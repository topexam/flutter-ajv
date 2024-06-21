import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';

import 'entities/index.dart';

class AJVValidator {
  late JavascriptRuntime jsRuntime;

  Future<void> setup() async {
    jsRuntime = getJavascriptRuntime();
    var ajvIsLoaded = jsRuntime.evaluate("""
          var ajvIsLoaded = (typeof ajv == 'undefined') ? "0" : "1";
          ajvIsLoaded;
        """).stringResult;
    debugPrint("AJV is Loaded $ajvIsLoaded");

    if (ajvIsLoaded == "0") {
      try {
        jsRuntime.evaluate("""var window = global = globalThis;""");
        final ajvJS = await rootBundle
            .loadString("packages/flutter_ajv/assets/js/ajv.js");
        jsRuntime.evaluate(ajvJS);
      } catch (e) {
        debugPrint('Failed to init js engine: ${e.toString()}');
      }
    }
  }

  JsEvalResult registerSchema(Map<String, dynamic> schema) {
    final code = """
        var ajv = new Ajv({ allErrors: true, coerceTypes: true });
        ajv.addSchema(${jsonEncode(schema)}, "objSchema");
        ajv;
      """;
    return jsRuntime.evaluate(code);
  }

  Map<String, List<ValidationResult>> validate(Map<String, dynamic> data) {
    final code = """
        ajv.validate("objSchema",${json.encode(data)});
        JSON.stringify(ajv.errors);
      """;
    final jsResult = jsRuntime.evaluate(code);

    final valueResult = json.decode(jsResult.stringResult);
    final errorList = ValidationResult.listFromJson(
        valueResult is int ? [] : valueResult ?? []);

    Map<String, List<ValidationResult>> errorMap = {};
    for (var error in errorList) {
      if (error.keyword == 'required') {
        final fieldKey = error.params['missingProperty'];
        if (fieldKey != null) {
          errorMap[fieldKey] = [...(errorMap[fieldKey] ?? []), error];
        }
      }

      if (error.dataPath != null) {
        final resultArr = error.dataPath?.split('.') ?? [];
        final fieldKey = resultArr.length > 1 ? resultArr.last : null;
        if (fieldKey != null) {
          errorMap[fieldKey] = [...(errorMap[fieldKey] ?? []), error];
        }
      }
    }

    return errorMap;
  }

  Map<String, List<ValidationResult>> validateWithSchema(
    Map<String, dynamic> schema,
    Map<String, dynamic> data,
  ) {
    registerSchema(schema);
    return validate(data);
  }

  void dispose() {
    jsRuntime.dispose();
  }
}
