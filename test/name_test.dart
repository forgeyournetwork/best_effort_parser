import 'package:best_effort_parser/name.dart';
import 'package:test/test.dart';

main () {
  group('NameParser', () {
    group('.parse(String input) ', () {
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

      test('rotates the first comma-separated portion to the end', () {
        var result = NameParser.basic().parse('Warren, Jack Ramsey');
        expect(result.given, 'Jack Ramsey');
        expect(result.family, 'Warren');
      });

      // TODO: more testing
    });
  });
}