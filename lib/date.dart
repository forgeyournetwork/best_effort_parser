import 'dart:collection';

import 'src/date/date_part.dart';
import 'src/date/parsed_date.dart';
import 'src/date/detected_date.dart';

/// Type of function used to produce output from [DateParser]'s [parse] method.
///
/// [DateParser]'s usage of this function is guaranteed to never pass null to any of the parameters.
typedef DateParserOutput<T> = T Function(int year, [int month, int day]);

/// Enumeration of date formats understood by [DateParser], one of which may be
/// set during construction to specify how ambiguous dates should be parsed.
///
/// - [dayFirst]: assume day/month/year, but fall back to [yearFirst] if the year is obviously
/// first (i.e. DDDD/MM/YY becomes YYYY/MM/DD).
/// - [monthFirst]: assume month/day/year, but fall back to [yearFirst] if the year is obviously
/// first (i.e. MMMM/DD/YY becomes YYYY/MM/DD).
/// - [yearFirst]: assume year/month/day, but fall back to [dayFirst] if the year is obviously
/// last (i.e. YY/MM/DDDD becomes DD/MM/YYYY).
///
/// It should be noted that some dates are plainly unambiguous, and the date
/// format set here has no effect. Specifically, suppose 40-20-10: even
/// though year-day-month isn't a correct date format anywhere in the world,
/// it is obvious that 40 must represent a 2-digit year, 20 may only
/// represent a day, and 10 may only represent a month.
///
/// In other words, month must be 0<m<=12, and if there is number 12<d<=31
/// and another number 31<y, the parser can disambiguate which number is
/// mapped to what date part.
enum CompactDateFormat { dayFirst, monthFirst, yearFirst }

/// A parser designed to extract dates from an arbitrary string. The [parse] method will create a
/// list of [T] objects containing each date found.
///
/// Customization may be done during construction to target specific locales: detection of
/// written-out months and seasons, stripping of ordinal suffixes, two-to-four-digit year
/// conversions, season-to-month approximations, and of course compact date formats may all be
/// tweaked. Those constructor parameters are optional; the defaults are suitable for en-US.
///
/// Parsing takes place in two stages, **collection** and **assembly**.
///
/// **Collection** parses the string into a list of days, months, and years. These lists need not
/// be the same length and they may even be empty at the end of parsing; that is handled by the
/// assembly stage.
///
/// For example, with the [basic] settings, "1/5/10" would contribute 1 as a month, 5 as a day,
/// and 2010 as a year. "January" would contribute 1 as a month, "20" or "20th" would both
/// contribute 20 as a day, and "2010-2015" would contribute 2010 and 2015 as years. Because
/// [basic] settings include season-to-month translation, "spring" would contribute 3 as a month.
/// See [CompactDateFormat], [defaultSeasons], [defaultMonths],
/// [defaultDigitSuffixes], [defaultFourDigitOffsets], and
/// [defaultSeasonToMonthApproximations] for more information on [basic]
/// settings (and customizing them).
///
/// **Assembly** turns those days, months, and years into [T] objects. Each list is iterated over
/// in tandem: if any list has more terms, an iteration occurs and a [T] is made from the most
/// recent values from each list. If a list was always empty, the most recent value from that list
/// will always be null, so the [T] will be truncated if possible.
///
/// For example, "March 2nd, 2000" has a single [T] created, but "March 2nd, 2000 to July 1st,
/// 2001" would have two [T] created. "March 2nd, 2000 to 2005" would have two [T] created: one
/// representing 2 March 2000 and the other being 2 March 2005 (when the second iteration occurs,
/// the most recent day and month are still the ones from the previous iteration, so they are
/// used again). An example of the truncation described above is "January - March 2010", which
/// creates two [T] objects, neither having a day set. Truncation only occurs of less significant
/// terms, so "5-10 Sep" would result in no [T] objects since no year was present.
class DateParser<T> {
  /// Default comprehension of seasons, for American English.
  ///
  /// If customized, the length of this default's replacement should generally match the size of
  /// [defaultSeasonToMonthApproximations] (or its replacement). [parse]'s relevant behavior is as
  /// follows (replacements provided during construction will be substituted automatically):
  ///
  /// 1. When evaluating a part of a string ("foo" in "foo-bar" or "spring" in "spring 2020"), it
  /// will be checked against [RegExp]s created from the strings in this list.
  /// 2. If the part matches, the *1-index* of the string from this list will be used as a key to
  /// lookup in [defaultSeasonToMonthApproximations].
  /// 3. The value for that key in [defaultSeasonToMonthApproximations] will be added as a month.
  ///
  /// For example, with the defaults, "spring" matches only the first string in
  /// [defaultSeasons], so its 1-index of `1` will be used as a key to look in
  /// [defaultSeasonToMonthApproximations]. `1`'s value is `3` (since spring begins in March), so
  /// 3 will be recorded as the month.
  static const List<String> defaultSeasons = [
    r'spring',
    r'summer',
    r'fall|autumn',
    r'winter',
  ];

