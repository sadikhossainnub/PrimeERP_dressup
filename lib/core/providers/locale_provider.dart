import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = StateProvider<Locale>((ref) {
  return const Locale('en');
});

extension LocaleToggle on WidgetRef {
  void toggleLocale() {
    final current = read(localeProvider);
    if (current.languageCode == 'en') {
      read(localeProvider.notifier).state = const Locale('bn');
    } else {
      read(localeProvider.notifier).state = const Locale('en');
    }
  }
}
