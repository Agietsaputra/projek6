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
        "judul": "Mengenal Stretching, Jenis dan Manfaatnya untuk Tubuh",
        "tanggal": "Kamis, 26 Sep 2024 14:00 WIB",
        "link": "https://www.halodoc.com/artikel/mengenal-stretching-jenis-dan-manfaatnya-untuk-tubuh",
        "isi": "Stretching adalah aktivitas yang meningkatkan fleksibilitas, rentang gerak, dan performa fisik, serta mencegah cedera. Dengan memahami jenis-jenis dan manfaatnya, kamu dapat memulai stretching agar memperoleh kesehatan yang lebih baik."
      },
      {
        "judul": "Stretching: Jenis dan Manfaatnya bagi Tubuh",
        "tanggal": "Senin, 11 Nov 2024 15:00 WIB",
        "link": "https://www.alodokter.com/stretching-jenis-dan-manfaatnya-bagi-tubuh",
        "isi": "Stretching atau peregangan otot adalah aktivitas yang dilakukan untuk menjaga otot-otot tubuh tetap lentur, kuat dan, sehat. Terdapat beragam jenis stretching yang bermanfaat bagi kesehatan dan kebugaran tubuh."
      },
      {
        "judul": "Ketahui Apa itu Stretching dan Manfaatnya Untuk Kesehatan!",
        "tanggal": "Senin, 14 Okt 2024 14:00 WIB",
        "link": "https://enesis.com/id/artikel/apa-itu-stretching/",
        "isi": "Salah satu cara untuk menjaga kesehatan tubuh adalah dengan melakukan peregangan atau stretching. Apa itu stretching? Stretching adalah latihan ringan yang sangat bermanfaat untuk meningkatkan fleksibilitas, mengurangi nyeri otot, dan meningkatkan sirkulasi darah."
      },
      {
        "judul": "5 Manfaat Stretching bagi Tubuh dan Cara Melakukan Gerakannya",
        "tanggal": "Kamis, 07 Jul 2022 14:00 WIB",
        "link": "https://www.alodokter.com/terkesan-sederhana-ini-manfaat-stretching-bagi-tubuh",
        "isi": "Biasanya, stretching melibatkan otot bahu, dada, leher, punggung, pinggul, kaki, dan pergelangan kaki. Gerakan stretching juga baik dilakukan oleh ibu hamil yang rentan mengalami nyeri punggung."
      },
      {
        "judul": "Manfaat Peregangan Sebelum, Selama, dan Setelah Olahraga",
        "tanggal": "Jumat, 12 Feb 2021 15:00 WIB",
        "link": "https://www.cnnindonesia.com/gaya-hidup/20210201120357-255-600797/manfaat-peregangan-sebelum-selama-dan-setelah-olahraga",
        "isi": "Pemanasan jadi menu mutlak sebelum berolahraga, termasuk peregangan. Peregangan membuat olahraga yang dilakukan aman dari risiko cedera. Sebagian orang menyangka peregangan hanya dilakukan sebelum berolahraga. Padahal, setelah dan selama olahraga pun, peregangan layak dilakukan dan membawa manfaat tersendiri."
      },
      {
        "judul": "7 Manfaat Peregangan untuk Kesehatan Otot dan Sendi",
        "tanggal": "Senin, 26 Agu 2024 14:00 WIB",
        "link": "https://www.ciputramedicalcenter.com/manfaat-peregangan/",
        "isi": "Tujuan gerakan peregangan adalah untuk membuat otot lebih lentur. Seiring bertambahnya usia, tubuh cenderung mudah kaku dan terasa pegal. Kondisi ini bisa semakin parah apabila Anda jarang berolahraga atau melakukan aktivitas fisik."
      },
      {
        "judul": "5 Waktu yang Tepat untuk Melakukan Peregangan Setiap Harinya",
        "tanggal": "Kamis, 07 Okt 2021 14:00 WIB",
        "link": "https://www.idntimes.com/health/fitness/waktu-yang-tepat-untuk-melakukan-peregangan-c1c2-01-ttmm6-tfthw1",
        "isi": "Banyak dari kita yang menggeliatkan tubuh sesaat setelah bangun tidur. Kebiasaan ini tanpa disadari termasuk gerakan peregangan yang bisa melawan kekakuan tubuh setelah terlelap semalaman."
      },
      {
        "judul": "Apa Itu Stretching dan 7 Jenis Latihannya",
        "tanggal": "Data tidak tersedia",
        "link": "https://fithub.id/blog/apa-itu-stretching/",
        "isi": "Stretching adalah hal yang harus dilakukan secara rutin setiap hari menurut Harvard Health Publishing. Alasannya, stretching atau peregangan membuat otot tetap fleksibel, kuat, dan sehat."
      },
      {
        "judul": "Peregangan Ternyata Bermanfaat Bagi Tubuh Lho!",
        "tanggal": "Minggu, 17 Nov 2019 15:00 WIB",
        "link": "https://ayosehat.kemkes.go.id/peregangan-ternyata-bermanfaat-bagi-tubuh-lho",
        "isi": "Salah satu manfaat melakukan peregangan adalah untuk menghindari terjadinya cedera. Hal ini dikarenakan peregangan dapat meningkatkan vitalitas yang membuat tubuh menjadi mudah dengan gerakan yang tiba-tiba."
      },
      {
        "judul": "Bagaimana Cara Melakukan Peregangan sebelum Berolahraga?",
        "tanggal": "Jumat, 27 Agu 2021 14:00 WIB",
        "link": "https://www.halodoc.com/artikel/bagaimana-cara-melakukan-peregangan-sebelum-berolahraga",
        "isi": "Sebab, otot merespon lebih baik terhadap tekanan yang diberikan tubuh saat melakukan pemanasan. Maka, lakukanlah pemanasan ringan seperti berjalan lima sampai 10 menit. Hal ini bertujuan agar darah mengalir ke seluruh tubuh dengan lancar."
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
