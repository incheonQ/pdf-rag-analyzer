import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'analysis_model.dart';


class AnalysisStorageService {
  static const String _storageKey = 'analysis_history';
  
  // 분석 결과 저장
  Future<void> saveAnalysisHistory(List<AnalysisResult> history) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = history.map((item) => {
      'id': item.id,
      'fileName': item.fileName,
      'dateTime': item.dateTime.toIso8601String(),
      'results': item.results,
      'notes': item.notes,
    }).toList();
    
    await prefs.setString(_storageKey, jsonEncode(jsonData));
  }
  
  // 분석 결과 불러오기
  Future<List<AnalysisResult>> loadAnalysisHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    
    if (jsonString == null) {
      return [];
    }
    
    final jsonData = jsonDecode(jsonString) as List;
    return jsonData.map((item) => AnalysisResult(
      id: item['id'],
      fileName: item['fileName'],
      dateTime: DateTime.parse(item['dateTime']),
      results: item['results'],
      notes: item['notes'] ?? '',
    )).toList();
  }

  // API 키 저장
Future<void> saveApiKey(String apiKey) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('openai_api_key', apiKey);
}

// API 키 불러오기
Future<String?> loadApiKey() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('openai_api_key');
}
}