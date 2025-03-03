import 'package:flutter/material.dart';
import 'file_analysis_screen.dart';
import 'analysis_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 저장된 API 키 로드
  final storageService = AnalysisStorageService();
  final apiKey = await storageService.loadApiKey();
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF RAG 분석기',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const FileAnalysisScreen(),
    );
  }
}