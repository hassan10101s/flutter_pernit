import '../../../../core/screen_records/pernit_screen_record.dart';
import '../../../screen_records/data/repos/endpoint_screen_record_repository.dart';
import '../../../screen_records/data/repos/screen_record_repository_dependencies.dart';
import '../../../screen_records/presentation/bloc/screen_records_cubit.dart';

class UnitsRecordsRepository extends EndpointScreenRecordRepository {
  UnitsRecordsRepository(
    List<PernitScreenRecord> records, [
    ScreenRecordRepositoryDependencies? dependencies,
  ]) : super(
         endpoint: '/v1/auth/erp/units/',
         initialRecords: records,
         dependencies: dependencies,
       );
}

class UnitsRecordsCubit extends ScreenRecordsCubit {
  UnitsRecordsCubit(UnitsRecordsRepository super.repository);
}

class SopRecordsRepository extends EndpointScreenRecordRepository {
  SopRecordsRepository(
    List<PernitScreenRecord> records, [
    ScreenRecordRepositoryDependencies? dependencies,
  ]) : super(
         endpoint: '/v1/auth/erp/sops-lab/',
         initialRecords: records,
         dependencies: dependencies,
       );
}

class SopRecordsCubit extends ScreenRecordsCubit {
  SopRecordsCubit(SopRecordsRepository super.repository);
}

class SopDetailsRecordsRepository extends EndpointScreenRecordRepository {
  SopDetailsRecordsRepository(
    List<PernitScreenRecord> records, [
    ScreenRecordRepositoryDependencies? dependencies,
  ]) : super(
         endpoint: '/v1/auth/erp/sop-details-lab/',
         initialRecords: records,
         dependencies: dependencies,
       );
}

class SopDetailsRecordsCubit extends ScreenRecordsCubit {
  SopDetailsRecordsCubit(SopDetailsRecordsRepository super.repository);
}

class WarehousesRecordsRepository extends EndpointScreenRecordRepository {
  WarehousesRecordsRepository(
    List<PernitScreenRecord> records, [
    ScreenRecordRepositoryDependencies? dependencies,
  ]) : super(
         endpoint: '/v1/auth/erp/warehouses/',
         initialRecords: records,
         dependencies: dependencies,
       );
}

class WarehousesRecordsCubit extends ScreenRecordsCubit {
  WarehousesRecordsCubit(WarehousesRecordsRepository super.repository);
}

class ProductsRecordsRepository extends EndpointScreenRecordRepository {
  ProductsRecordsRepository(
    List<PernitScreenRecord> records, [
    ScreenRecordRepositoryDependencies? dependencies,
  ]) : super(
         endpoint: '/v1/auth/erp/products/',
         initialRecords: records,
         dependencies: dependencies,
       );
}

class ProductsRecordsCubit extends ScreenRecordsCubit {
  ProductsRecordsCubit(ProductsRecordsRepository super.repository);
}

class RawMaterialsRecordsRepository extends EndpointScreenRecordRepository {
  RawMaterialsRecordsRepository(
    List<PernitScreenRecord> records, [
    ScreenRecordRepositoryDependencies? dependencies,
  ]) : super(
         endpoint: '/v1/auth/erp/raw-materials/',
         initialRecords: records,
         dependencies: dependencies,
       );
}

class RawMaterialsRecordsCubit extends ScreenRecordsCubit {
  RawMaterialsRecordsCubit(RawMaterialsRecordsRepository super.repository);
}

class ProductCategoriesRecordsRepository
    extends EndpointScreenRecordRepository {
  ProductCategoriesRecordsRepository(
    List<PernitScreenRecord> records, [
    ScreenRecordRepositoryDependencies? dependencies,
  ]) : super(
         endpoint: '/v1/auth/erp/category-products/',
         initialRecords: records,
         dependencies: dependencies,
       );
}

class ProductCategoriesRecordsCubit extends ScreenRecordsCubit {
  ProductCategoriesRecordsCubit(
    ProductCategoriesRecordsRepository super.repository,
  );
}

class RawMaterialCategoriesRecordsRepository
    extends EndpointScreenRecordRepository {
  RawMaterialCategoriesRecordsRepository(
    List<PernitScreenRecord> records, [
    ScreenRecordRepositoryDependencies? dependencies,
  ]) : super(
         endpoint: '/v1/auth/erp/category-raw-materials/',
         initialRecords: records,
         dependencies: dependencies,
       );
}

class RawMaterialCategoriesRecordsCubit extends ScreenRecordsCubit {
  RawMaterialCategoriesRecordsCubit(
    RawMaterialCategoriesRecordsRepository super.repository,
  );
}

class FormulasRecordsRepository extends EndpointScreenRecordRepository {
  FormulasRecordsRepository(
    List<PernitScreenRecord> records, [
    ScreenRecordRepositoryDependencies? dependencies,
  ]) : super(
         endpoint: '/v1/auth/erp/formulas/',
         initialRecords: records,
         dependencies: dependencies,
       );
}

