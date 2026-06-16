class PernitScreenRecord {
  final String title;
  final Map<String, String> fields;

  const PernitScreenRecord.api({required this.title, required this.fields});

  String get firstValue {
    if (fields.isEmpty) {
      return '';
    }

    return fields.values.first;
  }
}
