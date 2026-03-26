import 'dart:async';
import 'dart:collection';
import '../command_runner.dart';

// ================= ENUM =================
enum OptionType { flag, option }

// ================= БАЗОВЫЙ АРГУМЕНТ =================
abstract class Argument {
  String get name;
  String? get help;

  // Может быть bool (для флагов) или String
  Object? get defaultValue;

  String? get valueHelp;

  String get usage;
}

// ================= OPTION =================
class Option extends Argument {
  Option(
    this.name, {
    required this.type,
    this.help,
    this.abbr,
    this.defaultValue,
    this.valueHelp,
  });

  @override
  final String name;

  final OptionType type;

  @override
  final String? help;

  final String? abbr;

  @override
  final Object? defaultValue;

  @override
  final String? valueHelp;

  @override
  String get usage {
    if (abbr != null) {
      return '-$abbr,--$name: $help';
    }
    return '--$name: $help';
  }
}

// ================= COMMAND =================
abstract class Command extends Argument {
  @override
  String get name;

  String get description;

  bool get requiresArgument => false;

  late CommandRunner runner;

  @override
  String? help;

  @override
  String? defaultValue;

  @override
  String? valueHelp;

  // ===== OPTIONS =====
  final List<Option> _options = [];

  UnmodifiableSetView<Option> get options =>
      UnmodifiableSetView(_options.toSet());

  // Добавить флаг (boolean)
  void addFlag(String name,
      {String? help, String? abbr, String? valueHelp}) {
    _options.add(
      Option(
        name,
        help: help,
        abbr: abbr,
        defaultValue: false,
        valueHelp: valueHelp,
        type: OptionType.flag,
      ),
    );
  }

  // Добавить опцию со значением
  void addOption(
    String name, {
    String? help,
    String? abbr,
    String? defaultValue,
    String? valueHelp,
  }) {
    _options.add(
      Option(
        name,
        help: help,
        abbr: abbr,
        defaultValue: defaultValue,
        valueHelp: valueHelp,
        type: OptionType.option,
      ),
    );
  }

  // Логика команды
  FutureOr<Object?> run(ArgResults args);

  @override
  String get usage {
    return '$name: $description';
  }
}

// ================= ARG RESULTS =================
class ArgResults {
  Command? command;
  String? commandArg;

  Map<Option, Object?> options = {};
}