import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:apa/app/data/api_provider.dart';

class Article {
  final String judul;
  final DateTime tanggal;
  final String link;
  final String isi;

  Article({
    required this.judul,
    required this.tanggal,
    required this.link,
    required this.isi,
  });
}

class HomeController extends GetxController {
  final ApiProvider _apiProvider = Get.find();
  final box = GetStorage();

  var email = ''.obs;
  var name = ''.obs;
  var photoUrl = ''.obs;

  final lastRun = Rxn<Map<String, dynamic>>();
  final totalDistanceThisWeek = 0.0.obs;
  var chartData = <String, double>{}.obs;
  final articles = <Article>[].obs;

  bool get sudahLariHariIni => lastRun.value != null;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    fetchRingkasanAktivitas();
    loadManualArticles();
  }

  void _loadUserData() async {
    try {
      final profile = await _apiProvider.getProfile();
      if (profile != null && profile.isNotEmpty) {
        email.value = profile['email'] ?? '';
        name.value = profile['name'] ?? '';
        photoUrl.value = profile['photo'] ?? '';
        box.write('userEmail', email.value);
        box.write('name', name.value);
        box.write('photo', photoUrl.value);
        return;
      }
    } catch (e) {
      print('⚠️ Gagal ambil dari API: $e');
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        email.value = user.email ?? '';
        name.value = user.displayName ?? '';
        photoUrl.value = user.photoURL ?? '';
        box.write('userEmail', email.value);
        box.write('name', name.value);
        box.write('photo', photoUrl.value);
        return;
      }
    } catch (e) {
      print('⚠️ Gagal ambil dari Firebase: $e');
    }

    // Fallback dari GetStorage
    email.value = box.read('userEmail') ?? 'Tidak ada email';
    name.value = box.read('name') ?? 'Pengguna';
    photoUrl.value = box.read('photo') ?? '';
  }

  Future<void> fetchRingkasanAktivitas() async {
    try {
      final data = await _apiProvider.getRiwayatLariLocal();

      final now = DateTime.now();
      final startOfWeek =
          DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
      final today = DateTime(now.year, now.month, now.day);

      // 🔍 Ambil data hari ini
      final todayRuns = data.where((e) {
        final raw = e['tanggal']?.toString() ?? '';
        final date = DateTime.tryParse(raw);
        if (date == null) return false;
        final onlyDate = DateTime(date.year, date.month, date.day);
        return onlyDate == today;
      }).toList();

      if (todayRuns.isNotEmpty) {
        todayRuns.sort((a, b) {
          final aDate = DateTime.tryParse(a['tanggal'].toString()) ?? DateTime(1970);
          final bDate = DateTime.tryParse(b['tanggal'].toString()) ?? DateTime(1970);
          return bDate.compareTo(aDate);
        });
        lastRun.value = todayRuns.first;
      } else {
        lastRun.value = null;
      }

      // 📊 Total jarak minggu ini
      final total = data.where((e) {
        final raw = e['tanggal']?.toString() ?? '';
        final date = DateTime.tryParse(raw);
        return date != null && !date.isBefore(startOfWeek);
      }).fold<double>(0.0, (sum, e) {
        final jarak = (e['jarak'] is num) ? (e['jarak'] as num).toDouble() : 0.0;
        return sum + jarak;
      });

      totalDistanceThisWeek.value = total;

      // 📈 Grafik harian minggu ini
      final tempData = {
        'Sen': 0.0,
        'Sel': 0.0,
        'Rab': 0.0,
        'Kam': 0.0,
        'Jum': 0.0,
        'Sab': 0.0,
        'Min': 0.0,
      };

      for (var e in data) {
        final raw = e['tanggal']?.toString() ?? '';
        final date = DateTime.tryParse(raw);
        if (date != null && !date.isBefore(startOfWeek)) {
          final hari = _hariSingkat(date.weekday);
          final jarak = (e['jarak'] is num) ? (e['jarak'] as num).toDouble() : 0.0;
          tempData[hari] = tempData[hari]! + jarak;
        }
      }

      chartData.value = tempData;
    } catch (e) {
      print("❌ Error fetchRingkasanAktivitas: $e");
    }
  }

  String _hariSingkat(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Sen';
      case DateTime.tuesday:
        return 'Sel';
      case DateTime.wednesday:
        return 'Rab';
      case DateTime.thursday:
        return 'Kam';
      case DateTime.friday:
        return 'Jum';
      case DateTime.saturday:
        return 'Sab';
      case DateTime.sunday:
        return 'Min';
      default:
        return '';
    }
  }

  void loadManualArticles() {
    final List<Map<String, String>> rawData = [
      {
        "judul": "Jelang Puncak Arus Balik...",
        "tanggal": "Sabtu, 13 Apr 2024 11:00 WIB",
        "link": "https://health.detik.com/kebugaran/d-7290517/...",
        "isi": "Seperti halnya arus mudik..."
      },
      {
        "judul": "Pegal-pegal Kelamaan Duduk...",
        "tanggal": "Minggu, 07 Apr 2024 06:57 WIB",
        "link": "https://health.detik.com/berita-detikhealth/d-7282874/...",
        "isi": "Salah satu risiko perjalanan..."
      },
      {
        "judul": "Tips Jaga Stamina dan Kebugaran...",
        "tanggal": "Jumat, 21 Mar 2025 11:15 WIB",
        "link": "https://www.detik.com/sumut/berita/d-7834353/...",
        "isi": "Itikaf merupakan salah satu kegiatan..."
      },
    ];

    articles.value = rawData.map((e) {
      return Article(
        judul: e['judul'] ?? '',
        tanggal: parseTanggal(e['tanggal'] ?? ''),
        link: e['link'] ?? '',
        isi: e['isi'] ?? '',
      );
    }).toList();
  }

  DateTime parseTanggal(String tanggalStr) {
    try {
      return DateFormat("EEEE, dd MMM yyyy HH:mm 'WIB'", 'id_ID').parse(tanggalStr);
    } catch (_) {
      try {
        return DateFormat("dd MMM yyyy", 'id_ID').parse(tanggalStr);
      } catch (_) {
        return DateTime(1970);
      }
    }
  }
}
