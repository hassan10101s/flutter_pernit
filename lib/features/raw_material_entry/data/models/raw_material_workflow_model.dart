import '../../domain/entities/raw_material_workflow.dart';
import 'raw_material_entry_model.dart';

class RawMaterialEntryPageModel {
  final List<RawMaterialEntryModel> entries;
  final int totalCount;
  final int page;
  final bool hasNextPage;

  const RawMaterialEntryPageModel({
    required this.entries,
    required this.totalCount,
    required this.page,
    required this.hasNextPage,
  });

  factory RawMaterialEntryPageModel.fromJson(
    Object? payload, {
    required int page,
  }) {
    if (payload is List<dynamic>) {
      final entries = _entryModels(payload);
      return RawMaterialEntryPageModel(
        entries: entries,
        totalCount: entries.length,
        page: page,
        hasNextPage: false,
      );
    }

    if (payload is Map<String, dynamic>) {
      final results = payload['results'];
      final entries = results is List<dynamic>
          ? _entryModels(results)
          : <RawMaterialEntryModel>[];
      return RawMaterialEntryPageModel(
        entries: entries,
        totalCount: _readInt(payload['count']) ?? entries.length,
        page: page,
        hasNextPage: _readString(payload['next']) != null,
      );
    }

    return RawMaterialEntryPageModel(
      entries: const [],
      totalCount: 0,
      page: page,
      hasNextPage: false,
    );
  }

  RawMaterialEntryPage toEntity() {
    return RawMaterialEntryPage(
      entries: [for (final entry in entries) entry.toEntity()],
      totalCount: totalCount,
      page: page,
      hasNextPage: hasNextPage,
    );
  }
}

class RawMaterialSampleModel extends RawMaterialSample {
  const RawMaterialSampleModel({
    required super.id,
    required super.batchId,
    required super.rawMaterialName,
    required super.sampleNumber,
    required super.status,
    required super.createdAt,
  });

  factory RawMaterialSampleModel.fromJson(Map<String, dynamic> json) {
    return RawMaterialSampleModel(
      id: _readInt(json['id']) ?? 0,
      batchId: _readInt(json['received_raw_material']) ?? 0,
      rawMaterialName:
          _readString(json['received_raw_material_name']) ?? 'Raw material',
      sampleNumber: _readString(json['sample_no']),
      status: _readString(json['status']) ?? 'pending',
      createdAt: DateTime.tryParse(_readString(json['created_at']) ?? ''),
    );
  }
}

class RawMaterialSamplePageModel extends RawMaterialSamplePage {
  const RawMaterialSamplePageModel({
    required super.samples,
    required super.totalCount,
    required super.page,
    required super.hasNextPage,
  });

  factory RawMaterialSamplePageModel.fromJson(
    Object? payload, {
    required int page,
  }) {
    final values = payload is Map<String, dynamic>
        ? _readList(payload['results'])
        : _readList(payload);
    return RawMaterialSamplePageModel(
      samples: [
        for (final value in values)
          if (value is Map<String, dynamic>)
            RawMaterialSampleModel.fromJson(value),
      ],
      totalCount: payload is Map<String, dynamic>
          ? _readInt(payload['count']) ?? values.length
          : values.length,
      page: page,
      hasNextPage:
          payload is Map<String, dynamic> &&
          _readString(payload['next']) != null,
    );
  }
}

class RawMaterialAnalysisWorkspaceModel extends RawMaterialAnalysisWorkspace {
  const RawMaterialAnalysisWorkspaceModel({
    required super.sample,
    required super.batchId,
    required super.rawMaterialName,
    required super.supplierWeight,
    required super.unit,
    required super.warehouseName,
    required super.chemicalParameters,
    required super.physicalParameters,
    required super.sops,
    required super.isComplete,
  });

  factory RawMaterialAnalysisWorkspaceModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final sampleJson = _readMap(json['sample']);
    final batchJson = _readMap(json['batch']);

    return RawMaterialAnalysisWorkspaceModel(
      sample: RawMaterialSample(
        id: _readInt(sampleJson['id']) ?? 0,
        batchId: _readInt(batchJson['id']) ?? 0,
        rawMaterialName:
            _readString(batchJson['raw_material_name']) ?? 'Raw material',
        sampleNumber: _readString(sampleJson['sample_no']),
        status: _readString(sampleJson['status']) ?? 'pending',
        createdAt: null,
      ),
      batchId: _readInt(batchJson['id']) ?? 0,
      rawMaterialName:
          _readString(batchJson['raw_material_name']) ?? 'Raw material',
      supplierWeight: _readDouble(batchJson['supplier_weight']) ?? 0,
      unit: _readString(batchJson['unit']),
      warehouseName: _readString(batchJson['warehouse_name']),
      chemicalParameters: [
        for (final value in _readList(json['chemical_parameters']))
          if (value is Map<String, dynamic>)
            ChemicalAnalysisParameter(
              id: _readInt(value['id']) ?? 0,
              name: _readString(value['name']) ?? 'Parameter',
              unit: _readString(value['unit']),
              normalMin: _readDouble(value['normal_min']),
              normalMax: _readDouble(value['normal_max']),
              rejectedMin: _readDouble(value['rejected_min']),
              rejectedMax: _readDouble(value['rejected_max']),
              value: _readDouble(value['value']),
              sopId: _readInt(value['sop']),
              sopName: _readString(value['sop_name']),
              sopDocumentNumber: _readString(value['sop_document_number']),
              isWithinRange: _readNullableBool(value['is_within_range']),
            ),
      ],
      physicalParameters: [
        for (final value in _readList(json['physical_parameters']))
          if (value is Map<String, dynamic>)
            PhysicalAnalysisParameter(
              id: _readInt(value['id']) ?? 0,
              name: _readString(value['name']) ?? 'Physical parameter',
              reference: _readString(value['reference']),
              rejectedReference: _readString(value['rejected_reference']),
              value: _readString(value['value']),
            ),
      ],
      sops: [
        for (final value in _readList(json['sops']))
          if (value is Map<String, dynamic>)
            AnalysisSop(
              id: _readInt(value['id']) ?? 0,
              title: _readString(value['title']) ?? 'SOP',
              documentNumber: _readString(value['document_number']) ?? '-',
              referenceMethod: _readString(value['reference_method']),
            ),
      ],
      isComplete: _readNullableBool(json['is_complete']) ?? false,
    );
  }
}

List<RawMaterialEntryModel> _entryModels(List<dynamic> values) {
  return [
    for (final value in values)
      if (value is Map<String, dynamic>) RawMaterialEntryModel.fromJson(value),
  ];
}

Map<String, dynamic> _readMap(Object? value) {
  return value is Map<String, dynamic> ? value : const {};
}

List<dynamic> _readList(Object? value) {
  return value is List<dynamic> ? value : const [];
}

int? _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '');
}

double? _readDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '');
}

String? _readString(Object? value) {
  final normalized = value?.toString().trim();
  if (normalized == null || normalized.isEmpty || normalized == 'null') {
    return null;
  }
  return normalized;
}

bool? _readNullableBool(Object? value) {
  if (value is bool) {
    return value;
  }
  final normalized = _readString(value)?.toLowerCase();
  if (normalized == 'true' || normalized == '1') {
    return true;
  }
  if (normalized == 'false' || normalized == '0') {
    return false;
  }
  return null;
}
