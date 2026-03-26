import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'arguments.dart';
import 'exceptions.dart';

class CommandRunner {
  CommandRunner({this.onOutput, this.onError});

  final Map<String, Command> _commands = {};

  FutureOr<void> Function(String)? onOutput;
  FutureOr<void> Function(Object)? onError;

  UnmodifiableSetView<Command> get commands =>
      UnmodifiableSetView(_commands.values.toSet());

  // ===== usage =====
  String get usage {
    final buffer = StringBuffer();

    buffer.writeln('Available commands:\n');

    for (final command in _commands.values) {
      buffer.writeln('  ${command.name} - ${command.description}');
    }

    return buffer.toString();
  }

  // ===== addCommand =====
  void addCommand(Command command) {
    _commands[command.name] = command;
    command.runner = this;
  }

  // ===== parse =====
  ArgResults parse(List<String> input) {
    final command = _commands[input.first]!;

    final results = ArgResults()
      ..command = command;

    for (int i = 1; i < input.length; i++) {
      final arg = input[i];

      for (final option in command.options) {
        if (arg == '--${option.name}' ||
            (option.abbr != null && arg == '-${option.abbr}')) {

          if (option.type == OptionType.flag) {
            results.options[option] = true;
          } else {
            if (i + 1 < input.length) {
              results.options[option] = input[i + 1];
              i++;
            }
          }
        }
      }
    }

    return results;
  }

  // ===== run =====
  Future<void> run(List<String> input) async {
    try {
      if (input.isEmpty) {
        throw ArgumentException('No command provided.');
      }

      final command = _commands[input.first];

      if (command == null) {
        throw ArgumentException('Unknown command: ${input.first}');
      }

      final results = parse(input);

      final output = await command.run(results);

      if (output != null) {
        if (onOutput != null) {
          await onOutput!(output.toString());
        } else {
          print(output);
        }
      }
    } on Exception catch (exception) {
      if (onError != null) {
        await onError!(exception);
      } else {
        rethrow;
      }
    }
  }
}