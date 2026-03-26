import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'arguments.dart';
import 'exceptions.dart';

class CommandRunner {
  CommandRunner({this.onError});

  final Map<String, Command> _commands = <String, Command>{};

  UnmodifiableSetView<Command> get commands =>
      UnmodifiableSetView<Command>(<Command>{..._commands.values});

  FutureOr<void> Function(Object)? onError;

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

      final results = ArgResults()
        ..command = command
        ..commandArg = input.length > 1 ? input[1] : null;

      final output = await command.run(results);

      if (output != null) {
        print(output);
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