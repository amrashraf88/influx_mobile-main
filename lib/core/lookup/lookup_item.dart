class LookupItem {
  const LookupItem({required this.value, required this.label});

  final String value;
  final String label;

  factory LookupItem.fromJson(Map<String, dynamic> json) {
    final String value =
        json['value']?.toString() ??
        json['slug']?.toString() ??
        json['id']?.toString() ??
        '';
    final String label =
        json['label']?.toString() ??
        json['name']?.toString() ??
        json['title']?.toString() ??
        value;
    return LookupItem(value: value, label: label);
  }
}
