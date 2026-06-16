import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/screen_records/pernit_screen_record.dart';

sealed class ScreenRecordsState extends Equatable {
  final List<PernitScreenRecord> records;

  const ScreenRecordsState({this.records = const []});

  @override
  List<Object?> get props => [records];
}

final class ScreenRecordsInitial extends ScreenRecordsState {
  const ScreenRecordsInitial({super.records});
}

final class ScreenRecordsLoading extends ScreenRecordsState {
  const ScreenRecordsLoading({super.records});
}

final class ScreenRecordsLoaded extends ScreenRecordsState {
  const ScreenRecordsLoaded({required super.records});
}

final class ScreenRecordsError extends ScreenRecordsState {
  final Failure failure;

  const ScreenRecordsError({required this.failure, super.records});

  @override
  List<Object?> get props => [...super.props, failure];
}
