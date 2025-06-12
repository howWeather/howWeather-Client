import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedDayProvider = StateProvider<DateTime?>((ref) => null);
final selectedTimeProvider = StateProvider<int?>((ref) => null);

extension ProviderHelper on WidgetRef {
  void resetCalendarProviders() {
    read(selectedDayProvider.notifier).state = null;
    read(selectedTimeProvider.notifier).state = null;
  }
}
