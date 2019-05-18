# best_effort_parser

> Author: [Jack Warren][author site]

[![Build Status](https://travis-ci.com/jack-r-warren/best_effort_parser.svg?branch=master)](https://travis-ci.com/jack-r-warren/best_effort_parser) [![Coverage Status](https://coveralls.io/repos/github/jack-r-warren/best_effort_parser/badge.svg?branch=master)](https://coveralls.io/github/jack-r-warren/best_effort_parser?branch=master) [![Pub](https://img.shields.io/pub/v/best_effort_parser.svg)](https://pub.dartlang.org/packages/best_effort_parser)

Provides assistance with parsing arbitrary, unstructured user input into output types of your choice.

## Name Parsing
#### `best_effort_parser/name.dart`

Provides parsing of names by categorizing different parts:
- **family**: A person's last name(s)
- **given**: A person's first and middle name(s)
- **dropping particle**: particle(s) before the person's last name that are ignored if only the last name is shown
- **non-dropping particle**: particles(s) before the person's last name that are *not* ignored if only the last name is shown
- **suffix**: abbreviations after a person's last name

Features handling of a wide range of formats: beyond just "\<first> \<last>" and "\<last>, \<first>", particles and suffixes are parsed from any reasonably correct position a user may place them.

### Example:
#### `name_example.dart`

```dart
import 'package:best_effort_parser/name.dart';

void main(List<String> arguments) =>
    print(NameParser.basic().parse(arguments.join(' ')).diagnosticString());
```

Demo:
```text
λ  dart .\name_example.dart 'Jack Warren'
[Given]: Jack [Family]: Warren

λ  dart .\name_example.dart 'La Fontaine, Jean de'
[Given]: Jean [Dropping Particle]: de [Non-dropping Particle]: La [Family]: Fontaine

λ  dart .\name_example.dart 'Gates, Bill III'
[Given]: Bill [Family]: Gates [Suffix]: III

λ  dart .\name_example.dart 'Willem de Kooning'
[Given]: Willem [Dropping Particle]: de [Family]: Kooning
```

Customization of both parsing and output type is available.

## Date Parsing
#### `best_effort_parser/date.dart`

Provides parsing of dates by collecting years, months, and days and assembling those parts into a list. Each entry in that output list represents a singular date, so a string containing multiple dates or a range will have multiple entries in its output.

### Example:
#### `date_example.dart`

```dart
import 'package:best_effort_parser/date.dart';

void main(List<String> arguments) => 
    DateParser.basic().parse(arguments.join(' ')).forEach(print);
```

Demo:
```text
λ  dart .\date_example.dart 'January 1st, 2019'
[Day]: 1 [Month]: 1 [Year]: 2019

λ  dart .\date_example.dart '1/2/3'
[Day]: 2 [Month]: 1 [Year]: 2003

λ  dart .\date_example.dart '10/10/90 - 3/13/18'
[Day]: 10 [Month]: 10 [Year]: 1990
[Day]: 13 [Month]: 3 [Year]: 2018

λ  dart .\date_example.dart 'Spring-Summer 2010'
[Month]: 3 [Year]: 2010
[Month]: 6 [Year]: 2010

λ  dart .\date_example.dart '1999-15-6'
[Day]: 6 [Month]: 3 [Year]: 1999
```

Customization of both parsing and output type is available.

## Feature requests and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[author site]: https://jackwarren.info
[tracker]: https://github.com/jack-r-warren/best_effort_parser/issues
