/// Immutable value class for the components of a name.
class ParsedName {
  late String _family, _given, _droppingParticle, _nonDroppingParticle, _suffix;

  /// Get the family (last) name.
  String get family => _family;

  /// Get the given (first and middle) name.
  String get given => _given;

  /// Get the dropping (disappears when only the last name is shown) particle.
  String get droppingParticle => _droppingParticle;

  /// Get the non-dropping (stays when only the last name is shown) particle.
  String get nonDroppingParticle => _nonDroppingParticle;

  /// Get the last name suffix.
  String get suffix => _suffix;

  /// Constructor for [ParsedName], where any null parameters will have the empty string used in
  /// their place.
  ParsedName(String? family,
      {String? given,
      String? droppingParticle,
      String? nonDroppingParticle,
      String? suffix}) {
    _family = family ?? '';
    _given = given ?? '';
    _droppingParticle = droppingParticle ?? '';
    _nonDroppingParticle = nonDroppingParticle ?? '';
    _suffix = suffix ?? '';
  }

  /// Static method constructor for [ParsedName] so that this class can be constructed via
  /// reference.
  static ParsedName constantConstructor(String family,
          {String? given,
          String? droppingParticle,
          String? nonDroppingParticle,
          String? suffix}) =>
      ParsedName(family,
          given: given,
          droppingParticle: droppingParticle,
          nonDroppingParticle: nonDroppingParticle,
          suffix: suffix);

  /// Join all non-empty fields with a [separator] (defaults to a space).
  ///
  /// The order of the fields is "first last". Specifically:
  /// 1. [given]
  /// 2. [droppingParticle]
  /// 3. [nonDroppingParticle]
  /// 4. [family]
  /// 5. [suffix]
  @override
  String toString({String separator = ' '}) => [
        if (given.isNotEmpty) given,
        if (droppingParticle.isNotEmpty) droppingParticle,
        if (nonDroppingParticle.isNotEmpty) nonDroppingParticle,
        if (family.isNotEmpty) family,
        if (suffix.isNotEmpty) suffix,
      ].join(separator);

  /// Evaluate if the [other] object is the same as this, by type and field equality.
  @override
  bool operator ==(other) =>
      other is ParsedName &&
      family == other.family &&
      given == other.given &&
      droppingParticle == other.droppingParticle &&
      nonDroppingParticle == other.nonDroppingParticle &&
      suffix == other.suffix;

  /// Similar to [toString] but with labels for each present field.
  String diagnosticString(
          {String separator = ' ',
          String givenLabel = '[Given]:',
          String droppingParticleLabel = '[Dropping Particle]:',
          String nonDroppingParticleLabel = '[Non-dropping Particle]:',
          String familyLabel = '[Family]:',
          String suffixLabel = '[Suffix]:'}) =>
      [
        if (given.isNotEmpty && givenLabel.isNotEmpty) givenLabel,
        if (given.isNotEmpty) given,
        if (droppingParticle.isNotEmpty && droppingParticleLabel.isNotEmpty)
          droppingParticleLabel,
        if (droppingParticle.isNotEmpty) droppingParticle,
        if (nonDroppingParticle.isNotEmpty &&
            nonDroppingParticleLabel.isNotEmpty)
          nonDroppingParticleLabel,
        if (nonDroppingParticle.isNotEmpty) nonDroppingParticle,
        if (family.isNotEmpty && familyLabel.isNotEmpty) familyLabel,
        if (family.isNotEmpty) family,
        if (suffix.isNotEmpty && suffixLabel.isNotEmpty) suffixLabel,
        if (suffix.isNotEmpty) suffix
      ].join(separator);
}
