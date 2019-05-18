import 'package:best_effort_parser/name.dart';
import 'package:best_effort_parser/src/name/parsed_name.dart';
import 'package:test/test.dart';

main() {
  group('NameParser', () {
    group('.parse(String input)', () {
      test('returns in the case of null or empty input', () {
        ['', null].map(NameParser.basic().parse).forEach((result) {
          [
            result.given,
            result.family,
            result.droppingParticle,
            result.nonDroppingParticle,
            result.suffix
          ].forEach((str) => expect(str, isEmpty));
        });
      });

      test('groups first and middle names', () {
        var result = NameParser.basic().parse('Jack Ramsey Warren');
        expect(result.given, 'Jack Ramsey');
        expect(result.family, 'Warren');
        expect(result.droppingParticle, isEmpty);
        expect(result.nonDroppingParticle, isEmpty);
        expect(result.suffix, isEmpty);
      });

      test('groups first and middle initials', () {
        var result = NameParser.basic().parse('J. R. Warren');
        expect(result.given, 'J. R.');
        expect(result.family, 'Warren');
      });

      test('strips out odd whitespace', () {
        var result = NameParser.basic().parse('Jack    Ramsey     Warren');
        expect(result.given, 'Jack Ramsey');
        expect(result.family, 'Warren');
      });

      test('leaves floating punctuation', () {
        var result = NameParser.basic().parse('Jack  -  Ramsey     Warren');
        expect(result.given, 'Jack - Ramsey');
        expect(result.family, 'Warren');
      });

      test(
          'rotates the first comma-separated portion to the end to handle <last>, <first>',
          () {
        var result = NameParser.basic().parse('Warren, Jack Ramsey');
        expect(result.given, 'Jack Ramsey');
        expect(result.family, 'Warren');
      });

      test('handles particles properly', () {
        var result = NameParser.basic().parse('Jean de La Fontaine');
        expect(result.given, 'Jean');
        expect(result.family, 'Fontaine');
        expect(result.droppingParticle, 'de');
        expect(result.nonDroppingParticle, 'La');
        expect(result.suffix, isEmpty);
      });

      test('handles particles properly with full <last>, <first> ordering', () {
        var result = NameParser.basic().parse('de La Fontaine, Jean');
        expect(result.given, 'Jean');
        expect(result.family, 'Fontaine');
        expect(result.droppingParticle, 'de');
        expect(result.nonDroppingParticle, 'La');
        expect(result.suffix, isEmpty);
      });

      test('handles particles properly with partial <last>, <first> ordering',
          () {
        var result = NameParser.basic().parse('La Fontaine, Jean de');
        expect(result.given, 'Jean');
        expect(result.family, 'Fontaine');
        expect(result.droppingParticle, 'de');
        expect(result.nonDroppingParticle, 'La');
        expect(result.suffix, isEmpty);
      });

      test('handles particles properly with partial <last>, <first> ordering',
          () {
        var result = NameParser.basic().parse('La Fontaine, Jean de');
        expect(result.given, 'Jean');
        expect(result.family, 'Fontaine');
        expect(result.droppingParticle, 'de');
        expect(result.nonDroppingParticle, 'La');
        expect(result.suffix, isEmpty);
      });

      test(
          'handles particles properly with partial <last>, <first> ordering with an odd comma',
          () {
        var result = NameParser.basic().parse('La Fontaine, Jean, de');
        expect(result.given, 'Jean');
        expect(result.family, 'Fontaine');
        expect(result.droppingParticle, 'de');
        expect(result.nonDroppingParticle, 'La');
        expect(result.suffix, isEmpty);
      });

      test('handles particles properly with minimal <last>, <first> ordering',
          () {
        var result = NameParser.basic().parse('Fontaine, Jean de La');
        expect(result.given, 'Jean');
        expect(result.family, 'Fontaine');
        expect(result.droppingParticle, 'de');
        expect(result.nonDroppingParticle, 'La');
        expect(result.suffix, isEmpty);
      });

      test('handles lowercase particles as dropping', () {
        var result = NameParser.basic().parse('Willem de Kooning');
        expect(result.given, 'Willem');
        expect(result.family, 'Kooning');
        expect(result.droppingParticle, 'de');
        expect(result.nonDroppingParticle, isEmpty);
      });

      test('handles lowercase particles as dropping in <last>, <first>', () {
        var result = NameParser.basic().parse('de Kooning, Willem');
        expect(result.given, 'Willem');
        expect(result.family, 'Kooning');
        expect(result.droppingParticle, 'de');
        expect(result.nonDroppingParticle, isEmpty);
      });

      test('handles uppercase particles as non-dropping', () {
        var result = NameParser.basic().parse('Willem De Kooning');
        expect(result.given, 'Willem');
        expect(result.family, 'Kooning');
        expect(result.droppingParticle, isEmpty);
        expect(result.nonDroppingParticle, 'De');
      });

      test('handles uppercase particles as non-dropping in <last>, <first>',
          () {
        var result = NameParser.basic().parse('De Kooning, Willem');
        expect(result.given, 'Willem');
        expect(result.family, 'Kooning');
        expect(result.droppingParticle, isEmpty);
        expect(result.nonDroppingParticle, 'De');
      });

      test('handles suffixes', () {
        var result = NameParser.basic().parse('Elizabeth Alexandra Mary II');
        expect(result.given, 'Elizabeth Alexandra');
        expect(result.family, 'Mary');
        expect(result.suffix, 'II');
      });

      test('handles suffixes when comma-separated', () {
        var result = NameParser.basic().parse('Elizabeth Alexandra Mary, II');
        expect(result.given, 'Elizabeth Alexandra');
        expect(result.family, 'Mary');
        expect(result.suffix, 'II');
      });

      test('handles suffixes in <last>, <first> when the suffix follows last',
          () {
        var result = NameParser.basic().parse('Mary II, Elizabeth Alexandra');
        expect(result.given, 'Elizabeth Alexandra');
        expect(result.family, 'Mary');
        expect(result.suffix, 'II');
      });

      test(
          'handles suffixes in <last>, <first> when the suffix follows last with a comma',
          () {
        var result = NameParser.basic().parse('Mary, II, Elizabeth Alexandra');
        expect(result.given, 'Elizabeth Alexandra');
        expect(result.family, 'Mary');
        expect(result.suffix, 'II');
      });

      test('handles suffixes in <last>, <first> when the suffix is at the end',
          () {
        var result = NameParser.basic().parse('Mary, Elizabeth Alexandra II');
        expect(result.given, 'Elizabeth Alexandra');
        expect(result.family, 'Mary');
        expect(result.suffix, 'II');
      });

      test(
          'handles suffixes in <last>, <first> when the suffix is at the end with a comma',
          () {
        var result = NameParser.basic().parse('Mary, Elizabeth Alexandra, II');
        expect(result.given, 'Elizabeth Alexandra');
        expect(result.family, 'Mary');
        expect(result.suffix, 'II');
      });

      test(
          'handles all-caps names as expected, with particles being non-dropping',
          () {
        var result = NameParser.basic().parse('WILLEM DE KOONING');
        expect(result.given, 'WILLEM');
        expect(result.family, 'KOONING');
        expect(result.nonDroppingParticle, 'DE');
      });

      test('handles multiple of different parts', () {
        final target = ParsedName('family1 family2',
            given: 'given1 given2',
            droppingParticle: 'de van',
            nonDroppingParticle: 'Di La',
            suffix: 'Jr. III PhD.');
        final parser = NameParser.basic();
        final samples = <String>[
          'given1 given2 de van Di La family1 family2 Jr. III PhD.',
          'given1 given2 de Di van La family1 family2 Jr. III PhD.',
          'given1 given2 de van Di La family1 family2, Jr. III PhD.',
          'given1 given2 de van Di La family1 family2 Jr., III PhD.',
          'given1 given2 de van Di La family1 family2, Jr. III, PhD.',
          'family1 family2 Jr. III PhD., given1 given2 de van Di La',
          'family1 family2, Jr. III PhD., given1 given2 de van Di La',
          'family1 family2, Jr., III PhD., given1, given2, de van, Di La',
          'family1 family2 Jr., given1 given2 de van Di La III PhD.',
          'Di La family1 family2, given1 given2 de van, Jr. III PhD.',
          'de van Di La family1 family2, given1 given2, Jr. III PhD.',
          'Di La de van family1 family2, given1, given2 Jr. III PhD.',
        ].map(parser.parse);
        expect(samples, everyElement(equals(target)));
      });

      test('puts suffixes as the family if that\'s all we have', () {
        expect(NameParser.basic().parse('I II III').family, 'I II III');
      });
    });
  });

  group('ParsedName', () {
    group('operator ==', () {
      test('returns false on different types', () {
        // ignore: unrelated_type_equality_checks
        expect(ParsedName('foo') == 5, isFalse);
      });

      test('returns false if fields are different, true if same', () {
        final samples = [
          ParsedName('abc'),
          ParsedName('', given: 'abc'),
          ParsedName('', droppingParticle: 'abc'),
          ParsedName('', nonDroppingParticle: 'abc'),
          ParsedName('', suffix: 'abc')
        ];
        for (int a = 0; a < 5; a++) {
          for (int b = 0; b < 5; b++) {
            expect(samples[a] == samples[b], a == b);
          }
        }
      });
    });

    group('toString()', () {
      test('uses space separation by default', () {
        var result = NameParser.basic().parse('Jack Warren');
        expect(result.toString(), 'Jack Warren');
      });

      test('can use a custom separator', () {
        var result = NameParser.basic().parse('Jack Warren');
        expect(result.toString(separator: '.'), 'Jack.Warren');
      });
    });

    group('diagonisticString()', () {
      test('fills its default parameters', () {
        var result = NameParser.basic()
            .parse('given1 given2 de van Di La family1 family2 Jr. III PhD.');
        expect(
            result.diagnosticString(),
            '[Given]: given1 given2 [Dropping Particle]: de van [Non-dropping Particle]: Di La '
            '[Family]: family1 family2 [Suffix]: Jr. III PhD.');
      });

      test('can have customized labels/separators', () {
        var result = NameParser.basic()
            .parse('given1 given2 de van Di La family1 family2 Jr. III PhD.');
        expect(
            result.diagnosticString(
                separator: '-',
                givenLabel: '',
                droppingParticleLabel: '',
                nonDroppingParticleLabel: '',
                familyLabel: '',
                suffixLabel: ''),
            result.toString(separator: '-'));
      });
    });
  });
}
