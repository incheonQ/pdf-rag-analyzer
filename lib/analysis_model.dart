class AnalysisResult {
  final String id;
  final String fileName;
  final DateTime dateTime;
  final String results;
  final String notes;

  AnalysisResult({
    required this.id,
    required this.fileName,
    required this.dateTime,
    required this.results,
    this.notes = '',
  });

  AnalysisResult copyWith({
    String? id,
    String? fileName,
    DateTime? dateTime,
    String? results,
    String? notes,
  }) {
    return AnalysisResult(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      dateTime: dateTime ?? this.dateTime,
      results: results ?? this.results,
      notes: notes ?? this.notes,
    );
  }
}