import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/frappe_provider.dart';

final frappeDocProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, arg) async {
  final parts = arg.split('|');
  final doctype = parts[0];
  final name = parts[1];
  
  final ds = ref.watch(frappeRemoteDsProvider);
  return await ds.getDoc(doctype, name);
});

final workflowTransitionsProvider = FutureProvider.family<List<dynamic>, String>((ref, arg) async {
  final ds = ref.watch(frappeRemoteDsProvider);
  
  // We need the document data to get transitions
  final docAsync = ref.watch(frappeDocProvider(arg));
  
  return docAsync.when(
    data: (doc) async {
       return await ds.getWorkflowTransitions(doc);
    },
    loading: () => [],
    error: (e, stack) => [],
  );
});
