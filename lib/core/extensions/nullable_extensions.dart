extension NullableStringExtension on String? {
  bool isNullOrEmpty() {
    return this == null || this!.isEmpty;
  }

  bool isNullOrBlank() {
    return this == null || this!.trim().isEmpty;
  }
}

extension NullableIterableExtension<T> on Iterable<T>? {
  bool isNullOrEmpty() {
    return this == null || this!.isEmpty;
  }
}

extension NullableMapExtension<K, V> on Map<K, V>? {
  bool isNullOrEmpty() {
    return this == null || this!.isEmpty;
  }
}
