import 'dart:core';

/// Immutable value class for the components of a date.
class ParsedDate {
  late int _year;
  int? _month, _day;

  /// Get the date's year.
  int get year => _year;

  /// Get the date's month.
  int? get month => _month;

  /// Get the date's day.
  int? get day => _day;

  /// Constructor for [ParsedDate], where if the [year] is null it is stored as 0 but [month] and
  /// [day] are stored as is (null if they aren't provided).
  ParsedDate(int? year, [int? month, int? day]) {
    _year = year ?? 0;
    _month = month;
    _day = day;
  }

  /// Static method constructor for [ParsedDate] so that this class may be constructed via
  /// reference.
  static ParsedDate constantConstructor(int? year, [int? month, int? day]) =>
      ParsedDate(year, month, day);

  /// Turn this [ParsedDate] into a Dart [DateTime], using 1 in place of a null [month] or [day].
  DateTime toDateTime() => DateTime(year, month ?? 1, day ?? 1);

  /// Evaluate if the [other] object is the same as this, by type and field equality.
  @override
  bool operator ==(other) =>
      other is ParsedDate &&
      year == other.year &&
      month == other.month &&
      day == other.day;

  /// Alias [toString] to [diagnosticString], forcing default parameters.
  @override
  String toString() => diagnosticString();

  /// Print out the [day], [month], and [year] (in that order) with labels before each term.
  ///
  /// If a term is null, both the label and the null will be omitted. Since [year] cannot be
  /// null, it and its label will always be present.
  String diagnosticString(
          {String separator = ' ',
          String dayLabel = '[Day]:',
          String monthLabel = '[Month]:',
          String yearLabel = '[Year]:'}) =>
      [
        if (day != null) dayLabel,
        if (day != null) day,
        if (month != null) monthLabel,
        if (month != null) month,
        yearLabel,
        year
      ].join(separator);
}
