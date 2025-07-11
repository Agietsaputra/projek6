import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiProvider {
  final _storage = const FlutterSecureStorage();
  final String baseUrl = 'https://flask-smart.vercel.app';
  final box = GetStorage();

  // Konfigurasi Google Sign-In yang konsisten
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<String?> readSecureStorage(String key) async {
    return await _storage.read(key: key);
  }

  // Register user baru
  Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      final body = _decodeResponse(response);
      return body;
    } catch (e) {
      throw 'Terjadi kesalahan koneksi atau server';
    }
  }

  // Login dengan email + password
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final body = _decodeResponse(response);

      if (response.statusCode == 200 && body['access_token'] != null) {
        await _storage.write(key: 'token', value: body['access_token']);
        if (body['data']?['username'] != null) {
          await _storage.write(
              key: 'user_name', value: body['data']['username']);
        }
        if (body['data']?['email'] != null) {
          await _storage.write(key: 'email', value: body['data']['email']);
        }
        return body;
      } else {
        throw body['message'] ?? 'Login gagal, coba lagi';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Login Basic Auth
  Future<Map<String, dynamic>> loginWithBasicAuth(
      String identifier, String password) async {
    final url = Uri.parse('$baseUrl/login/basic');
    try {
      final credentials = base64Encode(utf8.encode('$identifier:$password'));
      final response = await http.post(
        url,
        headers: {'Authorization': 'Basic $credentials'},
      );

      final body = _decodeResponse(response);

      if (response.statusCode == 200 && body['token'] != null) {
        await _storage.write(key: 'token', value: body['token']);
        if (body['user_name'] != null) {
          await _storage.write(key: 'user_name', value: body['user_name']);
        }
        return body;
      } else {
        throw body['message'] ?? 'Login Basic gagal';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Login dengan Google - Langsung tanpa backend
  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      print("🔄 Memulai login Google...");

      // 1. Pastikan sign out terlebih dahulu untuk menghindari konflik
      await _googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();

      // 2. Login dengan Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw 'Login Google dibatalkan';
      }

      print("✅ Google Sign-In berhasil: ${googleUser.email}");

      // 3. Ambil auth credential
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw 'Gagal mendapatkan token dari Google';
      }

      print("✅ Token Google diperoleh");

      // 4. Buat credential untuk Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 5. Login ke Firebase
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw 'Gagal login ke Firebase';
      }

      print("✅ Firebase login berhasil: ${firebaseUser.email}");

      // 6. Ambil ID Token dari Firebase
      final String? idToken = await firebaseUser.getIdToken();
      if (idToken == null) {
        throw 'Gagal mendapatkan ID Token Firebase';
      }

      print("✅ Firebase ID Token diperoleh");

      // 7. Kirim token ke backend Flask
      final url = Uri.parse('$baseUrl/login/google');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': idToken}),
      );

      final body = _decodeResponse(response);
      print("📡 Response dari backend: ${response.statusCode}");

      if (response.statusCode == 200 && body['token'] != null) {
        // 8. Simpan token dari backend Flask
        await _storage.write(key: 'token', value: body['token']);

        // 9. Simpan data profil
        final name =
            firebaseUser.displayName ?? googleUser.displayName ?? 'Google User';
        final email = firebaseUser.email ?? googleUser.email;
        final photo = firebaseUser.photoURL ?? googleUser.photoUrl ?? '';

        await _storage.write(key: 'user_name', value: name);
        await _storage.write(key: 'email', value: email);
        await _storage.write(key: 'picture', value: photo);

        // 10. Simpan juga ke GetStorage untuk backup
        await box.write('token', body['token']);
        await box.write('user_name', name);
        await box.write('email', email);
        await box.write('picture', photo);

        print("✅ Token dan data profil tersimpan");
        print("🔑 Token: ${body['token'].substring(0, 20)}...");

        return {
          'success': true,
          'message': 'Login Google berhasil',
          'token': body['token'],
          'user': {
            'name': name,
            'email': email,
            'picture': photo,
          }
        };
      } else {
        throw body['message'] ?? 'Login Google gagal di backend';
      }
    } catch (e) {
      print("❌ Error loginWithGoogle: $e");

      // Cleanup jika gagal
      await _googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();

      rethrow;
    }
  }

  // Login dengan Google - Tanpa backend (untuk development)
  Future<Map<String, dynamic>> loginWithGoogleLocal() async {
    
    try {
      print("🔄 Memulai login Google Local...");

      // 1. Pastikan sign out terlebih dahulu

      
      await _googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
      await debugStorage();

      // 2. Login dengan Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw 'Login Google dibatalkan';
      }

      print("✅ Google Sign-In berhasil: ${googleUser.email}");

      // 3. Ambil auth credential
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw 'Gagal mendapatkan token dari Google';
      }

      // 4. Buat credential untuk Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 5. Login ke Firebase
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw 'Gagal login ke Firebase';
      }

      // 6. Ambil ID Token dari Firebase sebagai token utama
      final String? idToken = await firebaseUser.getIdToken();
      if (idToken == null) {
        throw 'Gagal mendapatkan ID Token Firebase';
      }

      // 7. Simpan token dan data profil
      final name =
          firebaseUser.displayName ?? googleUser.displayName ?? 'Google User';
      final email = firebaseUser.email ?? googleUser.email;
      final photo = firebaseUser.photoURL ?? googleUser.photoUrl ?? '';

      await _storage.write(key: 'token', value: idToken);
      await box.write('token', idToken);

      await _storage.write(key: 'user_name', value: name);
      await _storage.write(key: 'email', value: email);
      await _storage.write(key: 'picture', value: photo);

      await box.write('user_name', name);
      await box.write('email', email);
      await box.write('picture', photo);

      print("✅ Token dan data profil tersimpan (Local)");
      print("🔑 Token: ${idToken.substring(0, 20)}...");

      return {
        'success': true,
        'message': 'Login Google berhasil (Local)',
        'token': idToken,
        'user': {
          'name': name,
          'email': email,
          'picture': photo,
        }
      };
    } catch (e) {
      print("❌ Error loginWithGoogleLocal: $e");

      // Cleanup jika gagal
      await _googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();

      rethrow;
    }
  }

  // Request OTP
  Future<Map<String, dynamic>> requestOtp(String email) async {
    final url = Uri.parse('$baseUrl/request-otp');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final body = _decodeResponse(response);

      if (response.statusCode == 200) {
        return body;
      } else {
        throw body['message'] ?? 'Gagal mengirim OTP';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Verifikasi OTP
  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    final url = Uri.parse('$baseUrl/verify-otp');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      final body = _decodeResponse(response);

      if (response.statusCode == 200) {
        return body;
      } else {
        throw body['message'] ?? 'Verifikasi OTP gagal';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword(
      String email, String newPassword) async {
    final url = Uri.parse('$baseUrl/reset-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'new_password': newPassword}),
      );

      final body = _decodeResponse(response);

      if (response.statusCode == 200) {
        return body;
      } else {
        throw body['message'] ?? 'Reset password gagal';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Kirim OTP untuk reset password
  Future<Map<String, dynamic>> requestOtpReset(String email) async {
    final url = Uri.parse('$baseUrl/request-otp-reset');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final body = _decodeResponse(response);

      if (response.statusCode == 200) {
        return body;
      } else {
        throw body['message'] ?? 'Gagal mengirim OTP reset password';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Verifikasi OTP reset password
  Future<Map<String, dynamic>> verifyOtpReset(String email, String otp) async {
    final url = Uri.parse('$baseUrl/verify-otp-reset');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      final body = _decodeResponse(response);

      if (response.statusCode == 200) {
        return body;
      } else {
        throw body['message'] ?? 'Verifikasi OTP reset password gagal';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Simpan riwayat lari per user (durasi dalam detik, jarak dalam kilometer)
  Future<void> simpanRiwayatLariLocal({
  required int durasi,
  required double jarak,
  required List<Map<String, double>> rute,
}) async {
  final box = GetStorage();
  final now = DateTime.now().toIso8601String();

  final riwayat = {
    'durasi': durasi,
    'jarak': jarak,
    'rute': rute,
    'tanggal': now,
  };

  // Ambil riwayat yang sudah ada
  final List existing = box.read('riwayat_lari') ?? [];

  // Tambahkan riwayat baru
  existing.add(riwayat);

  // Simpan ulang
  await box.write('riwayat_lari', existing);
}

  // Ambil riwayat lari user dari backend
  Future<List<Map<String, dynamic>>> getRiwayatLariLocal() async {
  final box = GetStorage();
  final List raw = box.read('riwayat_lari') ?? [];
  return raw.map((e) => Map<String, dynamic>.from(e)).toList();
}

  // Get profil user - Diperbaiki untuk cek token yang benar
  Future<Map<String, dynamic>?> getProfile() async {
    // Ambil data dari secure storage & GetStorage
    final email = await _storage.read(key: 'email') ?? box.read('email');
    final name = await _storage.read(key: 'user_name') ?? box.read('user_name');
    final picture = await _storage.read(key: 'picture') ?? box.read('picture');

    if (email == null || name == null) {
      print("❌ Tidak ada profil tersimpan lokal");
      return null;
    }

    return {
      'email': email,
      'name': name,
      'photo': picture,
      'role': 'user',
    };
  }

  // Update profil user
  Future<Map<String, dynamic>> updateProfile({
    String? email,
    String? password,
    String? name,
    String? picture,
    String? phone,
    String? username,
    String? gender,
  }) async {
    final token = await _storage.read(key: 'token');
    if (token == null) throw 'Token tidak ditemukan';

    final Map<String, dynamic> bodyData = {};
    if (email?.isNotEmpty == true) bodyData['email'] = email;
    if (password?.isNotEmpty == true) bodyData['password'] = password;
    if (name?.isNotEmpty == true) bodyData['name'] = name;
    if (picture?.isNotEmpty == true) bodyData['picture'] = picture;
    if (phone?.isNotEmpty == true) bodyData['phone'] = phone;
    if (username?.isNotEmpty == true) bodyData['username'] = username;
    if (gender?.isNotEmpty == true) bodyData['gender'] = gender;

    if (bodyData.isEmpty) throw 'Tidak ada data yang akan diperbarui';

    final url = Uri.parse('$baseUrl/profile');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(bodyData),
    );

    final body = _decodeResponse(response);

    if (response.statusCode == 200) {
      // Update local storage
      if (name?.isNotEmpty == true) {
        await _storage.write(key: 'user_name', value: name!);
        await box.write('user_name', name);
      }
      if (email?.isNotEmpty == true) {
        await _storage.write(key: 'email', value: email!);
        await box.write('email', email);
      }
      if (phone?.isNotEmpty == true) {
        await _storage.write(key: 'phone', value: phone!);
        await box.write('phone', phone);
      }
      if (username?.isNotEmpty == true) {
        await _storage.write(key: 'username', value: username!);
        await box.write('username', username);
      }
      if (gender?.isNotEmpty == true) {
        await _storage.write(key: 'gender', value: gender!);
        await box.write('gender', gender);
      }
      return body;
    } else {
      throw body['message'] ?? 'Gagal memperbarui profil';
    }
  }

  // Hapus akun
  Future<Map<String, dynamic>> deleteAccount() async {
    final token = await _storage.read(key: 'token');
    if (token == null) throw 'Token tidak ditemukan';

    final url = Uri.parse('$baseUrl/profile');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    final body = _decodeResponse(response);

    if (response.statusCode == 200) {
      return body;
    } else {
      throw body['message'] ?? 'Gagal menghapus akun';
    }
  }

  // Logout - Diperbaiki untuk clear semua storage
  // Future<void> clearToken() async {
  //   await _storage.deleteAll();
  //   await box.erase();
  // }

  Future<void> logout() async {
    try {
      // Sign out dari Google dan Firebase
      await _googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();

      // Clear semua storage
      // await clearToken();

      print("✅ Logout berhasil");
    } catch (e) {
      print("❌ Error logout: $e");
      // Tetap clear storage meskipun ada error
      // await clearToken();
    }
  }

  Future<String?> getToken() async {
    String? token = await _storage.read(key: 'token');
    print("🔐 SecureStorage token: $token");

    if (token == null) {
      token = box.read('token');
      print("📦 GetStorage token: $token");
    }

    return token;
  }

  // Refresh token
  Future<Map<String, dynamic>> refreshToken() async {
    final token = await getToken();
    if (token == null) throw 'Token tidak ditemukan';

    final url = Uri.parse('$baseUrl/refresh-token');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final body = _decodeResponse(response);

    if (response.statusCode == 200 && body['token'] != null) {
      await _storage.write(key: 'token', value: body['token']);
      await box.write('token', body['token']);
      return body;
    } else {
      throw body['message'] ?? 'Gagal refresh token';
    }
  }

  // Helper untuk debug storage
  Future<void> debugStorage() async {
    final secureToken = await _storage.read(key: 'token');
    final boxToken = box.read('token');

    print("🧪 Token dari SecureStorage: $secureToken");
    print("📦 Token dari GetStorage: $boxToken");
  }

  // Helper
  Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw 'Respons server tidak valid';
    }
  }
}
