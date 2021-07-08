import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class Preference<T> extends ChangeNotifier {
  /// Reset this preference to its default value.
  reset();
}

class BoolPreference extends Preference<bool> {
  final String key;
  final bool defaultValue;
  bool _value;

  BoolPreference({required this.key, required this.defaultValue})
      : _value = defaultValue {
    _loadFromSharedPreferences();
  }

  bool get value => _value;
  set value(value) {
    _value = value;
    notifyListeners();
    _updatePrefs();
  }

  void _updatePrefs() async {
    var preferences = await SharedPreferences.getInstance();
    // If the user's preference is not the default value, record it.
    // Otherwise, just clear it from storage, because the default is used.
    if (value != defaultValue) {
      preferences.setBool(key, value);
    } else {
      preferences.remove(key);
    }
  }

  /// Read the value of this preference from the shared preferences.
  _loadFromSharedPreferences() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(key)) {
      _value = prefs.getBool(key)!;
    }
  }

  /// Set to its default value
  reset() {
    value = defaultValue;
  }
}

class BrightnessPreference extends Preference<Brightness> {
  late final BoolPreference _delegate;

  BrightnessPreference({required key, required defaultValue}) {
    _delegate = BoolPreference(key: key, defaultValue: defaultValue);
    _delegate.addListener(() => notifyListeners());
  }

  Brightness get value => _delegate.value ? Brightness.light : Brightness.dark;
  set value(Brightness value) => _delegate.value = value == Brightness.light;

  reset() => _delegate.reset();
}
