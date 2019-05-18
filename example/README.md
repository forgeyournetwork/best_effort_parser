# Examples
> Sample behavior of these examples is available in the top-level `README.md` file
## `name_example.dart`
A command-line utility demoing the capabilities of `package:best_effort_parser/name.dart`.

```dart
import 'package:best_effort_parser/name.dart';

/// Bare-bones example of using [NameParser] as a command-line program. All arguments are
/// concatenated with spaces and then run through the parser with default settings.
///
/// Example usage:
/// ```text
/// λ  dart name_example.dart 'Jack Warren'
/// [Given]: Jack [Family]: Warren
/// ```
void main(List<String> arguments) =>
    print(NameParser.basic().parse(arguments.join(' ')).diagnosticString());
```

Provided `dart` is on your path, the script may be run from the `example/` directory with ```dart name_exaple.dart``` followed by strings of your choice.

## `date_example.dart`
A command-line utility demoing the capabilities of `package:best_effort_parser/date.dart`.

```dart
import 'package:best_effort_parser/date.dart';

/// Bare-bones example of using [DateParser] as a command-line program. All arguments are
/// concatenated with spaces and then run through the parser with default settings.
///
/// Example usage:
/// ```text
/// λ  dart date_example.dart 'January 1st, 2019'
/// [Day]: 1 [Month]: 1 [Year]: 2019
/// ```
void main(List<String> arguments) =>
    DateParser.basic().parse(arguments.join(' ')).forEach(print);
```

Provided `dart` is on your path, the script may be run from the `example/` directory with `dart date_example.dart` followed by strings of your choice.