import 'package:equatable/equatable.dart';

import 'raw_material_entry.dart';

class RawMaterialEntryPage extends Equatable {
  final List<RawMaterialEntry> entries;
  final int totalCount;
  final int page;
  final bool hasNextPage;

  const RawMaterialEntryPage({
    required this.entries,
    required this.totalCount,
    required this.page,
    required this.hasNextPage,
  });

  @override
  List<Object?> get props => [entries, totalCount, page, hasNextPage];
}

class SamplingRecord extends Equatable {
  final int id;
  final String takenBy;
  final DateTime takenAt;
  final String sampleNo;

  const SamplingRecord({
    required this.id,
    required this.takenBy,
    required this.takenAt,
    required this.sampleNo,
  });

  @override
  List<Object?> get props => [id, takenBy, takenAt, sampleNo];
}

class QcRecord extends Equatable {
  final int qcId;
  final String? comments;
  final String qcStatus;
  final DateTime timestamp;
  final String checkedByName;

  const QcRecord({
    required this.qcId,
    required this.checkedByName,
    required this.qcStatus,
    required this.timestamp,
    this.comments,
  });

  @override
  List<Object?> get props => [qcId, comments, qcStatus, timestamp, checkedByName];
}

class EntryMetadata extends Equatable {
  final List<SamplingRecord> samplingHistory;
  final List<QcRecord> qcHistory;

  const EntryMetadata({
    required this.samplingHistory,
    required this.qcHistory,
  });

  @override
  List<Object?> get props => [samplingHistory, qcHistory];
}

class RawMaterialSample extends Equatable {
  final int id;
  final int batchId;
  final String rawMaterialName;
  final String? sampleNumber;
  final String status;
  final DateTime? createdAt;

  const RawMaterialSample({
    required this.id,
    required this.batchId,
    required this.rawMaterialName,
    required this.sampleNumber,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    batchId,
    rawMaterialName,
    sampleNumber,
    status,
    createdAt,
  ];
}

class RawMaterialSamplePage extends Equatable {
  final List<RawMaterialSample> samples;
  final int totalCount;
  final int page;
  final bool hasNextPage;

  const RawMaterialSamplePage({
    required this.samples,
    required this.totalCount,
    required this.page,
    required this.hasNextPage,
  });

  @override
  List<Object?> get props => [samples, totalCount, page, hasNextPage];
}

class AnalysisSop extends Equatable {
  final int id;
  final String title;
  final String documentNumber;
  final String? referenceMethod;

  const AnalysisSop({
    required this.id,
    required this.title,
    required this.documentNumber,
    required this.referenceMethod,
  });

  @override
  List<Object?> get props => [id, title, documentNumber, referenceMethod];
}

class ChemicalAnalysisParameter extends Equatable {
  final int id;
  final String name;
  final String? unit;
  final double? normalMin;
  final double? normalMax;
  final double? rejectedMin;
  final double? rejectedMax;
  final double? value;
  final int? sopId;
  final String? sopName;
  final String? sopDocumentNumber;
  final bool? isWithinRange;

  const ChemicalAnalysisParameter({
    required this.id,
    required this.name,
    required this.unit,
    required this.normalMin,
    required this.normalMax,
    required this.rejectedMin,
    required this.rejectedMax,
    required this.value,
    required this.sopId,
    required this.sopName,
    required this.sopDocumentNumber,
    required this.isWithinRange,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    unit,
    normalMin,
    normalMax,
    rejectedMin,
    rejectedMax,
    value,
    sopId,
    sopName,
    sopDocumentNumber,
    isWithinRange,
  ];
}

class PhysicalAnalysisParameter extends Equatable {
  final int id;
  final String name;
  final String? reference;
  final String? rejectedReference;
  final String? value;

  const PhysicalAnalysisParameter({
    required this.id,
    required this.name,
    required this.reference,
    required this.rejectedReference,
    required this.value,
  });

  @override
  List<Object?> get props => [id, name, reference, rejectedReference, value];
}

class RawMaterialAnalysisWorkspace extends Equatable {
  final RawMaterialSample sample;
  final int batchId;
  final String rawMaterialName;
  final double supplierWeight;
  final String? unit;
  final String? warehouseName;
  final List<ChemicalAnalysisParameter> chemicalParameters;
  final List<PhysicalAnalysisParameter> physicalParameters;
  final List<AnalysisSop> sops;
  final bool isComplete;

  const RawMaterialAnalysisWorkspace({
    required this.sample,
    required this.batchId,
    required this.rawMaterialName,
    required this.supplierWeight,
    required this.unit,
    required this.warehouseName,
    required this.chemicalParameters,
    required this.physicalParameters,
    required this.sops,
    required this.isComplete,
  });

  int get totalParameters =>
      chemicalParameters.length + physicalParameters.length;

  @override
  List<Object?> get props => [
    sample,
    batchId,
    rawMaterialName,
    supplierWeight,
    unit,
    warehouseName,
    chemicalParameters,
    physicalParameters,
    sops,
    isComplete,
  ];
}

class ChemicalAnalysisResultDraft extends Equatable {
  final int parameterId;
  final double value;

  const ChemicalAnalysisResultDraft({
    required this.parameterId,
    required this.value,
  });

  @override
  List<Object?> get props => [parameterId, value];
}

class PhysicalAnalysisResultDraft extends Equatable {
  final int parameterId;
  final String value;

  const PhysicalAnalysisResultDraft({
    required this.parameterId,
    required this.value,
  });

  @override
  List<Object?> get props => [parameterId, value];
}

class RawMaterialAnalysisSubmission extends Equatable {
  final List<ChemicalAnalysisResultDraft> chemicalResults;
  final List<PhysicalAnalysisResultDraft> physicalResults;

  const RawMaterialAnalysisSubmission({
    required this.chemicalResults,
    required this.physicalResults,
  });

  bool matches(RawMaterialAnalysisWorkspace workspace) {
    final chemicalIds = chemicalResults
        .map((result) => result.parameterId)
        .toSet();
    final expectedChemicalIds = workspace.chemicalParameters
        .map((parameter) => parameter.id)
        .toSet();
    final physicalIds = physicalResults
        .map((result) => result.parameterId)
        .toSet();
    final expectedPhysicalIds = workspace.physicalParameters
        .map((parameter) => parameter.id)
        .toSet();

    return chemicalResults.isNotEmpty || physicalResults.isNotEmpty
        ? chemicalIds.length == chemicalResults.length &&
              physicalIds.length == physicalResults.length &&
              expectedChemicalIds.containsAll(chemicalIds) &&
              expectedPhysicalIds.containsAll(physicalIds)
        : false;
  }

  @override
  List<Object?> get props => [chemicalResults, physicalResults];
}

enum RawMaterialQualityDecision {
  accepted('accepted'),
  rejected('rejected');

  final String apiValue;

  const RawMaterialQualityDecision(this.apiValue);
}
