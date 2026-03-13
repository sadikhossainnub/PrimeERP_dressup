import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../frappe_core/data/providers/frappe_provider.dart';
import '../models/notification_model.dart';

final notificationsProvider = FutureProvider<List<NotificationItem>>((ref) async {
  final repository = ref.watch(frappeRepositoryProvider);

  try {
    final list = await repository.getList(
      'Notification Log',
      fields: [
        'name',
        'subject',
        'email_content',
        'document_type',
        'document_name',
        'from_user',
        'read',
        'creation',
      ],
      limitPageLength: 50,
      orderBy: 'creation desc',
    );

    return list.map((json) => NotificationItem.fromJson(json)).toList();
  } catch (e) {
    throw Exception('Failed to load notifications: $e');
  }
});
