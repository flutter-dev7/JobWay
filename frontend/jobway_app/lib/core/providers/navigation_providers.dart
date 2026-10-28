import 'package:flutter_riverpod/flutter_riverpod.dart';

// Запрос переключить вкладку на главном экране (индекс вкладки).
// HomePage обрабатывает его и сбрасывает обратно в null
final homeTabRequestProvider = StateProvider<int?>((ref) => null);