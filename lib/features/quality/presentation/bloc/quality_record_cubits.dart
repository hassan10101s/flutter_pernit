import '../../../../core/screen_records/pernit_screen_record.dart';
import '../../../screen_records/data/repos/endpoint_screen_record_repository.dart';
import '../../../screen_records/data/repos/screen_record_repository_dependencies.dart';
import '../../../screen_records/presentation/bloc/screen_records_cubit.dart';

class RawMaterialLabSamplesRecordsRepository
    extends EndpointScreenRecordRepository {
  RawMaterialLabSamplesRecordsRepository(
    List<PernitScreenRecord> records, [
    ScreenRecordRepositoryDependencies? dependencies,
  ]) : super(
         endpoint: '/v1/auth/erp/lab-samples-of-received-raw-materials/',
         initialRecords: records,
         dependencies: dependencies,
       );
}

class RawMaterialLabSamplesRecordsCubit extends ScreenRecordsCubit {
  RawMaterialLabSamplesRecordsCubit(
    RawMaterialLabSamplesRecordsRepository super.repository,
  );
}

class RawMaterialLabResultsRecordsRepository
    extends EndpointScreenRecordRepository {
  RawMaterialLabResultsRecordsRepository(
    List<PernitScreenRecord> records, [
    ScreenRecordRepositoryDependencies? dependencies,
  ]) : super(
         endpoint: '/v1/auth/erp/lab-results-raw-materials/',
         initialRecords: records,
         dependencies: dependencies,
       );
}

class RawMaterialLabResultsRecordsCubit extends ScreenRecordsCubit {
  RawMaterialLabResultsRecordsCubit(
    RawMaterialLabResultsRecordsRepository super.repository,
  );
}

class RawMaterialPhysicalLabResultsRecordsRepository
    extends EndpointScreenRecordRepository {
  RawMaterialPhysicalLabResultsRecordsRepository(
    List<PernitScreenRecord> records, [
    ScreenRecordRepositoryDependencies? dependencies,
  ]) : super(
         endpoint: '/v1/auth/erp/physical-lab-results-raw-materials/',
         initialRecords: records,
         dependencies: dependencies,
       );
}

class RawMaterialPhysicalLabResultsRecordsCubit extends ScreenRecordsCubit {
  RawMaterialPhysicalLabResultsRecordsCubit(
    RawMaterialPhysicalLabResultsRecordsRepository super.repository,
  );
}

class RawMaterialQualityChecksRecordsRepository
    extends EndpointScreenRecordRepository {
  RawMaterialQualityChecksRecordsRepository(
    List<PernitScreenRecord> records, [
    ScreenRecordRepositoryDependencies? dependencies,
  ]) : super(
         endpoint: '/v1/auth/erp/quality-checks-raw-materials/',
         initialRecords: records,
         dependencies: dependencies,
       );
}

class RawMaterialQualityChecksRecordsCubit extends ScreenRecordsCubit {
  RawMaterialQualityChecksRecordsCubit(
    RawMaterialQualityChecksRecordsRepository super.repository,
  );
}

class ProductionQualityChecksRecordsRepository
    extends EndpointScreenRecordRepository {
  ProductionQualityChecksRecordsRepository(
    List<PernitScreenRecord> records, [
    ScreenRecordRepositoryDependencies? dependencies,
  ]) : super(
         endpoint: '/v1/auth/erp/quality-checks-production/',
         initialRecords: records,
         dependencies: dependencies,
       );
}

class ProductionQualityChecksRecordsCubit extends ScreenRecordsCubit {
  ProductionQualityChecksRecordsCubit(
    ProductionQualityChecksRecordsRepository super.repository,
  );
}
