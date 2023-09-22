extension StringNullCheck on String {
  bool isNullOrEmpty() {
    return this == null || this.isEmpty;
  }
}

extension ListNullCheck on List {
  bool isNullOrEmpty() {
    return this == null || this.isEmpty;
  }
}
