import '../../../../core/screen_records/pernit_screen_record.dart';
import '../../../screen_records/data/repos/endpoint_screen_record_repository.dart';
import '../../../screen_records/presentation/bloc/screen_records_cubit.dart';

class ProductionOrdersRecordsRepository extends EndpointScreenRecordRepository {
  ProductionOrdersRecordsRepository(List<PernitScreenRecord> records)
    : super(
        endpoint: '/v1/auth/erp/production-orders/',
        initialRecords: records,
      );
}

class ProductionOrdersRecordsCubit extends ScreenRecordsCubit {
  ProductionOrdersRecordsCubit(
    ProductionOrdersRecordsRepository super.repository,
  );
}

class ProductionOrderDetailsRecordsRepository
    extends EndpointScreenRecordRepository {
  ProductionOrderDetailsRecordsRepository(List<PernitScreenRecord> records)
    : super(
        endpoint: '/v1/auth/erp/production-order-details/',
        initialRecords: records,
      );
}

class ProductionOrderDetailsRecordsCubit extends ScreenRecordsCubit {
  ProductionOrderDetailsRecordsCubit(
    ProductionOrderDetailsRecordsRepository super.repository,
  );
}

class ProductionLabSamplesRecordsRepository
    extends EndpointScreenRecordRepository {
  ProductionLabSamplesRecordsRepository(List<PernitScreenRecord> records)
    : super(
        endpoint: '/v1/auth/erp/lab-samples-of-production/',
        initialRecords: records,
      );
}

class ProductionLabSamplesRecordsCubit extends ScreenRecordsCubit {
  ProductionLabSamplesRecordsCubit(
    ProductionLabSamplesRecordsRepository super.repository,
  );
}

class ProductionLabResultsRecordsRepository
    extends EndpointScreenRecordRepository {
  ProductionLabResultsRecordsRepository(List<PernitScreenRecord> records)
    : super(
        endpoint: '/v1/auth/erp/lab-results-production/',
        initialRecords: records,
      );
}

class ProductionLabResultsRecordsCubit extends ScreenRecordsCubit {
  ProductionLabResultsRecordsCubit(
    ProductionLabResultsRecordsRepository super.repository,
  );
}

class ProductionReserveMaterialsRecordsRepository
    extends EndpointScreenRecordRepository {
  ProductionReserveMaterialsRecordsRepository(List<PernitScreenRecord> records)
    : super(
        endpoint: '/v1/auth/erp/production-orders/{id}/reserve_materials/',
        initialRecords: records,
      );
}

class ProductionReserveMaterialsRecordsCubit extends ScreenRecordsCubit {
  ProductionReserveMaterialsRecordsCubit(
    ProductionReserveMaterialsRecordsRepository super.repository,
  );
}
