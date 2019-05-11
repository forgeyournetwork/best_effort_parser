// TODO: documentation
class ParsedName {
  String _family, _given, _droppingParticle, _nonDroppingParticle, _suffix;

  String get family => _family;

  String get given => _given;

  String get droppingParticle => _droppingParticle;

  String get nonDroppingParticle => _nonDroppingParticle;

  String get suffix => _suffix;

  ParsedName(String family,
      {String given = '',
      String droppingParticle = '',
      String nonDroppingParticle = '',
      String suffix = ''}) {
    _family = family ?? '';
    _given = given ?? '';
    _droppingParticle = droppingParticle ?? '';
    _nonDroppingParticle = nonDroppingParticle ?? '';
    _suffix = suffix ?? '';
  }

  static ParsedName constantConstructor(String family,
          {String given = '',
          String droppingParticle = '',
          String nonDroppingParticle = '',
          String suffix = ''}) =>
      ParsedName(family,
          given: given,
          droppingParticle: droppingParticle,
          nonDroppingParticle: nonDroppingParticle,
          suffix: suffix);

  @override
  String toString() => [
        if (given.isNotEmpty) given,
        if (droppingParticle.isNotEmpty) droppingParticle,
        if (nonDroppingParticle.isNotEmpty) nonDroppingParticle,
        if (family.isNotEmpty) family,
        if (suffix.isNotEmpty) suffix,
      ].join(' ');

  @override
  bool operator ==(other) =>
      other is ParsedName &&
      family == other.family &&
      given == other.given &&
      droppingParticle == other.droppingParticle &&
      nonDroppingParticle == other.nonDroppingParticle &&
      suffix == other.suffix;

// TODO: diagnostic version of [toString]
}
