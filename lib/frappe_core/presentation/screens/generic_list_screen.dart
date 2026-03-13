import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../../l10n/app_localizations.dart';
import '../../data/providers/frappe_provider.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/meta_provider.dart';
import '../providers/permission_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class GenericListScreen extends ConsumerStatefulWidget {
  final String doctype;

  const GenericListScreen({super.key, required this.doctype});

  @override
  ConsumerState<GenericListScreen> createState() => _GenericListScreenState();
}

class _GenericListScreenState extends ConsumerState<GenericListScreen> {
  static const _pageSize = 20;
  String _searchQuery = '';
  final PagingController<int, Map<String, dynamic>> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final ds = ref.read(frappeRemoteDsProvider);
      final List<List<dynamic>>? filters = _searchQuery.isNotEmpty
          ? [
              ['name', 'like', '%$_searchQuery%'],
            ]
          : null;

      final items = await ds.getList(
        widget.doctype,
        fields: ['*'],
        limitStart: pageKey,
        limitPageLength: _pageSize,
        filters: filters,
      );
      final isLastPage = items.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(items);
      } else {
        final nextPageKey = pageKey + items.length;
        _pagingController.appendPage(items, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final metaAsync = ref.watch(docTypeMetaProvider(widget.doctype));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.doctype),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/resource/${widget.doctype}/new'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search ${widget.doctype}...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
                _pagingController.refresh();
              },
            ),
          ),
        ),
      ),
      floatingActionButton: ref
          .watch(userPermissionsProvider(widget.doctype))
          .when(
            data: (perms) {
              if (perms.canCreate == true) {
                return FloatingActionButton(
                  onPressed: () =>
                      context.push('/resource/${widget.doctype}/new'),
                  backgroundColor: AppTheme.primaryColor,
                  child: const Icon(Icons.add, color: Colors.white),
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (err, stack) => const SizedBox.shrink(),
          ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: metaAsync.when(
        data: (meta) => PagedListView<int, Map<String, dynamic>>(
          pagingController: _pagingController,
          padding: const EdgeInsets.all(16),
          builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
            itemBuilder: (context, item, index) =>
                _buildListItem(item, meta, l10n),
            firstPageProgressIndicatorBuilder: (_) => const LoadingWidget(),
            newPageProgressIndicatorBuilder: (_) => const LoadingWidget(),
            noItemsFoundIndicatorBuilder: (_) =>
                Center(child: Text(l10n.noRecordsFound)),
          ),
        ),
        loading: () => const LoadingWidget(),
        error: (err, _) => ErrorStateWidget(message: err.toString()),
      ),
    );
  }

  Widget _buildListItem(
    Map<String, dynamic> item,
    meta,
    AppLocalizations l10n,
  ) {
    final title = _getTitle(item, meta);
    final subtitle = _getSubtitle(item, meta);
    final status = item['status']?.toString();
    final amount = _getAmount(item, meta);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.dividerColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () =>
            context.push('/resource/${widget.doctype}/${item['name']}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (status != null) _buildStatusBadge(status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (amount != null)
                    Text(
                      amount,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (item['modified'] != null)
                Text(
                  '${l10n.modified}: ${DateFormat.yMMMd().format(DateTime.parse(item['modified'].toString()))}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTitle(Map<String, dynamic> item, meta) {
    if (meta.titleField != null && item[meta.titleField] != null) {
      return item[meta.titleField].toString();
    }
    return item['name'] ?? 'No Name';
  }

  String _getSubtitle(Map<String, dynamic> item, meta) {
    // Priority fields for subtitle based on common ERPNext patterns
    final fields = [
      'customer_name',
      'supplier_name',
      'item_name',
      'subject',
      'title',
    ];
    for (var f in fields) {
      if (item[f] != null && f != meta.titleField) {
        return item[f].toString();
      }
    }
    return item['owner'] ?? '';
  }

  String? _getAmount(Map<String, dynamic> item, meta) {
    // Common amount fields
    final amountFields = [
      'grand_total',
      'total_amount',
      'base_grand_total',
      'rounded_total',
      'amount',
    ];
    for (var f in amountFields) {
      if (item[f] != null) {
        final val = double.tryParse(item[f].toString()) ?? 0.0;
        final currency = item['currency']?.toString() ?? 'USD';
        return NumberFormat.currency(symbol: '$currency ').format(val);
      }
    }
    return null;
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    switch (status.toLowerCase()) {
      case 'completed':
      case 'closed':
      case 'paid':
      case 'submitted':
      case 'active':
        color = Colors.green;
        break;
      case 'pending':
      case 'draft':
      case 'open':
      case 'unpaid':
        color = Colors.orange;
        break;
      case 'cancelled':
      case 'overdue':
      case 'failed':
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
