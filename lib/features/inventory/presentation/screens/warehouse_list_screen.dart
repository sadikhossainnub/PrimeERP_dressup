import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/inventory_provider.dart';

class WarehouseListScreen extends ConsumerWidget {
  const WarehouseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final whAsync = ref.watch(warehouseListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        title: const Text('Warehouses'),
        backgroundColor: const Color(0xFF1E2A38),
        foregroundColor: Colors.white,
      ),
      body: whAsync.when(
        data: (warehouses) {
          if (warehouses.isEmpty) return const Center(child: Text('No warehouses found.'));
          
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: warehouses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final wh = warehouses[index];
              final name = wh['name']?.toString() ?? '';
              final isGroup = (wh['is_group'] as num?)?.toInt() == 1;

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE5E7EB))),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: isGroup ? const Color(0xFF3B82F6).withValues(alpha: 0.1) : const Color(0xFF10B981).withValues(alpha: 0.1),
                    child: Icon(isGroup ? Icons.folder_outlined : Icons.warehouse_outlined, color: isGroup ? const Color(0xFF3B82F6) : const Color(0xFF10B981)),
                  ),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  subtitle: isGroup ? const Text('Group Warehouse', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))) : null,
                  trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
