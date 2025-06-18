import 'package:get/get.dart';
import 'package:intl/intl.dart';

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

class ChartData {
  final DateTime date;
  final int count;

  ChartData(this.date, this.count);
}

class ChartDomain {
  final String domain;
  final int count;

  ChartDomain(this.domain, this.count);
}

class VisualisasiController extends GetxController {
  RxList<Article> articles = <Article>[].obs;
  RxList<ChartData> chartPerTanggal = <ChartData>[].obs;
  RxList<ChartDomain> chartPerDomain = <ChartDomain>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadManualArticles();
    generateChartPerTanggal();
    generateChartPerDomain();
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
      // Tambahkan lainnya...
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
      return DateFormat("EEEE, dd MMM yyyy HH:mm 'WIB'", 'id_ID')
          .parse(tanggalStr);
    } catch (_) {
      return DateTime.now();
    }
  }

  void generateChartPerTanggal() {
    Map<String, int> countMap = {};
    for (var article in articles) {
      String key = DateFormat('yyyy-MM-dd').format(article.tanggal);
      countMap[key] = (countMap[key] ?? 0) + 1;
    }

    chartPerTanggal.value = countMap.entries
        .map((e) => ChartData(DateTime.parse(e.key), e.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  void generateChartPerDomain() {
    Map<String, int> domainMap = {};
    for (var article in articles) {
      try {
        String domain = Uri.parse(article.link).host;
        domainMap[domain] = (domainMap[domain] ?? 0) + 1;
      } catch (_) {}
    }

    chartPerDomain.value = domainMap.entries
        .map((e) => ChartDomain(e.key, e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
  }
}
