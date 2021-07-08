import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class Preference<T> extends ChangeNotifier {
  final String key;
  Preference({required this.key});

  /// Reset this preference to its default value.
  reset();
}

class StringSetPreference extends Preference<Set<String>> {
  Set<String> _excludedQuests = Set();

  StringSetPreference({required key}) : super(key: key);

  // The accessor and mutator are needed for code generation,
  // even though client code should not call them.
  Set<String> get value => throw UnsupportedError('Cannot get value this way');
  set value(Set<String> value) =>
      throw UnsupportedError('Cannot set the value this way.');

  bool includes(String name) => !excludes(name);

  bool excludes(String name) => _excludedQuests.contains(name);

  void exclude(String name) {
    bool isNewExclusion = _excludedQuests.add(name);
    if (isNewExclusion) {
      _updatePrefs();
      notifyListeners();
    }
  }

  void include(String name) {
    bool changed = _excludedQuests.remove(name);
    if (changed) {
      _updatePrefs();
      notifyListeners();
    }
  }

  void _updatePrefs() async {
    var preferences = await SharedPreferences.getInstance();
    // If the user's preference is not the default value, record it.
    // Otherwise, just clear it from storage, because the default is used.
    if (_excludedQuests.isEmpty) {
      preferences.remove(key);
    } else {
      preferences.setStringList(key, _excludedQuests.toList());
    }
  }

  @override
  reset() {
    _excludedQuests = Set();
    _updatePrefs();
  }
}

class BoolPreference extends Preference<bool> {
  final bool defaultValue;
  bool _value;

  BoolPreference({required key, required this.defaultValue})
      : _value = defaultValue,
        super(key: key) {
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

  BrightnessPreference({required key, required defaultValue})
      : super(key: key) {
    _delegate = BoolPreference(key: key, defaultValue: defaultValue);
    _delegate.addListener(() => notifyListeners());
  }

  Brightness get value => _delegate.value ? Brightness.light : Brightness.dark;
  set value(Brightness value) => _delegate.value = value == Brightness.light;

  reset() => _delegate.reset();
}
