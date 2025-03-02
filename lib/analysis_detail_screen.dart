import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'analysis_model.dart';

class AnalysisDetailScreen extends StatefulWidget {
  final AnalysisResult analysis;
  final VoidCallback onDelete;
  final Function(AnalysisResult) onUpdate;

  const AnalysisDetailScreen({
    super.key,
    required this.analysis,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<AnalysisDetailScreen> createState() => _AnalysisDetailScreenState();
}

class _AnalysisDetailScreenState extends State<AnalysisDetailScreen> {
  late TextEditingController _notesController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.analysis.notes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final updatedAnalysis = widget.analysis.copyWith(
      notes: _notesController.text,
    );
    widget.onUpdate(updatedAnalysis);
    setState(() {
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('메모가 저장되었습니다')),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('클립보드에 복사되었습니다')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('분석 결과: ${widget.analysis.fileName}'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveChanges();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.content_copy),
            onPressed: () {
              _copyToClipboard(widget.analysis.results);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('분석 삭제'),
                    content: const Text('이 분석 결과를 삭제하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          widget.onDelete();
                          Navigator.pop(context); // 다이얼로그 닫기
                          Navigator.pop(context); // 상세 화면 닫기
                        },
                        child: const Text('삭제'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '파일명: ${widget.analysis.fileName}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '분석 일시: ${widget.analysis.dateTime.year}/${widget.analysis.dateTime.month}/${widget.analysis.dateTime.day} ${widget.analysis.dateTime.hour}:${widget.analysis.dateTime.minute}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'RAG 분석 결과:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              flex: 2,
              child: Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SingleChildScrollView(
                    child: Text(
                      widget.analysis.results,
                      style: GoogleFonts.notoSansJp(
            fontSize: 16,
          ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '메모:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_isEditing)
                  TextButton(
                    onPressed: _saveChanges,
                    child: const Text('저장'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              flex: 1,
              child: _isEditing
                  ? TextField(
                      controller: _notesController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '메모를 입력하세요',
                      ),
                      style: GoogleFonts.notoSansJp(
            fontSize: 16,
          ),
                    )
                  : GestureDetector(
                      onTap: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
                      child: Card(
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SingleChildScrollView(
                            child: Text(
                              widget.analysis.notes.isEmpty
                                  ? '메모를 추가하려면 탭하세요'
                                  : widget.analysis.notes,
                             style: GoogleFonts.notoSansJp( // 수정
                  fontSize: 16,
                  color: widget.analysis.notes.isEmpty 
                    ? Colors.grey 
                    : Colors.black,
                ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}