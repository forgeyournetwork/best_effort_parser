import 'dart:collection';

import 'parsed_name.dart';

/// The type of function [NameParser] uses to generate its [Output].
///
/// The values given as parameters to this function will never be null. If a name does not have a
/// given component, an empty string will be given to this function's corresponding parameter.
typedef ParsedNameStorage<Output> = Output Function(String family,
    {String given, String droppingParticle, String nonDroppingParticle, String suffix});

// TODO: explain [NameParser]
class NameParser<Output> {
  /// A [RegExp] pattern matching a variety of name suffixes.
  ///
  /// Included:
  /// - `jr`, `sr`
  /// - Roman numerals `i` - `xiii`
  /// - `esq`, `cpa`, `dc`, `dds`, `vm`, `jd`, `md`, `phd`
  static const String defaultSuffixes = r'^([js]r|[vx]?i{0,3}|i[vx]|esq|cpa|dc|dds|vm|[jm]d|phd)$';

  /// A [RegExp] pattern matching a variety of name particles.
  ///
  /// Included:
  /// -`af`, `aw`, `da`, `das`, `de`, `den`, `der`, `des`, `di`, `dit`, `do`, `dos`, `du`, `la`,
  /// `le`, `na`, `of`, `ter`, `thoe`, `tot`, `van`, `von`, `zu`
  static const String defaultParticles =
      r'^(a[fw]|d(([ao]s?)|(e[nrs]?)|(it?)|u)|l[ea]|na|of|t(er|hoe|ot)|v[ao]n|zu)$';

  /// A [RegExp] pattern matching punctuation by negating alphanumeric and whitespace characters.
  ///
  /// `_` is included as a special case because it is typically included as an alphanumeric
  /// character.
  static const String defaultPunctuation = r'_|[^\w\s]';

  /// Internal storage of applicable [RegExp]s, where the name represents what is positively
  /// detected.
  RegExp _suffixes,
      _particles,
      _punctuation,
      _whitespace = RegExp(r'\s+'),
      _commas = RegExp(r'\s*,+\s*');

  /// Internal storage for the [ParsedNameStorage] function, to be used to return the output of
  /// [parse].
  ParsedNameStorage<Output> _parsedNameStorage;

  /// Constructor for [NameParser], requiring a [ParsedNameStorage] to return as output.
  ///
  /// Optional parameters are available to customize what the parsing detects as [suffixes],
  /// [particles], and [punctuation], respectively. Those optional parameters are [Pattern]s:
  ///
  /// - If the parameter is a [RegExp], use it as-is.
  /// - If the parameter is a [String], wrap it in a case-insensitive [RegExp].
  ///
  /// Since the default values of the optional parameters are strings, they are converted to
  /// case-insensitive [RegExp] objects here.
  NameParser(ParsedNameStorage<Output> parsedNameStorage,
      {Pattern suffixes = defaultSuffixes,
      Pattern particles = defaultParticles,
      Pattern punctuation = defaultPunctuation}) {
    _parsedNameStorage = parsedNameStorage;
    _suffixes = suffixes is String ? RegExp(suffixes, caseSensitive: false) : suffixes;
    _particles = particles is String ? RegExp(particles, caseSensitive: false) : particles;
    _punctuation = punctuation is String ? RegExp(punctuation, caseSensitive: false) : punctuation;
  }

  /// Static basic constructor for [NameParser] that restricts the output of [parse] to be a
  /// [ParsedName] object.
  ///
  /// Optional parameters may be provided; they behave precisely the same as the normal
  /// constructor for [NameParser].
  static NameParser<ParsedName> basic(
          {Pattern suffixes = defaultSuffixes,
          Pattern particles = defaultParticles,
          Pattern punctuation = defaultPunctuation}) =>
      NameParser<ParsedName>(ParsedName.constantConstructor,
          suffixes: suffixes, particles: particles, punctuation: punctuation);

