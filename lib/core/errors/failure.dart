import 'package:equatable/equatable.dart';

import 'failure_code.dart';

class Failure extends Equatable {
  final FailureCode code;
  final String messageKey;
  final Map<String, List<String>> fieldErrors;
  final List<String> nonFieldErrors;
  final Object? details;

  const Failure({
    required this.code,
    required this.messageKey,
    this.fieldErrors = const {},
    this.nonFieldErrors = const [],
    this.details,
  });

  @override
  List<Object?> get props => [
    code,
    messageKey,
    fieldErrors,
    nonFieldErrors,
    details,
  ];
}
