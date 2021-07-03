import 'package:flutter_tqr/models/settings.dart';
import 'package:test/test.dart';

void main() {
  test('Preferences accessor has been generated through source-gen', () {
    var settings = SettingsModel();
    expect(settings.allPrefs.length, isNot(0));
  });
}
