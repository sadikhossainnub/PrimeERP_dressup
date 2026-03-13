import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/frappe_remote_ds.dart';
import '../../../core/network/dio_client.dart';

import '../repositories/frappe_repository_impl.dart';
import '../../domain/repositories/frappe_repository.dart';

final frappeRemoteDsProvider = Provider<FrappeRemoteDataSource>((ref) {
  return FrappeRemoteDataSource(ref.watch(dioProvider));
});

final frappeRepositoryProvider = Provider<FrappeRepository>((ref) {
  return FrappeRepositoryImpl(ref.watch(frappeRemoteDsProvider));
});
