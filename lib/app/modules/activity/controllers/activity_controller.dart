import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginHistory {
  final String email;
  final String provider;
  final DateTime loginTime;
  final String device;

  LoginHistory({
    required this.email,
    required this.provider,
    required this.loginTime,
    required this.device,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'provider': provider,
        'loginTime': loginTime.toIso8601String(),
        'device': device,
      };

  factory LoginHistory.fromJson(Map<String, dynamic> json) {
    return LoginHistory(
      email: json['email'],
      provider: json['provider'],
      loginTime: DateTime.parse(json['loginTime']),
      device: json['device'] ?? 'unknown',
    );
  }
}

class ChartData {
  final DateTime date;
  final int count;

  ChartData(this.date, this.count);
}

class ActivityController extends GetxController {
  final RxList<LoginHistory> historyList = <LoginHistory>[].obs;
  final RxList<ChartData> chartData = <ChartData>[].obs;

  final GetStorage _storage = GetStorage();
  final String storageKey = 'login_history';

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  void loadHistory() async {
    final rawData = _storage.read<List>(storageKey) ?? [];

    // Gunakan key yang pasti ada
    final boxEmail = _storage.read('email');
    final prefs = await SharedPreferences.getInstance();
    final sharedEmail = prefs.getString('email');

    final currentEmail = boxEmail ?? sharedEmail;
    print('📨 Email aktif yang digunakan filter: $currentEmail');

    if (currentEmail == null) {
      print(
          "⚠️ Tidak ada email ditemukan di storage, tidak bisa filter history");
      historyList.clear();
      return;
    }

    final data = rawData
        .map((item) => LoginHistory.fromJson(Map<String, dynamic>.from(item)))
        .where((history) => history.email == currentEmail)
        .toList();

    print('📦 Semua history tersimpan: ${rawData.length} item');
    print('🔍 History yang cocok dengan email: ${data.length} item');

    historyList.assignAll(data.reversed.toList());
    generateChartData();
  }

  void addHistory(LoginHistory history) {
    final currentList = _storage.read<List>(storageKey) ?? [];
    currentList.add(history.toJson());
    _storage.write(storageKey, currentList);
    loadHistory(); // untuk memuat ulang dan filter berdasarkan email
  }

  void generateChartData() {
    Map<String, int> countMap = {};

    for (var history in historyList) {
      String key = DateFormat('yyyy-MM-dd').format(history.loginTime);
      countMap[key] = (countMap[key] ?? 0) + 1;
    }

    chartData.value = countMap.entries
        .map((e) => ChartData(DateTime.parse(e.key), e.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}
