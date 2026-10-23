import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadsync/features/home/service.dart';

final homeServiceProvider = Provider<HomeService>((ref) {
  return HomeService();
});

final userNameProvider = StreamProvider.autoDispose<String>((ref) {
  HomeService service = ref.watch(homeServiceProvider);
  return service.getUserNameStream();
});