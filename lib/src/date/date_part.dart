import 'dart:convert';

class DatePart {
  final int? value;
  final String text;

  DatePart({
    required this.value,
    required this.text,
  });

  DatePart copyWith({
    int? value,
    String? text,
  }) {
    return DatePart(
      value: value ?? this.value,
      text: text ?? this.text,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'text': text,
    };
  }

  factory DatePart.fromMap(Map<String, dynamic> map) {
    return DatePart(
      value: map['value']?.toInt(),
      text: map['text'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory DatePart.fromJson(String source) =>
      DatePart.fromMap(json.decode(source));

  @override
  String toString() => 'DatePart(value: $value, text: $text)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DatePart && other.value == value && other.text == text;
  }

  @override
  int get hashCode => value.hashCode ^ text.hashCode;
}
