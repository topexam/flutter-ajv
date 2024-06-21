class ValidationResult {
  ValidationResult({
    this.message = "",
    this.property = "",
    this.keyword = "",
    this.dataPath = "",
    this.schemaPath = "",
    this.params = const {},
  }) : super();

  final String? message;
  final String? property;
  final String? keyword;
  final String? dataPath;
  final String? schemaPath;
  final Map<String, dynamic> params;

  static ValidationResult fromJson(Map<String, dynamic> map) {
    return ValidationResult(
      message: map['message'],
      property: map['property'],
      dataPath: map['dataPath'],
      schemaPath: map['schemaPath'],
      keyword: map['keyword'],
      params: map['params'] ?? {},
    );
  }

  static List<ValidationResult> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((e) => fromJson(e)).toList();
  }
}