  /// Default comprehension of months, for American English.
  ///
  /// [parse]'s relevant behavior is as follows (replacements provided during construction will
  /// be substituted automatically):
  ///
  /// 1. When evaluating a part of a string ("foo" in "foo-bar" or "july" in "2 july 2020"), it
  /// will be checked against [RegExp]s created from the strings in this list.
  /// 2. If the part matches, the *1-index* of the string from this list will be added as a month.
  ///
  /// For example, with the defaults "September" matches the ninth string in [defaultMonths], so
  /// its 1-index of 9 will be recorded as the month.
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

  /// Default ordinal suffixes to strip from numbers before parsing, for American English.
  ///
  /// [parse]'s relevant behavior is as follows (replacements provided during construction will
  /// be substituted automatically):
  ///
  /// 1. When evaluating a part of a string ("foo" in "foo-bar" or "2nd" in "July 2nd 2020"), it
  /// will have all matches of a [RegExp] created from this string removed.
  /// 2. The part is then attempted to be parsed to an integer. If unsuccessful, the below step
  /// is skipped.
  /// 3. If the integer has less than four digits, it is stored as a day. If the integer has at
  /// least four digits, it is stored as a year.
  ///
  /// For example, with the defaults "2nd" has "nd" stripped, becoming "2". That is parsed to an
  /// integer, and having only one digit it is stored as a day.
  static const String defaultDigitSuffixes = r'st|nd|rd|th';

  /// Default offsets to apply to years under a certain threshold, where years in the range `[0,
  /// 30)` have 2000 added to them while years in the range `[30, 100)` have 1900 added to them.
  ///
  /// [parse]'s relevant behavior is as follows (replacements provided during construction will
  /// be substituted automatically:
  ///
  /// 1. When adding a year from a compact format ("1920/5/6" or "3/2/10"), if the year is less
  /// than four digits (and no fall-back behavior from [CompactDateFormat] was executed) and a
  /// non-null key exists after the year in this mapping, add its value to the year before
  /// storing it.
  ///
  /// For example, with the defaults "1/2/3"'s year of "3" is less than 30 and so has 2000 added
  /// to it, resulting in 2003 being recorded as the year.
  static const Map<int, int> defaultFourDigitOffsets = {
    30: 2000, // For years less than 30, add 2000
    100: 1900, // For years at least 30 but less than 100, add 1900
  };