class FormulasRecordsCubit extends ScreenRecordsCubit {
  FormulasRecordsCubit(FormulasRecordsRepository super.repository);
}

class FormulaDetailsRecordsRepository extends EndpointScreenRecordRepository {
  FormulaDetailsRecordsRepository(
    List<PernitScreenRecord> records, [
    ScreenRecordRepositoryDependencies? dependencies,
  ]) : super(
         endpoint: '/v1/auth/erp/formula-details/',
         initialRecords: records,
         dependencies: dependencies,
       );
}

class FormulaDetailsRecordsCubit extends ScreenRecordsCubit {
  FormulaDetailsRecordsCubit(FormulaDetailsRecordsRepository super.repository);
}

class ProductionRulesRecordsRepository extends EndpointScreenRecordRepository {
  ProductionRulesRecordsRepository(
    List<PernitScreenRecord> records, [
    ScreenRecordRepositoryDependencies? dependencies,
  ]) : super(
         endpoint: '/v1/auth/erp/production-rules/',
         initialRecords: records,
         dependencies: dependencies,
       );
}

class ProductionRulesRecordsCubit extends ScreenRecordsCubit {
  ProductionRulesRecordsCubit(
    ProductionRulesRecordsRepository super.repository,
  );
}

class LabParametersRecordsRepository extends EndpointScreenRecordRepository {
  LabParametersRecordsRepository(
    List<PernitScreenRecord> records, [
    ScreenRecordRepositoryDependencies? dependencies,
  ]) : super(
         endpoint: '/v1/auth/erp/parameter-labs/',
         initialRecords: records,
         dependencies: dependencies,
       );
}

class LabParametersRecordsCubit extends ScreenRecordsCubit {
  LabParametersRecordsCubit(LabParametersRecordsRepository super.repository);
}

class PhysicalLabsRecordsRepository extends EndpointScreenRecordRepository {
  PhysicalLabsRecordsRepository(
    List<PernitScreenRecord> records, [
    ScreenRecordRepositoryDependencies? dependencies,
  ]) : super(
         endpoint: '/v1/auth/erp/physical-labs/',
         initialRecords: records,
         dependencies: dependencies,
       );
}

class PhysicalLabsRecordsCubit extends ScreenRecordsCubit {
  PhysicalLabsRecordsCubit(PhysicalLabsRecordsRepository super.repository);
}

class AnalysisParametersRecordsRepository
    extends EndpointScreenRecordRepository {
  AnalysisParametersRecordsRepository(
    List<PernitScreenRecord> records, [
    ScreenRecordRepositoryDependencies? dependencies,
  ]) : super(
         endpoint: '/v1/auth/erp/analysis-parameters-raw-materials/',
         initialRecords: records,
         dependencies: dependencies,
       );
}

class AnalysisParametersRecordsCubit extends ScreenRecordsCubit {
  AnalysisParametersRecordsCubit(
    AnalysisParametersRecordsRepository super.repository,
  );
}

class ReferenceMethodsRecordsRepository extends EndpointScreenRecordRepository {
  ReferenceMethodsRecordsRepository(
    List<PernitScreenRecord> records, [
    ScreenRecordRepositoryDependencies? dependencies,
  ]) : super(
         endpoint: '/v1/auth/erp/reference-methods/',
         initialRecords: records,
         dependencies: dependencies,
       );
}

class ReferenceMethodsRecordsCubit extends ScreenRecordsCubit {
  ReferenceMethodsRecordsCubit(
    ReferenceMethodsRecordsRepository super.repository,
  );
}

class PredictiveResultsRecordsRepository
    extends EndpointScreenRecordRepository {
  PredictiveResultsRecordsRepository(
    List<PernitScreenRecord> records, [
    ScreenRecordRepositoryDependencies? dependencies,
  ]) : super(
         endpoint: '/v1/auth/erp/predictive-results/',
         initialRecords: records,
         dependencies: dependencies,
       );
}

class PredictiveResultsRecordsCubit extends ScreenRecordsCubit {
  PredictiveResultsRecordsCubit(
    PredictiveResultsRecordsRepository super.repository,
  );
}

class SuppliersRecordsRepository extends EndpointScreenRecordRepository {
  SuppliersRecordsRepository(
    List<PernitScreenRecord> records, [
    ScreenRecordRepositoryDependencies? dependencies,
  ]) : super(
         endpoint: '/v1/auth/erp/suppliers/',
         initialRecords: records,
         dependencies: dependencies,
       );
}

class SuppliersRecordsCubit extends ScreenRecordsCubit {
  SuppliersRecordsCubit(SuppliersRecordsRepository super.repository);
}

class CustomersRecordsRepository extends EndpointScreenRecordRepository {
  CustomersRecordsRepository(
    List<PernitScreenRecord> records, [
    ScreenRecordRepositoryDependencies? dependencies,
  ]) : super(
         endpoint: '/v1/auth/erp/customers/',
         initialRecords: records,
         dependencies: dependencies,
       );
}

class CustomersRecordsCubit extends ScreenRecordsCubit {
  CustomersRecordsCubit(CustomersRecordsRepository super.repository);
}
