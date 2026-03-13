import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:hive/hive.dart';
import '../../data/models/doctype_meta_model.dart';
import '../../data/providers/frappe_provider.dart';
import '../../../core/constants/app_constants.dart';

final docTypeMetaProvider = FutureProvider.family<DocTypeMetaModel, String>((ref, doctype) async {
  final box = await Hive.openBox(AppConstants.hiveMetaBox);
  
  // 1. Check Cache
  final cached = box.get(doctype);
  if (cached != null) {
    return DocTypeMetaModel.fromJson(jsonDecode(cached as String));
  }

  // 2. Fetch from Remote
  final ds = ref.watch(frappeRemoteDsProvider);
  final data = await ds.getDocTypeMeta(doctype);
  final meta = DocTypeMetaModel.fromJson(data);

  // 3. Save to Cache
  await box.put(doctype, jsonEncode(meta.toJson()));

  return meta;
});
