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

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  void loadHistory() async {
    // Ambil email user yang sedang login
    final boxEmail = _storage.read('email');
    final prefs = await SharedPreferences.getInstance();
    final sharedEmail = prefs.getString('email');

    final currentEmail = boxEmail ?? sharedEmail;
    print('📨 Email aktif untuk filter: $currentEmail');

    if (currentEmail == null) {
      print("⚠️ Tidak ada email ditemukan di storage, tidak bisa filter history");
      historyList.clear();
      return;
    }

    final key = 'login_history_$currentEmail';
    final rawData = _storage.read<List>(key) ?? [];

    final data = rawData
        .map((item) => LoginHistory.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    print('📦 History total untuk $currentEmail: ${data.length} item');
    historyList.assignAll(data.reversed.toList());
    generateChartData();
  }

  void addHistory(LoginHistory history) {
    final key = 'login_history_${history.email}';
    final currentList = _storage.read<List>(key) ?? [];
    currentList.add(history.toJson());
    _storage.write(key, currentList);
    loadHistory(); // reload untuk user aktif
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

  // Optional: hapus history user tertentu
  void clearHistoryForUser(String email) {
    final key = 'login_history_$email';
    _storage.remove(key);
    historyList.clear();
    chartData.clear();
  }
}
