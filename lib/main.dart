import 'package:flutter/material.dart';
import 'file_analysis_screen.dart';
import 'analysis_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 저장된 API 키 로드
  final storageService = AnalysisStorageService();
  final apiKey = await storageService.loadApiKey();
  if (apiKey != null) {
    print('불러온 API 키: $apiKey');
  } else {
    print('저장된 API 키가 없습니다. 새로 입력해주세요.');
  }
    runApp(MyApp(initialApiKey: apiKey));
}

class MyApp extends StatelessWidget {
  final String? initialApiKey;
  
  const MyApp({super.key, this.initialApiKey});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF RAG 분석기',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: FileAnalysisScreen(initialApiKey: initialApiKey),
    );
  }
}