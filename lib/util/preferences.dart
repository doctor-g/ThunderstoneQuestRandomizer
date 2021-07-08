import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class Preference<T> extends ChangeNotifier {
  final T defaultValue;
  final String key;

  /// The value of this preference.
  ///
  /// Subclasses must initialize this in their constructors.
  late T _value;

  Preference({required this.key, required this.defaultValue}) {
    _value = defaultValue;
    _initializeFromUserPreferences();
  }

  _initializeFromUserPreferences() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(key)) {
      value = _loadFrom(prefs);
    }
  }

  /// Read the value of this preference from the given preferences object.
  ///
  /// When this is called, the presence of the key has already been checked.
  T _loadFrom(SharedPreferences prefs);

  /// Reset this preference to its default value.
  reset() {
    value = defaultValue;
  }

  T get value => _value;
  set value(T value) {
    _value = value;
    notifyListeners();
    _updatePrefs();
  }

  void _updatePrefs() async {
    var preferences = await SharedPreferences.getInstance();
    // If the user's preference is not the default value, record it.
    // Otherwise, just clear it from storage, because the default is used.
    if (value != defaultValue) {
      _writeValue(preferences);
    } else {
      preferences.remove(key);
    }
  }

  /// Write this preference's value to the preferences store.
  _writeValue(SharedPreferences prefs);
}

class BoolPreference extends Preference<bool> {
  BoolPreference({required key, required defaultValue})
      : super(key: key, defaultValue: defaultValue);

  @override
  bool _loadFrom(SharedPreferences prefs) => prefs.getBool(key)!;

  @override
  _writeValue(SharedPreferences prefs) => prefs.setBool(key, value);
}

class IntPreference extends Preference<int> {
  IntPreference({required key, required defaultValue})
      : super(key: key, defaultValue: defaultValue);

  @override
  int _loadFrom(SharedPreferences prefs) => prefs.getInt(key)!;

  @override
  _writeValue(SharedPreferences prefs) => prefs.setInt(key, value);
}

class BrightnessPreference extends Preference<Brightness> {
  BrightnessPreference({required key, required defaultValue})
      : super(key: key, defaultValue: defaultValue);

  @override
  Brightness _loadFrom(SharedPreferences prefs) =>
      prefs.getBool(key)! ? Brightness.light : Brightness.dark;

  @override
  _writeValue(SharedPreferences prefs) =>
      prefs.setBool(key, value == Brightness.light);
}

class StringSetPreference extends Preference<Set<String>> {
  StringSetPreference({required key}) : super(key: key, defaultValue: Set());

  /// Get the list of excluded names.
  ///
  /// This could be simply `_value`, but this alias increases readability.
  Set<String> get _excludedNames => _value;

  bool includes(String name) => !excludes(name);

  bool excludes(String name) => _excludedNames.contains(name);

  void exclude(String name) {
    bool isNewExclusion = _excludedNames.add(name);
    if (isNewExclusion) {
      _updatePrefs();
      notifyListeners();
    }
  }

  void include(String name) {
    bool isNewInclusion = _excludedNames.remove(name);
    if (isNewInclusion) {
      _updatePrefs();
      notifyListeners();
    }
  }

  void _updatePrefs() async {
    var preferences = await SharedPreferences.getInstance();
    // If the user's preference is not the default value, record it.
    // Otherwise, just clear it from storage, because the default is used.
    if (_excludedNames.isEmpty) {
      preferences.remove(key);
    } else {
      preferences.setStringList(key, _excludedNames.toList());
    }
  }

  @override
  Set<String> _loadFrom(SharedPreferences prefs) =>
      prefs.getStringList(key)!.toSet();

  @override
  _writeValue(SharedPreferences prefs) =>
      prefs.setStringList(key, _excludedNames.toList());
}
