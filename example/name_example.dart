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
