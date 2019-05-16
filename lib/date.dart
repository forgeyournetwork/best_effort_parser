import 'dart:collection';

import 'package:best_effort_parser/src/date/parsed_date.dart';

typedef ParsedDateStorage<T> = T Function(int year, [int month, int day]);

enum CompactDateFormat { dayFirst, monthFirst, yearFirst }

class DateParser<T> {
  static const List<String> defaultSeasons = [
    r'spring',
    r'summer',
    r'fall|autumn',
    r'winter',
  ];

  static const List<String> defaultMonths = [
    r'jan',
    r'feb',
    r'mar',
    r'apr',
    r'may',
    r'jun',
    r'jul',
    r'aug',
    r'sep',
    r'oct',
    r'nov',
    r'dec'
  ];

  static const String defaultDigitSuffixes = r'st|nd|rd|th';

  static const Map<int, int> defaultFourDigitOffsets = {
    30: 2000, // For years less than 30, add 2000
    100: 1900, // For years at least 30 but less than 100, add 1900
    1000: 0 // For years ad least 100 but less than 1000, add 0
  };

  static const Map<int, int> defaultSeasonToMonthApproximations = {
    1: 3, // Spring starts in March
    2: 6, // Summer starts in June
    3: 9, // Fall starts in September
    4: 12 // Winter starts in December
  };

  List<RegExp> _seasons, _months;
  RegExp _digitSuffixes;
  SplayTreeMap<int, int> _fourDigitOffsets;
  Map<int, int> _seasonToMonth;
  CompactDateFormat _compactDateFormat;
  ParsedDateStorage<T> _parsedDateStorage;

  /// Constructor for [DateParser], specifying the output format with the option to customize the
  /// behavior of [parse].
  ///
  /// - [compactDateFormat]: what to assume when given an ambiguous compact date (like 10/10/2000),
  /// defaults to MM/DD/YYYY (see [CompactDateFormat.monthFirst])
  /// - [months]: ordered list of patterns for detecting months, defaults to English (see
  /// [defaultMonths])
  /// - [seasons]: **nullable* ordered list of patterns for detecting seasons starting with spring,
  /// defaults
  /// to English (see [defaultSeasons]). If null, seasons will be ignored
  /// - [seasonToMonth]: **nullable** mapping of how seasons (by their order, spring bring 1)
  /// should be converted to months, defaults to the month in which the season starts (see
  /// [defaultSeasonToMonthApproximations]). If null, seasons will be ignored.
  /// - [digitSuffixes]: **nullable** pattern of digit suffixes to be stripped before parsing
  /// numbers, defaults to English (see [defaultDigitSuffixes]. If null, no suffixes will be
  /// stripped (and thus 1st January 2000 would only have January and 2000 parsed).
  /// - [fourDigitOffsets]: **nullable** mapping of how two/three digit years should be converted
  /// to four digits, defaults to `[0, 30)` being plus 2000 and `[30, 100) being plus 1900 (see
  /// [defaultFourDigitOffsets]). If null, no conversion will be done.
  DateParser(ParsedDateStorage<T> parsedDateStorage,
      {CompactDateFormat compactDateFormat: CompactDateFormat.monthFirst,
      List<Pattern> months: defaultMonths,
      List<Pattern> seasons: defaultSeasons,
      Map<int, int> seasonToMonth: defaultSeasonToMonthApproximations,
      Pattern digitSuffixes: defaultDigitSuffixes,
      Map<int, int> fourDigitOffsets: defaultFourDigitOffsets}) {
    _parsedDateStorage = parsedDateStorage;
    _compactDateFormat = compactDateFormat;
    _months = months.map(_toRegExp).toList();
    _seasons = (seasons != null ? seasons : <String>[]).map(_toRegExp).toList();
    _digitSuffixes = _toRegExp(digitSuffixes ?? '');
    _fourDigitOffsets = SplayTreeMap.of(fourDigitOffsets ?? {});
    _seasonToMonth = seasonToMonth;
  }

  /// Behaves the same as the constructor for [DateParser] except that the output format is
  /// specified to be [ParsedDate].
  static DateParser<ParsedDate> basic(
          {CompactDateFormat compactDateFormat: CompactDateFormat.monthFirst,
          List<Pattern> months: defaultMonths,
          List<Pattern> seasons: defaultSeasons,
          Map<int, int> seasonToMonth: defaultSeasonToMonthApproximations,
          Pattern digitSuffixes: defaultDigitSuffixes,
          Map<int, int> fourDigitOffsets: defaultFourDigitOffsets}) =>
      DateParser(ParsedDate.constantConstructor,
          compactDateFormat: compactDateFormat,
          months: months,
          seasons: seasons,
          seasonToMonth: seasonToMonth,
          digitSuffixes: digitSuffixes,
          fourDigitOffsets: fourDigitOffsets);

  /// Convert a [Pattern] into a [RegExp] by applying the [RegExp] constructor if the [Pattern]
  /// isn't already a [RegExp].
  static RegExp _toRegExp(Pattern p) =>
      p is RegExp ? p : RegExp(p.toString(), caseSensitive: false);

