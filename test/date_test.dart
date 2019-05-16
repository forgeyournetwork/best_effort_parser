import 'dart:math';

import 'package:best_effort_parser/date.dart';
import 'package:test/test.dart';
import 'package:best_effort_parser/src/date/parsed_date.dart';

main() {
  group('NameParser', () {
    group('.parse(String input)', () {
      test('handles compact singular dates', () {
        expect(DateParser.basic().parse('1/1/2000'), equals([ParsedDate(2000, 1, 1)]));
      });
    });
  });

  group('ParsedDate', () {
    group('operator ==', () {
      test('returns false if given a different type', () {
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
        for (int a = 0; a < samples.length; a++)
          for (int b = 0; b < samples.length; b++) expect(samples[a] == samples[b], a == b);
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
