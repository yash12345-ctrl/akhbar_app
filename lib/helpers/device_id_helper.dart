import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceIdHelper {
  static const String _uuidKey = 'guest_device_uuid';

  static Future<String> getDeviceId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uuid = prefs.getString(_uuidKey);

    if (uuid == null) {
      uuid = const Uuid().v4();
      await prefs.setString(_uuidKey, uuid);
    }

    return uuid;
  }
}
