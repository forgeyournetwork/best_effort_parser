import 'dart:math';

import 'package:best_effort_parser/date.dart';
import 'package:test/test.dart';
import 'package:best_effort_parser/src/date/parsed_date.dart';

main() {
  group('NameParser', () {
    group('.parse(String input)', () {
      test('handles singular compact dates with default settings', () {
        expect(DateParser.basic().parse('1/2/2000'), equals([ParsedDate(2000, 1, 2)]));
        expect(DateParser.basic().parse('12/31/1999'), equals([ParsedDate(1999, 12, 31)]));
      });

      test('handles multiple compact dates with the default settings', () {
        expect(DateParser.basic().parse('10-30-2010 - 11-15-2010'),
            equals([ParsedDate(2010, 10, 30), ParsedDate(2010, 11, 15)]));
        expect(DateParser.basic().parse('1/3/1803-2/4/2020-10/3/2400'),
            equals([ParsedDate(1803, 1, 3), ParsedDate(2020, 2, 4), ParsedDate(2400, 10, 3)]));
      });

      test('handles singular normal dates', () {
        expect(DateParser.basic().parse('2 January 2010'), equals([ParsedDate(2010, 1, 2)]));
        expect(DateParser.basic().parse('Jul 2nd, 2005'), equals([ParsedDate(2005, 7, 2)]));
      });

      test('handles multiple normal dates', () {
        expect(DateParser.basic().parse('2-3 January 2010'),
            equals([ParsedDate(2010, 1, 2), ParsedDate(2010, 1, 3)]));
        expect(DateParser.basic().parse('10 June to 15 July, 1999'),
            equals([ParsedDate(1999, 6, 10), ParsedDate(1999, 7, 15)]));
        expect(DateParser.basic().parse('October 1st, 2010-2015'),
            equals([ParsedDate(2010, 10, 1), ParsedDate(2015, 10, 1)]));
        expect(
            DateParser.basic().parse('From the 1st of January, 1999, to the 2nd of March, 2000, '
                'until some time in 2001'),
            equals([ParsedDate(1999, 1, 1), ParsedDate(2000, 3, 2), ParsedDate(2001, 3, 2)]));
      });

      test('creates output using as much info as it has', () {
        expect(DateParser.basic().parse('2010'), equals([ParsedDate(2010)]));
        expect(DateParser.basic().parse('1900-2000'), equals([ParsedDate(1900), ParsedDate(2000)]));
        expect(DateParser.basic().parse('January 2010'), equals([ParsedDate(2010, 1)]));
        expect(DateParser.basic().parse('October to December, 2019'),
            equals([ParsedDate(2019, 10), ParsedDate(2019, 12)]));
      });

      test('has default handling of seasons', () {
        expect(DateParser.basic().parse('Spring 2000'), equals([ParsedDate(2000, 3)]));
        expect(DateParser.basic().parse('Summer 2000'), equals([ParsedDate(2000, 6)]));
        expect(DateParser.basic().parse('Fall 2000'), equals([ParsedDate(2000, 9)]));
        expect(DateParser.basic().parse('Winter 2000'), equals([ParsedDate(2000, 12)]));
      });

      test('returns an empty list if the input is null or empty', () {
        expect(DateParser.basic().parse(null), equals(<ParsedDate>[]));
        expect(DateParser.basic().parse(''), equals(<ParsedDate>[]));
      });

      test('returns an empty list if the input cannot be parsed', () {
        final samples = ['garbage', 'january', '10', 'summer 10'];
        expect(
            samples.map((s) => DateParser.basic().parse(s)), everyElement(equals(<ParsedDate>[])));
      });

      test('adds and removes digits as needed to standardize the numerical representation', () {
        expect(DateParser.basic().parse('0001/00002/90'), equals([ParsedDate(1990, 1, 2)]));
        expect(DateParser.basic().parse('0002-0003 January 2019'),
            equals([ParsedDate(2019, 1, 2), ParsedDate(2019, 1, 3)]));
        expect(DateParser.basic().parse('1/1/1 to 10/10/10 to 11/11/11'),
            equals([ParsedDate(2001, 1, 1), ParsedDate(2010, 10, 10), ParsedDate(2011, 11, 11)]));
      });

      test('can have customized month parsing', () {
        final List<String> customMonths = List.from(DateParser.defaultMonths);
        customMonths[0] = 'foo';
        expect(DateParser.basic(months: customMonths).parse('foo 2020'),
            equals([ParsedDate(2020, 1)]));
      });

      test('can have customized season parsing', () {
        final List<String> customSeasons = List.from(DateParser.defaultSeasons);
        customSeasons[0] = 'foo';
        expect(DateParser.basic(seasons: customSeasons).parse('foo 2020'),
            equals([ParsedDate(2020, 3)]));
      });

      test('can have custom assignment of seasons to months', () {
        final Map<int, int> customSeasonToMonth =
            Map.from(DateParser.defaultSeasonToMonthApproximations);
        customSeasonToMonth[1] = 21;
        expect(DateParser.basic(seasonToMonth: customSeasonToMonth).parse('spring 2020'),
            equals([ParsedDate(2020, 21)]));
      });

      test('ignores seasons if it cannot translate them', () {
        expect(DateParser.basic(seasons: null).parse('spring 2019').first.month, isNull);
      });

      test('ignores seasons if it cannot encode them as months', () {
        expect(DateParser.basic(seasonToMonth: null).parse('spring 2019').first.month, isNull);
      });

      test('can have custom digit suffixes', () {
        expect(DateParser.basic(digitSuffixes: 'foo').parse('1foo january 2000'),
            equals([ParsedDate(2000, 1, 1)]));
      });

      test('can ignore digit suffixes by setting the pattern to null', () {
        expect(DateParser.basic(digitSuffixes: null).parse('1st jan 2000').first.day, isNull);
      });

      test('can have custom expansion of years to four digits', () {
        final Map<int, int> customToFourDigits = {50: 2000, 100: 1900};
        expect(DateParser.basic(fourDigitOffsets: customToFourDigits).parse('10/15/45').first.year,
            equals(2045));
      });

      test(
          'can have expansion of years to four digits disabled by setting the parameter to '
          'null', () {
        expect(DateParser.basic(fourDigitOffsets: null).parse('10/15/45').first.year, equals(45));
      });

      test('can interpret compact dates as being day-first', () {
        expect(DateParser.basic(compactDateFormat: CompactDateFormat.dayFirst).parse('11/12/13'),
            equals([ParsedDate(2013, 12, 11)]));
      });

      test('can interpret compact dates as being year-first', () {
        expect(DateParser.basic(compactDateFormat: CompactDateFormat.yearFirst).parse('11/12/13'),
            equals([ParsedDate(2011, 12, 13)]));
      });

      test('overrides year-first if the year is obviously last', () {
        expect(DateParser.basic(compactDateFormat: CompactDateFormat.yearFirst).parse('11/12/2013'),
            equals([ParsedDate(2013, 12, 11)]));
      });

      test('overrides day/month-first if the year is obviously first', () {
        expect(DateParser.basic().parse('2011/12/13'), equals([ParsedDate(2011, 12, 13)]));
        expect(DateParser.basic(compactDateFormat: CompactDateFormat.dayFirst).parse('2011/12/13'),
            equals([ParsedDate(2011, 12, 13)]));
      });

      test('makes sure the day isn\'t above 31', () {
        expect(DateParser.basic().parse('5,46,2000').first.day, equals(15));
      });

      test('makes sure the month isn\'t above 12', () {
        expect(DateParser.basic().parse('18-5-20').first.month, equals(6));
      });

      test('can output in custom formats', () {
        DateParserOutput<int> customOutput = (int year, [int month, int day]) => year;
        expect(DateParser(customOutput).parse('March 2004'), equals([2004]));
      });
    });
  });

  group('ParsedDate', () {
    group('operator ==', () {
      test('returns false if given a different type', () {
        // ignore: unrelated_type_equality_checks
        expect(ParsedDate(2000) == 5, false);
      });

      test('correctly evaluates fields', () {
        final samples = [
          ParsedDate(2000),
          ParsedDate(1000),
          ParsedDate(2000, 10),
          ParsedDate(2000, 5),
          ParsedDate(2000, 10, 10),
          ParsedDate(2000, 10, 5)
        ];
        for (int a = 0; a < samples.length; a++) {
          for (int b = 0; b < samples.length; b++) {
            expect(samples[a] == samples[b], a == b);
          }
        }
      });
    });

    group('toDateTime', () {
      test('creates the expected DateTime', () {
        final r = Random();
        for (int i = 0; i < 3; i++) {
          int y = r.nextInt(2500), m = r.nextInt(12), d = r.nextInt(28);
          expect(ParsedDate(y).toDateTime(), DateTime(y));
          expect(ParsedDate(y, m).toDateTime(), DateTime(y, m));
          expect(ParsedDate(y, m, d).toDateTime(), DateTime(y, m, d));
        }
      });
    });

    group('toString', () {
      test('is the same as diagnosticString', () {
        final r = Random();
        for (int i = 0; i < 3; i++) {
          var result = ParsedDate(r.nextInt(2500), r.nextInt(12), r.nextInt(28));
          expect(result.toString(), result.diagnosticString());
        }
      });
    });

    group('diagnosticString', () {
      test('only includes values when it should', () {
        expect(ParsedDate(2000).diagnosticString(), '[Year]: 2000');
        expect(ParsedDate(2000, 10).diagnosticString(), '[Month]: 10 [Year]: 2000');
        expect(ParsedDate(2000, 10, 10).diagnosticString(), '[Day]: 10 [Month]: 10 [Year]: 2000');
      });

      test('works with optional parameters', () {
        expect(
            ParsedDate(1, 1, 1)
                .diagnosticString(separator: '', dayLabel: '', monthLabel: '.', yearLabel: '.'),
            '1.1.1');
      });
    });
  });
}
