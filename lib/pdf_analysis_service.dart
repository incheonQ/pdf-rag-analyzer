import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';
import 'dart:typed_data';


class PdfAnalysisService {
  // AI API URL (OpenAI 또는 다른 서비스)
  final String apiUrl = 'https://api.openai.com/v1/chat/completions';
  late final String apiKey;

  PdfAnalysisService({String? initialApiKey}) {
    if (initialApiKey != null) {
      apiKey = initialApiKey;
    }
  }

  // PDF에서 텍스트 추출
  Future<String> extractTextFromPdf(File file) async {
    try {
      PdfDocument document = PdfDocument(inputBytes: await file.readAsBytes());
      String text = PdfTextExtractor(document).extractText();
      document.dispose();
      return text;
    } catch (e) {
      throw Exception('PDF 텍스트 추출 실패: $e');
    }
  }

  // RAG를 사용한 내용 분석 요청
Future<String> analyzeContent(String content) async {
  try {
    // 긴 내용인 경우 적절한 길이로 자르기
    if (content.length > 4000) {
      content = content.substring(0, 4000);
    }

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json; charset=utf-8', // UTF-8 명시
        'Authorization': 'Bearer $apiKey',
        'Accept': 'application/json; charset=utf-8', // UTF-8 응답 요청
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'system',
            'content': '당신은 문서 분석 전문가입니다. 제공된 텍스트에서 중요한 핵심 내용을 추출하고 요약해주세요. 업체명이나 사람 이름과 같은 고유명사는 기존 언어 텍스트를 유지해주세요. 그 밖의 모든 것은 한국어로 번역해주세요.'
          },
          {
            'role': 'user',
            'content': '다음 문서 내용을 분석하고 핵심 내용을 요약해주세요: $content'
          }
        ],
        'temperature': 0.3,
        'max_tokens': 500
      }),
      encoding: Encoding.getByName('utf-8'), // 명시적 UTF-8 인코딩 설정
    );

    if (response.statusCode == 200) {
      // UTF-8로 응답 디코딩
      final responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> data = jsonDecode(responseBody);
      return data['choices'][0]['message']['content'];
    } else {
      // 오류 응답도 UTF-8로 디코딩
      final errorBody = utf8.decode(response.bodyBytes);
      throw Exception('API 요청 실패: ${response.statusCode} $errorBody');
    }
  } catch (e) {
    throw Exception('내용 분석 실패: $e');
  }
}

  // 바이트 데이터로부터 PDF 텍스트 추출
Future<String> extractTextFromPdfBytes(Uint8List bytes) async {
  try {
    PdfDocument document = PdfDocument(inputBytes: bytes);
    String text = PdfTextExtractor(document).extractText();
    document.dispose();
    return text;
  } catch (e) {
    throw Exception('PDF 텍스트 추출 실패: $e');
  }
}

// 바이트 데이터 기반 전체 프로세스 처리
Future<String> analyzePdfBytes(Uint8List bytes, String fileName) async {
  try {
    String extractedText = await extractTextFromPdfBytes(bytes);
    String analysis = await analyzeContent(extractedText);
    return analysis;
  } catch (e) {
    print(e);
    throw Exception('PDF 분석 실패: $e');
  }
}

  // 전체 프로세스 처리
  Future<String> analyzePdf(File file) async {
    try {
      String extractedText = await extractTextFromPdf(file);
      String analysis = await analyzeContent(extractedText);
      return analysis;
    } catch (e) {
      print(e);
      throw Exception('PDF 분석 실패: $e');
    }
  }
}