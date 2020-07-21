import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_tqr/domain_model.dart' as tq;

class SettingsModel extends ChangeNotifier {
  // The names of excluded quests
  Set<String> _excludedQuests = new Set();

  HeroSelectionStrategy _heroStrategy = heroStrategies[0];

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

  HeroSelectionStrategy get heroSelectionStrategy => _heroStrategy;
  set heroSelectionStrategy(HeroSelectionStrategy strategy) {
    if (_heroStrategy != strategy) {
      _heroStrategy = strategy;
      notifyListeners();
    }
  }

  static final List<HeroSelectionStrategy> heroStrategies = [
    OnePerClassHeroSelectionStrategy(),
    FirstMatchHeroSelectionStrategy(),
    RandomHeroSelectionStrategy()
  ];
}

abstract class HeroSelectionStrategy {
  static final classes = ['Fighter', 'Rogue', 'Cleric', 'Wizard'];
  final Random _random = new Random();
  List<tq.Hero> selectHeroesFrom(List<tq.Hero> availableHeroes);
  String get name;

  int compareHeroes(hero1, hero2) => hero1.name.compareTo(hero2.name);
}

// Selects the first four heroes that match the criteria that there
// is at least one of each class.
class FirstMatchHeroSelectionStrategy extends HeroSelectionStrategy {
  String get name => 'First Match';

  List<tq.Hero> selectHeroesFrom(List<tq.Hero> availableHeroes) {
    // Try a random set of four
    Set<tq.Hero> result = new Set();

    while (result.length < 4) {
      int index = _random.nextInt(availableHeroes.length);
      var hero = availableHeroes[index];
      result.add(hero);
    }

    // If we have all the classes, we're done.
    // If not, recursively try again.
    if (result
        .map((hero) => hero.keywords)
        .expand((element) => element)
        .toSet()
        .containsAll(HeroSelectionStrategy.classes)) {
      List<tq.Hero> heroes = result.toList();
      return heroes..sort(compareHeroes);
    } else {
      return selectHeroesFrom(availableHeroes);
    }
  }
}

class RandomHeroSelectionStrategy extends HeroSelectionStrategy {
  String get name => 'Unconstrained';
  @override
  List<tq.Hero> selectHeroesFrom(List<tq.Hero> availableHeroes) {
    availableHeroes.shuffle();
    return availableHeroes.take(4).toList();
  }
}

class OnePerClassHeroSelectionStrategy extends HeroSelectionStrategy {
  String get name => 'One per class';
  @override
  List<tq.Hero> selectHeroesFrom(List<tq.Hero> availableHeroes) {
    List<tq.Hero> result = new List();
    print(availableHeroes);
    HeroSelectionStrategy.classes
      ..shuffle() // Mix up what we look for first
      ..forEach((element) {
        List<tq.Hero> heroesOfClass = availableHeroes
            .where((hero) => hero.keywords.contains(element))
            .toList();
        var hero;
        do {
          hero = heroesOfClass[_random.nextInt(heroesOfClass.length)];
          print('Hero is ${hero.name}');
        } while (result.contains(hero));
        result.add(hero);
      });
    return result..sort(compareHeroes);
  }
}
