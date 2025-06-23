import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiProvider {
  final _storage = const FlutterSecureStorage();
  final String baseUrl = 'https://flask-smart.vercel.app';

  final GoogleSignIn _googleSignIn = GoogleSignIn();

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

  // Login dengan Google
  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      // 1. Login dengan Google Sign-In
      final GoogleSignInAccount? googleUser =
          await GoogleSignIn(scopes: ['email', 'profile']).signIn();
      if (googleUser == null) throw 'Login Google dibatalkan';

      // 2. Ambil auth credential
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 3. Login ke Firebase
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      final idToken = await firebaseUser?.getIdToken();
      if (idToken == null) throw 'Gagal mendapatkan ID Token Firebase';

      // 4. Kirim token ke backend Flask
      final url = Uri.parse('$baseUrl/login/google');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': idToken}),
      );

      final body = _decodeResponse(response);

      if (response.statusCode == 200 && body['token'] != null) {
        // 5. Simpan token dari backend Flask
        await _storage.write(key: 'token', value: body['token']);

        // 6. Simpan data profil Google (dari Firebase user atau googleUser)
        final name = firebaseUser?.displayName ??
            googleUser.displayName ??
            'Google User';
        final email = firebaseUser?.email ?? googleUser.email;
        final photo = firebaseUser?.photoURL ?? googleUser.photoUrl ?? '';

        await _storage.write(key: 'user_name', value: name);
        await _storage.write(key: 'email', value: email);
        await _storage.write(key: 'picture', value: photo);

        return body;
      } else {
        throw body['message'] ?? 'Login Google gagal';
      }
    } catch (e) {
      print("❌ Error loginWithGoogle: $e");
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
Future<void> simpanRiwayatLari({
  required int durasi,
  required double jarak,
}) async {
  final token = await _storage.read(key: 'token');
  if (token == null) throw 'Token tidak ditemukan';

  final url = Uri.parse('$baseUrl/riwayat-lari');
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'durasi': durasi,
      'jarak': jarak,
    }),
  );

  final body = _decodeResponse(response);

  if (response.statusCode != 200) {
    throw body['message'] ?? 'Gagal menyimpan riwayat lari';
  }
}

// Ambil riwayat lari user dari backend
Future<List<Map<String, dynamic>>> getRiwayatLari() async {
  final token = await _storage.read(key: 'token');
  if (token == null) throw 'Token tidak ditemukan';

  final url = Uri.parse('$baseUrl/riwayat-lari');
  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  final body = _decodeResponse(response);

  if (response.statusCode == 200) {
    final List<dynamic> data = body['riwayat_lari'] ?? [];
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  } else {
    throw body['message'] ?? 'Gagal mengambil riwayat lari';
  }
}


  // Get profil user
  Future<Map<String, dynamic>> getProfile() async {
    final token = await _storage.read(key: 'token');
    if (token == null) throw 'Token tidak ditemukan';

    final url = Uri.parse('$baseUrl/profile');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    final body = _decodeResponse(response);

    if (response.statusCode == 200) {
      if (body['name'] != null) {
        await _storage.write(key: 'user_name', value: body['name']);
      }
      if (body['email'] != null) {
        await _storage.write(key: 'email', value: body['email']);
      }
      return body;
    } else {
      throw 'Gagal mengambil profil: ${response.statusCode}';
    }
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
      if (name?.isNotEmpty == true) {
        await _storage.write(key: 'user_name', value: name!);
      }
      if (email?.isNotEmpty == true) {
        await _storage.write(key: 'email', value: email!);
      }
      if (phone?.isNotEmpty == true) {
        await _storage.write(key: 'phone', value: phone!);
      }
      if (username?.isNotEmpty == true) {
        await _storage.write(key: 'username', value: username!);
      }
      if (gender?.isNotEmpty == true) {
        await _storage.write(key: 'gender', value: gender!);
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

  // Logout
  Future<void> clearToken() async {
    await _storage.deleteAll();
  }

  Future<void> logout() async {
    await clearToken();
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
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
      return body;
    } else {
      throw body['message'] ?? 'Gagal refresh token';
    }
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