  /// Default mapping of seasons (given by their 1-indexed order) to the value to be recorded as
  /// the month, where seasons are mapped to the month in which they begin.
  ///
  /// Customization and [parse]'s relevant behavior are discussed in the documentation for
  /// [defaultSeasons].
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
  DateParserOutput<T> _dateParserOutput;

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
  ///
  /// [Pattern]s accepted as input to this function will be made to all be [RegExp]s: [Pattern]'s
  /// implementations are [String] and [RegExp], so any [String]s will be passed to the [RegExp]
  /// constructor and any [RegExp]s will be left as is.
  DateParser(DateParserOutput<T> dateParserOutput,
      {CompactDateFormat compactDateFormat = CompactDateFormat.monthFirst,
      List<Pattern> months = defaultMonths,
      List<Pattern> seasons = defaultSeasons,
      Map<int, int> seasonToMonth = defaultSeasonToMonthApproximations,
      Pattern digitSuffixes = defaultDigitSuffixes,
      Map<int, int> fourDigitOffsets = defaultFourDigitOffsets}) {
    _dateParserOutput = dateParserOutput;
    _compactDateFormat = compactDateFormat;
    _months = months.map(_toRegExp).toList();
    _seasons = (seasons != null ? seasons : <String>[]).map(_toRegExp).toList();
    _digitSuffixes = _toRegExp(digitSuffixes ?? '');
    _fourDigitOffsets = SplayTreeMap.of(fourDigitOffsets ?? {});
    _seasonToMonth = seasonToMonth;
  }

  /// Behaves the same as the constructor for [DateParser] except that the output format is
  /// specified to be [ParsedDate].
  ///
  /// [ParsedDate] is an immutable value class with accessors for the year, month, and day and
  /// methods to transform it into a diagnostic string or [DateTime] object.
  static DateParser<ParsedDate> basic(
          {CompactDateFormat compactDateFormat = CompactDateFormat.monthFirst,
          List<Pattern> months = defaultMonths,
          List<Pattern> seasons = defaultSeasons,
          Map<int, int> seasonToMonth = defaultSeasonToMonthApproximations,
          Pattern digitSuffixes = defaultDigitSuffixes,
          Map<int, int> fourDigitOffsets = defaultFourDigitOffsets}) =>
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