  List<T> parse(String text) {
    if (text == null) return <T>[];
    final List<int> dayParts = [], monthParts = [], yearParts = [];

    // collect parts
    RegExp(r'((?:[\d]+\D){2}[\d]+)|([^\W_]+)').allMatches(text).forEach((RegExpMatch match) {
      if (match.group(1) != null) {
        // Compact format matching ((?:[\d]+\D){2}[\d]+), like `MM/DD/YY`
        final numbers = RegExp(r'(\d+)')
            .allMatches(match.group(1))
            .map((RegExpMatch numMatch) => numMatch.group(1))
            .map(int.tryParse)
            .map((int n) => n ?? 1)
            .toList(growable: false);
        if (numbers[0].toString().length < 4 &&
            numbers[2].toString().length >= 4 &&
            _compactDateFormat == CompactDateFormat.yearFirst) {
          // Found DD/MM/YYYY when format is YY/MM/DD
          dayParts.add(_toDay(numbers[0]));
          monthParts.add(_toMonth(numbers[1]));
          yearParts.add(_toYear(numbers[2]));
        } else if (numbers[0].toString().length >= 4 ||
            _compactDateFormat == CompactDateFormat.yearFirst) {
          // Found YYYY/MM/DD or format is YY/MM/DD
          yearParts.add(_toYear(numbers[0]));
          monthParts.add(_toMonth(numbers[1]));
          dayParts.add(_toDay(numbers[2]));
        } else if (_compactDateFormat == CompactDateFormat.dayFirst) {
          // Format is DD/MM/YY
          dayParts.add(_toDay(numbers[0]));
          monthParts.add(_toMonth(numbers[1]));
          yearParts.add(_toYear(numbers[2]));
        } else if (_compactDateFormat == CompactDateFormat.monthFirst) {
          // Format is MM/DD/YY
          monthParts.add(_toMonth(numbers[0]));
          dayParts.add(_toDay(numbers[1]));
          yearParts.add(_toYear(numbers[2]));
        }
      } else if (match.group(2) != null) {
        // Format format matching ([^\W_]+), like `January` or `2000`
        String part = match.group(2);

        // Add any month matches
        for (int m = 0; m < _months.length; m++)
          if (part.contains(_months[m])) monthParts.add(m + 1);

        // Add any season matches as month matches if allowed to
        if (_seasons.isNotEmpty && _seasonToMonth != null)
          for (int s = 0; s < _seasons.length; s++)
            if (part.contains(_seasons[s]))
              monthParts.add(_seasonToMonth[s + 1] ?? defaultSeasonToMonthApproximations[s + 1]);

        // Try to create a number from the part, use it as a day if it is at most two digits,
        // year otherwise
        int asNumber = int.tryParse(part.replaceAll(_digitSuffixes, ''));
        if (asNumber != null) {
          if (asNumber.toString().length <= 2)
            dayParts.add(_toDay(asNumber));
          else
            yearParts.add(_toYear(asNumber));
        }
      }
    });

    // Iterate through parts and construct T objects from them
    final List<T> ret = <T>[];
    final dayPartIterator = dayParts.where((i) => i != null).iterator;
    final monthPartIterator = monthParts.where((i) => i != null).iterator;
    final yearPartIterator = yearParts.where((i) => i != null).iterator;
    bool moreDays, moreMonths, moreYears;
    int dayCurrent, monthCurrent, yearCurrent;
    do {
      moreDays = dayPartIterator.moveNext();
      moreMonths = monthPartIterator.moveNext();
      moreYears = yearPartIterator.moveNext();
      if (moreDays || moreMonths || moreYears) {
        // If there are more parts to traverse, traverse them
        dayCurrent = dayPartIterator.current ?? dayCurrent;
        monthCurrent = monthPartIterator.current ?? monthCurrent;
        yearCurrent = yearPartIterator.current ?? yearCurrent;
        if (yearCurrent != null && monthCurrent != null && dayCurrent != null)
          // If all three parts aren't null, supply all three
          ret.add(_parsedDateStorage(yearCurrent, monthCurrent, dayCurrent));
        else if (yearCurrent != null && monthCurrent != null)
          // Otherwise, if year and month aren't null, supply those
          ret.add(_parsedDateStorage(yearCurrent, monthCurrent));
        else if (yearCurrent != null)
          // Otherwise, if year isn't null, supply that
          ret.add(_parsedDateStorage(yearCurrent));
      }
    } while (moreDays || moreMonths || moreYears);

    return ret;
  }

  /// Turn [year] into a four digit number if necessary and possible.
  int _toYear(int year) {
    if (year.toString().length < 4 && _fourDigitOffsets.firstKeyAfter(year) != null)
      return year + _fourDigitOffsets[_fourDigitOffsets.firstKeyAfter(year)];
    else
      return year;
  }

  /// Ensure that [month] is no greater than 12.
  int _toMonth(int month) => ((month - 1) % 12) + 1;

  /// Ensure that [day] is no greater than 31.
  int _toDay(int day) => ((day - 1) % 31) + 1;
}
