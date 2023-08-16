import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tqr/models/settings.dart';

void main() {
  test('Preferences accessor has been generated through source-gen', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    var settings = SettingsModel();
    expect(settings.allPrefs.length, isNot(0));
  });
}
