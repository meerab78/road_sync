import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model.dart';
import '../service/service.dart';
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

final settingsProvider = StreamProvider.autoDispose<UserSettings>((ref) {
  SettingsService service = ref.watch(settingsServiceProvider);
  return service.watchSettings();
});

// State = error message ('' matlab sab theek)
class SettingsController extends Notifier<String> {
  @override
  String build() {
    return '';
  }

  Future<void> saveEmergencyContact(String name, String number) async {
    try {
      await ref
          .read(settingsServiceProvider)
          .saveEmergencyContact(name, number);
      state = '';
    } catch (e) {
      state = e.toString();
    }
  }

  Future<void> saveRadius(int radius) async {
    try {
      await ref.read(settingsServiceProvider).saveRadius(radius);
      state = '';
    } catch (e) {
      state = e.toString();
    }
  }

  Future<void> saveNotifications(bool value) async {
    try {
      await ref.read(settingsServiceProvider).saveNotifications(value);
      state = '';
    } catch (e) {
      state = e.toString();
    }
  }
}

final settingsControllerProvider =
NotifierProvider<SettingsController, String>(() {
  return SettingsController();
});