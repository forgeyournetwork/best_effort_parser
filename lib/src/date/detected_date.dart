class DetectedDate {
  final dynamic date;
  final List<String> triggerTexts;

  DetectedDate(
    this.date,
    this.triggerTexts,
  );

  DetectedDate copyWith({
    dynamic date,
    List<String>? triggerTexts,
  }) {
    return DetectedDate(
      date ?? this.date,
      triggerTexts ?? this.triggerTexts,
    );
  }

  @override
  String toString() => 'DetectedDate(date: $date, triggerTexts: $triggerTexts)';

  @override
  int get hashCode => date.hashCode ^ triggerTexts.hashCode;
}