  /// [parse] the given [text] into a list of [T] objects, one for each date found.
  ///
  /// If the [text] is empty, null, or doesn't contain a parsable date, the output list will be
  /// empty. This function will never return null.
  List<DetectedDate> parse(String text) {
    if (text == null) return [];
    final List<DatePart> dayParts = [], monthParts = [], yearParts = [];

    // collect parts
    RegExp(r'((?:[\d]+\D){2}[\d]+)|([^\W_]+)')
        .allMatches(text)
        .forEach((Match match) {
      if (match.group(1) != null) {
        // Compact format matching ((?:[\d]+\D){2}[\d]+), like `MM/DD/YY`
        final numbers = RegExp(r'(\d+)')
            .allMatches(match.group(1))
            .map((Match numMatch) => numMatch.group(1))
            .map(int.tryParse)
            .map((int n) => n ?? 1)
            .toList(growable: false);

        // check if we have {y>31, 31>=d>12, 12>=m>0}, because then we don't
        // need to worry about the date format
        final numbersOrdered = List.of(numbers)..sort();
        if (12 >= numbersOrdered[0] &&
            numbersOrdered[1] > 12 &&
            31 >= numbersOrdered[1] &&
            numbersOrdered[2] > 31) {
          monthParts.add(
            DatePart(
              _toMonth(numbersOrdered[0]),
              numbersOrdered[0].toString(),
            ),
          );
          dayParts.add(
            DatePart(
              _toDay(numbersOrdered[1]),
              numbersOrdered[1].toString(),
            ),
          );
          yearParts.add(
            DatePart(
              _toYear(numbersOrdered[2]),
              numbersOrdered[2].toString(),
            ),
          );
          return;
        }

        // parse parsed on quantity of digits and the date format
        if (numbers[0].toString().length <= 2 &&
            numbers[1].toString().length <= 2 &&
            numbers[2].toString().length >= 4 &&
            _compactDateFormat == CompactDateFormat.yearFirst) {
          // Found DD/MM/YYYY when format is YY/MM/DD
          dayParts.add(
            DatePart(
              _toDay(numbers[0]),
              numbers[0].toString(),
            ),
          );
          monthParts.add(
            DatePart(
              _toMonth(numbers[1]),
              numbers[1].toString(),
            ),
          );
          yearParts.add(
            DatePart(
              _toYear(numbers[2]),
              numbers[2].toString(),
            ),
          );
        } else if ((numbers[0].toString().length >= 4 &&
                numbers[1].toString().length <= 2 &&
                numbers[2].toString().length <= 2) ||
            _compactDateFormat == CompactDateFormat.yearFirst) {
          // Found YYYY/MM/DD or format is YY/MM/DD
          yearParts.add(
            DatePart(
              _toYear(numbers[0]),
              numbers[0].toString(),
            ),
          );
          monthParts.add(
            DatePart(
              _toMonth(numbers[1]),
              numbers[1].toString(),
            ),
          );
          dayParts.add(
            DatePart(
              _toDay(numbers[2]),
              numbers[2].toString(),
            ),
          );
        } else if (_compactDateFormat == CompactDateFormat.dayFirst) {
          // Format is DD/MM/YY
          dayParts.add(
            DatePart(
              _toDay(numbers[0]),
              numbers[0].toString(),
            ),
          );
          monthParts.add(
            DatePart(
              _toMonth(numbers[1]),
              numbers[1].toString(),
            ),
          );
          yearParts.add(
            DatePart(
              _toYear(numbers[2]),
              numbers[2].toString(),
            ),
          );
        } else if (_compactDateFormat == CompactDateFormat.monthFirst) {
          // Format is MM/DD/YY
          monthParts.add(
            DatePart(
              _toMonth(numbers[0]),
              numbers[0].toString(),
            ),
          );
          dayParts.add(
            DatePart(
              _toDay(numbers[1]),
              numbers[1].toString(),
            ),
          );
          yearParts.add(
            DatePart(
              _toYear(numbers[2]),
              numbers[2].toString(),
            ),
          );
        }
      } else if (match.group(2) != null) {
        // Format format matching ([^\W_]+), like `January` or `2000`
        String part = match.group(2);

        // Add any month matches
        for (int m = 0; m < _months.length; m++) {
          if (part.contains(_months[m])) {
            monthParts.add(
              DatePart(
                m + 1,
                part,
              ),
            );
          }
        }

        // Add any season matches as month matches if allowed to
        if (_seasons.isNotEmpty && _seasonToMonth != null) {
          for (int s = 0; s < _seasons.length; s++) {
            if (part.contains(_seasons[s])) {
              monthParts.add(
                DatePart(
                  _seasonToMonth[s + 1] ??
                      defaultSeasonToMonthApproximations[s + 1],
                  part,
                ),
              );
            }
          }
        }

        // Try to create a number from the part, use it as a day if it is at most two digits,
        // year otherwise
        int asNumber = int.tryParse(part.replaceAll(_digitSuffixes, ''));
        if (asNumber != null) {
          var indexOfPart = match.start - 1 > 0 ? match.start - 1 : 0;
          if (asNumber.toString().length <= 2 &&
              !['\'', '‘'].contains(text[indexOfPart])) {
            dayParts.add(
              DatePart(
                _toDay(asNumber),
                part,
              ),
            );
          } else {
            yearParts.add(
              DatePart(
                _toYear(asNumber),
                part,
              ),
            );
          }
        }
      }
    });

    // Iterate through parts and construct T objects from them
    final List<DetectedDate> ret = [];
    final dayPartIterator = dayParts.where((i) => i != null).iterator;
    final monthPartIterator = monthParts.where((i) => i != null).iterator;
    final yearPartIterator = yearParts.where((i) => i != null).iterator;
    bool moreDays, moreMonths, moreYears;
    DatePart dayCurrent, monthCurrent, yearCurrent;
    do {
      moreDays = dayPartIterator.moveNext();
      moreMonths = monthPartIterator.moveNext();
      moreYears = yearPartIterator.moveNext();
      if (moreDays || moreMonths || moreYears) {
        // If there are more parts to traverse, traverse them
        dayCurrent = dayPartIterator.current ?? dayCurrent;
        monthCurrent = monthPartIterator.current ?? monthCurrent;
        yearCurrent = yearPartIterator.current ?? yearCurrent;
        if (yearCurrent != null && monthCurrent != null && dayCurrent != null) {
          // If all three parts aren't null, supply all three
          ret.add(DetectedDate(
            _dateParserOutput(
              yearCurrent.value,
              monthCurrent.value,
              dayCurrent.value,
            ),
            [
              yearCurrent.text,
              monthCurrent.text,
              dayCurrent.text,
            ],
          ));
        } else if (yearCurrent != null && monthCurrent != null) {
          // Otherwise, if year and month aren't null, supply those
          ret.add(DetectedDate(
            _dateParserOutput(yearCurrent.value, monthCurrent.value),
            [
              yearCurrent.text,
              monthCurrent.text,
            ],
          ));
        } else if (yearCurrent != null) {
          // Otherwise, if year isn't null, supply that
          ret.add(DetectedDate(
            _dateParserOutput(yearCurrent.value),
            [
              yearCurrent.text,
            ],
          ));
        }
      }
    } while (moreDays || moreMonths || moreYears);

    var textDates = {
      'today': 0,
      'tomorrow': 1,
      'yesterday': -1,
    };

    var weekTextDates = {
      'sunday': DateTime.sunday,
      'monday': DateTime.monday,
      'tuesday': DateTime.tuesday,
      'wednesday': DateTime.wednesday,
      'thursday': DateTime.thursday,
      'friday': DateTime.friday,
      'saturday': DateTime.saturday,
    };

    for (var textDateKey in textDates.keys) {
      if (text.contains(RegExp(textDateKey, caseSensitive: false))) {
        var now = DateTime.now();
        ret.add(DetectedDate(
          DateTime(now.year, now.month, now.day)
              .add(Duration(days: textDates[textDateKey])),
          [textDateKey],
        ));
      }
    }

    for (var weekTextDateKey in weekTextDates.keys) {
      var triggerText = 'last $weekTextDateKey';
      if (text.contains(RegExp(triggerText, caseSensitive: false))) {
        var now = DateTime.now();
        var weekday = now.weekday;

        // Calculate the difference between the current weekday and weekTextDate
        var daysUntilLastWeekTextDate =
            (weekday - weekTextDates[weekTextDateKey]) % 7;

        ret.add(DetectedDate(
          // Subtract the difference to get the date of the last weekTextDate
          now.subtract(Duration(days: daysUntilLastWeekTextDate)),
          [triggerText],
        ));
      }

      triggerText = 'next $weekTextDateKey';
      if (text.contains(RegExp(triggerText, caseSensitive: false))) {
        var now = DateTime.now();
        var weekday = now.weekday;

        // Calculate the number of days until the next weekTextDate
        var daysUntilNextWeekTextDate =
            weekTextDates[weekTextDateKey] - weekday + 7;

        ret.add(DetectedDate(
          // Add the days to the current date to get the date of the next weekTextDate
          now.add(Duration(days: daysUntilNextWeekTextDate)),
          [triggerText],
        ));
      }
    }

    return ret;
  }

  /// Turn [year] into a four digit number if necessary and possible.
  int _toYear(int year) {
    if (year.toString().length < 4 &&
        _fourDigitOffsets.firstKeyAfter(year) != null) {
      return year + _fourDigitOffsets[_fourDigitOffsets.firstKeyAfter(year)];
    } else {
      return year;
    }
  }

  /// Ensure that [month] is no greater than 12.
  int _toMonth(int month) => ((month - 1) % 12) + 1;

  /// Ensure that [day] is no greater than 31.
  int _toDay(int day) => ((day - 1) % 31) + 1;
}
