import 'package:flutter/cupertino.dart';

import 'package:flutter/foundation.dart';

class SettingsModel extends ChangeNotifier {
  // The names of excluded quests
  Set<String> _excludedQuests = new Set();

  bool includes(String questName) {
    return !excludes(questName);
  }

  bool excludes(String questName) {
    return _excludedQuests.contains(questName);
  }

  void exclude(String questName) {
    bool newExclusion = _excludedQuests.add(questName);
    if (newExclusion) {
      notifyListeners();
    }
  }

  void include(String questName) {
    bool changed = _excludedQuests.remove(questName);
    if (changed) {
      notifyListeners();
    }
  }
}
