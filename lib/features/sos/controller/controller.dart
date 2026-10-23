import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadsync/features/settings/controller/controller.dart';
import 'package:roadsync/features/settings/model.dart';
import '../service/service.dart';

final sosServiceProvider = Provider<SosService>((ref) {
  return SosService();
});

class SosController extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  // Sab theek ho to '' wapas, warna error message
  Future<String> sendSos(bool viaWhatsapp) async {
    state = true;

    try {
      UserSettings settings =
      await ref.read(settingsServiceProvider).getSettings();

      if (settings.emergencyNumber == '') {
        state = false;
        return 'Please set your emergency contact in Settings first';
      }

      SosService service = ref.read(sosServiceProvider);

      if (viaWhatsapp) {
        await service.openWhatsapp(
          number: settings.emergencyNumber,
          name: settings.name,
        );
      } else {
        await service.sendSms(
          number: settings.emergencyNumber,
          name: settings.name,
        );
      }

      state = false;
      return '';
    } catch (e) {
      state = false;
      return e.toString().replaceFirst('Exception: ', '');
    }
  }
}

final sosControllerProvider = NotifierProvider<SosController, bool>(() {
  return SosController();
});