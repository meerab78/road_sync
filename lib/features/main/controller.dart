import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainController extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void changeTab(int index) {
    state = index;
  }
}

final mainControllerProvider = NotifierProvider<MainController, int>(() {
  return MainController();
});