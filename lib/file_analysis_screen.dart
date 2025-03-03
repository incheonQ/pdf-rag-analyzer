import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'analysis_model.dart';
import 'analysis_detail_screen.dart';
import 'pdf_analysis_service.dart';
import 'dart:typed_data';
import 'analysis_storage_service.dart';


class FileAnalysisScreen extends StatefulWidget {
  final String? initialApiKey;
  
  const FileAnalysisScreen({super.key, this.initialApiKey});

  @override
  State<FileAnalysisScreen> createState() => _FileAnalysisScreenState();
}

class _FileAnalysisScreenState extends State<FileAnalysisScreen> {

  Uint8List? selectedFileBytes; // 파일 데이터를 바이트 형태로 저장
  String? selectedFileName; // 파일 이름 저장
  List<AnalysisResult> analysisHistory = [];
  bool isAnalyzing = false;
  final PdfAnalysisService _analysisService = PdfAnalysisService();
  final TextEditingController _apiKeyController = TextEditingController();
  final AnalysisStorageService _storageService = AnalysisStorageService();
  
  @override
  void initState() {
    super.initState();

    // 초기 API 키 설정
    if (widget.initialApiKey != null && widget.initialApiKey!.isNotEmpty) {
      _apiKeyController.text = widget.initialApiKey!;
      _analysisService.apiKey = widget.initialApiKey!;
    } else {
      _loadApiKey();
    }
  }
  
  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }
  
  // API 키 로드 함수
  Future<void> _loadApiKey() async {
    final apiKey = await _storageService.loadApiKey();
    if (apiKey != null) {
      setState(() {
        _apiKeyController.text = apiKey;
        _analysisService.apiKey = apiKey;
      });
    }
  }
  
  // API 키 저장 함수
  Future<void> _saveApiKey() async {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isNotEmpty) {
      await _storageService.saveApiKey(apiKey);
      _analysisService.apiKey = apiKey;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API 키가 저장되었습니다')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API 키를 입력해주세요')),
      );
    }
  }

  Future<void> _pickFile() async {
  print('파일 선택 시작');
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'],
    withData: true, // 파일 데이터를 직접 가져옵니다
  );
  
  if (result != null) {
    final file = result.files.single;
    if (file.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('파일 데이터를 가져오지 못했습니다')),
      );
      return;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('선택한 파일: ${file.name}')),
    );

    setState(() {
      selectedFileBytes = file.bytes;
      selectedFileName = file.name;
      print('파일이 성공적으로 설정됨: ${file.name}');
    });
  } else {
    print('파일을 선택하지 않았습니다');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('파일을 선택하지 않았습니다')),
    );
  }
}

  Future<void> _analyzeFile() async {
  if (selectedFileBytes == null || selectedFileName == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('먼저 PDF 파일을 선택해주세요')),
    );
    return;
  }

  setState(() {
    isAnalyzing = true;
  });

  try {
    // RAG 기술을 사용한 PDF 분석
    final analysisResult = await _analysisService.analyzePdfBytes(
      selectedFileBytes!, 
      selectedFileName!
    );
    
    final newAnalysis = AnalysisResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: selectedFileName!,
      dateTime: DateTime.now(),
      results: analysisResult,
    );

    setState(() {
      analysisHistory.add(newAnalysis);
      selectedFileBytes = null;
      selectedFileName = null;
      isAnalyzing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF 분석이 완료되었습니다')),
    );
  } catch (e) {
    setState(() {
      isAnalyzing = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('분석 중 오류가 발생했습니다: $e')),
    );
  }
}

  void _deleteAnalysis(String id) {
    setState(() {
      analysisHistory.removeWhere((analysis) => analysis.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF 분석기'),
      ),
      drawer: Drawer(
  child: Column(
    children: [
      DrawerHeader(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
        ),
        child: const Center(
          child: Text(
            '설정 및 기록',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
      ),
      // API 키 섹션 추가
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'OpenAI API 키',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'API 키를 입력하세요',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _saveApiKey,
              child: const Text('API 키 저장'),
            ),
          ],
        ),
      ),
      const Divider(),
      const Padding(
        padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
        child: Text(
          '분석 기록',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Expanded(
        child: analysisHistory.isEmpty
          ? const Center(child: Text('분석 기록이 없습니다'))
          : ListView.builder(
              itemCount: analysisHistory.length,
                      itemBuilder: (context, index) {
                        final analysis = analysisHistory[index];
                        return ListTile(
                          title: Text(analysis.fileName),
                          subtitle: Text(
                            '${analysis.dateTime.year}/${analysis.dateTime.month}/${analysis.dateTime.day} ${analysis.dateTime.hour}:${analysis.dateTime.minute}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteAnalysis(analysis.id),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AnalysisDetailScreen(
                                  analysis: analysis,
                                  onDelete: () => _deleteAnalysis(analysis.id),
                                  onUpdate: (updatedAnalysis) {
                                    setState(() {
                                      final index = analysisHistory.indexWhere(
                                          (a) => a.id == updatedAnalysis.id);
                                      if (index != -1) {
                                        analysisHistory[index] = updatedAnalysis;
                                      }
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      body: Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      selectedFileName != null
          ? Text('선택된 파일: $selectedFileName')
          : const Text('PDF 파일을 선택해주세요'),
      const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('PDF 파일 첨부하기'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
              onPressed: isAnalyzing ? null : _pickFile,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: isAnalyzing 
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2)
                  )
                : const Icon(Icons.analytics),
              label: Text(isAnalyzing ? '분석 중...' : 'RAG 기술로 분석하기'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
              onPressed: isAnalyzing ? null : _analyzeFile,
            ),
          ],
        ),
      ),
    );
  }
}