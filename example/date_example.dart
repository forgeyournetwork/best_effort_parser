import 'package:best_effort_parser/date.dart';

/// Bare-bones example of using [DateParser] as a command-line program. All arguments are
/// concatenated with spaces and then run through the parser with default settings.
///
/// Example usage:
/// ```bash
/// $ dart date_example.dart 'January 1st, 2019'
/// [Day]: 1 [Month]: 1 [Year]: 2019
/// ```
void main(List<String> arguments) =>
    DateParser.basic().parse(arguments.join(' ')).forEach(print);