  // TODO: explain [parse]
  Output parse(String input) {
    // Separate out obvious suffixes in the name. They could be anywhere, but they will be in the
    // correct order with themselves. Splits parts internally based on whitespace so that a comma
    // part with multiple suffixes will still be properly detected.
    List<String> commaParts = input.split(_commas);
    DoubleLinkedQueue<String> suffixParts = DoubleLinkedQueue();
    DoubleLinkedQueue<String> nonSuffixParts = DoubleLinkedQueue();
    for (var part in commaParts)
      if (part.replaceAll(_punctuation, '').split(_whitespace).every((s) => s.contains(_suffixes)))
        suffixParts.addLast(part);
      else
        nonSuffixParts.addLast(part);

    // If we still have multiple comma-separated parts, assume it is a "<last>, <first>"-type
    // scenario. Make the first element the last element and join everything with spaces so we
    // get something roughly matching "<first> <last>".
    String name;
    if (nonSuffixParts.length > 1) {
      // If the last part ends in a suffix, we have "<last>, <first> <suffixes>", so strip
      // suffixes off of the end before rotating <last> around.
      if (nonSuffixParts.last
          .split(_whitespace)
          .last
          .replaceAll(_punctuation, '')
          .contains(_suffixes)) {
        List<String> lastParts = nonSuffixParts.removeLast().split(_whitespace);
        while (lastParts.last.replaceAll(_punctuation, '').contains(_suffixes))
          suffixParts.addFirst(lastParts.removeLast());
        nonSuffixParts.add(lastParts.join(' '));
      }
      nonSuffixParts.add(nonSuffixParts.removeFirst());
      name = nonSuffixParts.join(' ');
    } else if (nonSuffixParts.isEmpty)
      // This means we have some sort of empty input or that everything is suffixes... return
      // immediately with everything we have as the family name.
      return _parsedNameStorage(input,
          given: '', droppingParticle: '', nonDroppingParticle: '', suffix: '');
    else
      name = nonSuffixParts.first;

    // There may be suffixes at the end that weren't comma-separated, so consume them if there exist
    // non-suffix parts.
    List<String> spaceParts = name.split(_whitespace);
    List<String> spacePartsNoPunctuation =
        spaceParts.map((s) => s.replaceAll(_punctuation, '')).toList();
    if (spacePartsNoPunctuation.any((s) => !s.contains(_suffixes)))
      while (spacePartsNoPunctuation.last.contains(_suffixes)) {
        suffixParts.addFirst(spaceParts.removeLast());
        spacePartsNoPunctuation.removeLast();
      }

    // If there's a particle that isn't the last part, consume all the parts from the end up to
    // that point as the family name.
    DoubleLinkedQueue<String> familyParts = DoubleLinkedQueue();
    if (spacePartsNoPunctuation.any((s) => s.contains(_particles)) &&
        !spacePartsNoPunctuation.last.contains(_particles))
      while (!spacePartsNoPunctuation.last.contains(_particles)) {
        familyParts.addFirst(spaceParts.removeLast());
        spacePartsNoPunctuation.removeLast();
      }
    else {
      familyParts.addFirst(spaceParts.removeLast());
      spacePartsNoPunctuation.removeLast();
    }

    // Consume any particles, calling ones that aren't lowercase non-dropping and any others as
    // dropping.
    DoubleLinkedQueue<String> nonDroppingParticleParts = DoubleLinkedQueue();
    DoubleLinkedQueue<String> droppingParticleParts = DoubleLinkedQueue();
    while (spaceParts.isNotEmpty && spacePartsNoPunctuation.last.contains(_particles)) {
      var particle = spacePartsNoPunctuation.removeLast();
      if (particle.toLowerCase() != particle)
        nonDroppingParticleParts.addFirst(spaceParts.removeLast());
      else
        droppingParticleParts.addFirst(spaceParts.removeLast());
    }

    // Remaining space parts are all part of the given name; we have everything to return now.
    return _parsedNameStorage(familyParts.join(' '),
        given: spaceParts.join(' '),
        droppingParticle: droppingParticleParts.join(' '),
        nonDroppingParticle: nonDroppingParticleParts.join(' '),
        suffix: suffixParts.join(' '));
  }
}
