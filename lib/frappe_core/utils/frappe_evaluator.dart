class FrappeEvaluator {
  /// Evaluates simple Frappe "eval:" expressions
  /// Supports:
  /// - Equality: eval:doc.status == 'Open'
  /// - Inequality: eval:doc.status != 'Closed'
  /// - Greater/Less than: eval:doc.amount > 1000
  /// - In list: eval:in_list(doc.type, ['A', 'B'])
  /// - Logical AND/OR: eval:doc.status == 'Open' && doc.type == 'Request'
  static bool evaluate(String expr, Map<String, dynamic> doc) {
    if (!expr.startsWith('eval:')) {
      return false; // Only parse "eval:" strings safely
    }

    String expression = expr.substring(5).trim();
    if (expression.isEmpty) return false;

    // Split by Logical OR '||' or 'or'
    if (expression.contains('||')) {
      return expression.split('||').any((e) => _evalCondition(e.trim(), doc));
    }
    if (expression.contains(' or ')) {
      return expression.split(' or ').any((e) => _evalCondition(e.trim(), doc));
    }

    // Split by Logical AND '&&' or 'and'
    if (expression.contains('&&')) {
      return expression.split('&&').every((e) => _evalCondition(e.trim(), doc));
    }
    if (expression.contains(' and ')) {
      return expression
          .split(' and ')
          .every((e) => _evalCondition(e.trim(), doc));
    }

    return _evalCondition(expression, doc);
  }

  static bool _evalCondition(String condition, Map<String, dynamic> doc) {
    condition = condition.trim();

    // Check for in_list
    final inListMatch = RegExp(
      r"in_list\(([^,]+),\s*\[(.*?)\]\)",
    ).firstMatch(condition);
    if (inListMatch != null) {
      final field = inListMatch.group(1)?.trim() ?? '';
      final arrayStr = inListMatch.group(2) ?? '';

      final fieldValue = _getFieldValue(field, doc);
      if (fieldValue == null) return false;

      // Extract values from array string (e.g. 'A', "B", 'C')
      final listValues = RegExp(
        r"['"
                '"' +
            r"](.*?)['" +
            '"' +
            r"]",
      ).allMatches(arrayStr).map((m) => m.group(1)).toList();

      return listValues.contains(fieldValue.toString());
    }

    // Simple comparison
    final opMatch = RegExp(
      r"(==|!=|>=|<=|>|<|in|not in)",
    ).firstMatch(condition);
    if (opMatch == null) {
      // It might be a simple boolean check e.g. "eval:doc.is_return"
      final val = _getFieldValue(condition, doc);
      if (val is bool) return val;
      if (val is int || val is double) return val != 0;
      if (val is String) return val.isNotEmpty;
      return val != null;
    }

    final op = opMatch.group(0)!;
    final parts = condition.split(op);
    if (parts.length != 2) return false;

    final leftStr = parts[0].trim();
    final rightStr = parts[1].trim();

    final leftVal = _resolveValue(leftStr, doc);
    final rightVal = _resolveValue(rightStr, doc);

    if (leftVal == null && rightVal == null) return op == '==';

    switch (op) {
      case '==':
        return leftVal.toString() == rightVal.toString();
      case '!=':
        return leftVal.toString() != rightVal.toString();
      case '>':
        return _compare(leftVal, rightVal) > 0;
      case '<':
        return _compare(leftVal, rightVal) < 0;
      case '>=':
        return _compare(leftVal, rightVal) >= 0;
      case '<=':
        return _compare(leftVal, rightVal) <= 0;
      case 'in':
        if (rightVal is List) return rightVal.contains(leftVal);
        if (rightVal is String) return rightVal.contains(leftVal.toString());
        return false;
      case 'not in':
        if (rightVal is List) return !rightVal.contains(leftVal);
        if (rightVal is String) return !rightVal.contains(leftVal.toString());
        return true;
      default:
        return false;
    }
  }

  static dynamic _resolveValue(String str, Map<String, dynamic> doc) {
    if (str.startsWith("'") && str.endsWith("'"))
      return str.substring(1, str.length - 1);
    if (str.startsWith('"') && str.endsWith('"'))
      return str.substring(1, str.length - 1);
    if (num.tryParse(str) != null) return num.parse(str);
    if (str == 'true' || str == 'True') return true;
    if (str == 'false' || str == 'False') return false;
    if (str == 'null' || str == 'None') return null;

    if (str.startsWith('doc.')) {
      return _getFieldValue(str, doc);
    }

    // Default to resolving as field name if no quotes but it's not a number
    return _getFieldValue(str, doc);
  }

  static dynamic _getFieldValue(String fieldPath, Map<String, dynamic> doc) {
    final cleanPath = fieldPath.startsWith('doc.')
        ? fieldPath.substring(4)
        : fieldPath;
    final parts = cleanPath.split('.');

    dynamic current = doc;
    for (final part in parts) {
      if (current is Map && current.containsKey(part)) {
        current = current[part];
      } else {
        return null;
      }
    }
    return current;
  }

  static int _compare(dynamic a, dynamic b) {
    if (a is num && b is num) return a.compareTo(b);
    return a.toString().compareTo(b.toString());
  }
}
