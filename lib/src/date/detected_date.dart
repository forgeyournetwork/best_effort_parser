import 'parsed_date.dart';

class DetectedDate {
  final T date;
  final List<String> triggerTexts;

  DetectedDate({
    required this.date,
    required this.triggerTexts,
  });

  DetectedDate copyWith({
    T? date,
    List<String>? triggerTexts,
  }) {
    return DetectedDate(
      date: date ?? this.date,
      triggerTexts: triggerTexts ?? this.triggerTexts,
    );
  }

  @override
  String toString() => 'DetectedDate(date: $date, triggerTexts: $triggerTexts)';

  @override
  int get hashCode => date.hashCode ^ triggerTexts.hashCode;
}
