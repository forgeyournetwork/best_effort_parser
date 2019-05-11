import 'package:best_effort_parser/name.dart';
import 'package:test/test.dart';

main() {
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

      test('rotates the first comma-separated portion to the end to handle <last>, <first>', () {
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

      test('handles particles properly with partial <last>, <first> ordering', () {
        var result = NameParser.basic().parse('La Fontaine, Jean de');
        expect(result.given, 'Jean');
        expect(result.family, 'Fontaine');
        expect(result.droppingParticle, 'de');
        expect(result.nonDroppingParticle, 'La');
        expect(result.suffix, isEmpty);
      });

      test('handles particles properly with partial <last>, <first> ordering', () {
        var result = NameParser.basic().parse('La Fontaine, Jean de');
        expect(result.given, 'Jean');
        expect(result.family, 'Fontaine');
        expect(result.droppingParticle, 'de');
        expect(result.nonDroppingParticle, 'La');
        expect(result.suffix, isEmpty);
      });

      test('handles particles properly with partial <last>, <first> ordering with an odd comma',
          () {
        var result = NameParser.basic().parse('La Fontaine, Jean, de');
        expect(result.given, 'Jean');
        expect(result.family, 'Fontaine');
        expect(result.droppingParticle, 'de');
        expect(result.nonDroppingParticle, 'La');
        expect(result.suffix, isEmpty);
      });

      test('handles particles properly with minimal <last>, <first> ordering', () {
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

      test('handles uppercase particles as non-dropping', (){
        var result = NameParser.basic().parse('Willem De Kooning');
        expect(result.given, 'Willem');
        expect(result.family, 'Kooning');
        expect(result.droppingParticle, isEmpty);
        expect(result.nonDroppingParticle, 'De');
      });

      test('handles uppercase particles as non-dropping in <last>, <first>', (){
        var result = NameParser.basic().parse('De Kooning, Willem');
        expect(result.given, 'Willem');
        expect(result.family, 'Kooning');
        expect(result.droppingParticle, isEmpty);
        expect(result.nonDroppingParticle, 'De');
      });
      
      test('handles suffixes', (){
        var result = NameParser.basic().parse('Elizabeth Alexandra Mary II');
        expect(result.given, 'Elizabeth Alexandra');
        expect(result.family, 'Mary');
        expect(result.suffix, 'II');
      });

      test('handles suffixes when comma-separated', (){
        var result = NameParser.basic().parse('Elizabeth Alexandra Mary, II');
        expect(result.given, 'Elizabeth Alexandra');
        expect(result.family, 'Mary');
        expect(result.suffix, 'II');
      });

      test('handles suffixes in <last>, <first> when the suffix follows last', (){
        var result = NameParser.basic().parse('Mary II, Elizabeth Alexandra');
        expect(result.given, 'Elizabeth Alexandra');
        expect(result.family, 'Mary');
        expect(result.suffix, 'II');
      });

      test('handles suffixes in <last>, <first> when the suffix follows last with a comma', (){
        var result = NameParser.basic().parse('Mary, II, Elizabeth Alexandra');
        expect(result.given, 'Elizabeth Alexandra');
        expect(result.family, 'Mary');
        expect(result.suffix, 'II');
      });

      test('handles suffixes in <last>, <first> when the suffix is at the end', (){
        var result = NameParser.basic().parse('Mary, Elizabeth Alexandra II');
        expect(result.given, 'Elizabeth Alexandra');
        expect(result.family, 'Mary');
        expect(result.suffix, 'II');
      });

      test('handles suffixes in <last>, <first> when the suffix is at the end with a comma', (){
        var result = NameParser.basic().parse('Mary, Elizabeth Alexandra, II');
        expect(result.given, 'Elizabeth Alexandra');
        expect(result.family, 'Mary');
        expect(result.suffix, 'II');
      });


      // TODO: more testing
    });
  });
}
