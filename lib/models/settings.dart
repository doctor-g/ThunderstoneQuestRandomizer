import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tqr/models/database.dart' as tq;
import 'package:flutter/foundation.dart';
import 'package:flutter_tqr/models/tableau.dart';
import 'package:flutter_tqr/util/tableau_failure.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database.dart';

class SettingsModel extends ChangeNotifier {
  static final String _excludedQuestsKey = 'exclude';
  static final String _heroStrategyIndexKey = 'heroStrategyIndex';
  static final String _comboBiasKey = 'comboBias';
  static final String _showMemoKey = 'showMemo';
  static final String _showKeywordsKey = 'showKeywords';
  static final String _showQuestKey = 'showQuest';
  static final String _brightnessKey = 'lightMode';
  static final String _barricadesModeKey = 'barricadesMode';
  static final String _soloModeKey = 'soloMode';

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // The names of excluded quests
  Set<String> _excludedQuests = new Set();

  int _heroStrategyIndex = 0;

  SettingsModel() {
    _loadPrefs();
  }

  void _loadPrefs() async {
    _prefs.then((prefs) {
      if (prefs.containsKey(_excludedQuestsKey)) {
        _excludedQuests = prefs.getStringList(_excludedQuestsKey)!.toSet();
      }
      if (prefs.containsKey(_heroStrategyIndexKey)) {
        _heroStrategyIndex = prefs.getInt(_heroStrategyIndexKey)!;
      }
      if (prefs.containsKey(_comboBiasKey)) {
        _comboBias = prefs.getDouble(_comboBiasKey)!;
      }
      if (prefs.containsKey(_showMemoKey)) {
        _showMemo = prefs.getBool(_showMemoKey)!;
      }
      if (prefs.containsKey(_showKeywordsKey)) {
        _showKeywords = prefs.getBool(_showKeywordsKey)!;
      }
      if (prefs.containsKey(_showQuestKey)) {
        _showQuest = prefs.getBool(_showQuestKey)!;
      }
      if (prefs.containsKey(_brightnessKey)) {
        _brightness =
            prefs.getBool(_brightnessKey)! ? Brightness.light : Brightness.dark;
      }
      if (prefs.containsKey(_barricadesModeKey)) {
        _barricadesMode = prefs.getBool(_barricadesModeKey)!;
      }
      if (prefs.containsKey(_soloModeKey)) {
        _soloMode = prefs.getBool(_soloModeKey)!;
      }
      notifyListeners();
    });
  }

  void clear() {
    _prefs.then((prefs) => prefs.clear());
    _excludedQuests = new Set();
    _heroStrategyIndex = 0;
    _comboBias = 0.5;
    _showMemo = true;
    _showKeywords = true;
    _showQuest = false;
    _brightness = Brightness.light;
    _barricadesMode = false;
    notifyListeners();
  }

  bool includes(Quest quest) => !excludes(quest);

  bool excludes(Quest quest) => _excludedQuests.contains(quest.canonicalName);

  void exclude(Quest quest) {
    bool isNewExclusion = _excludedQuests.add(quest.canonicalName);
    if (isNewExclusion) {
      _updatePrefs();
      notifyListeners();
    }
  }

  void include(Quest quest) {
    bool changed = _excludedQuests.remove(quest.canonicalName);
    if (changed) {
      _updatePrefs();
      notifyListeners();
    }
  }

  void _updatePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(_excludedQuestsKey, _excludedQuests.toList());
    prefs.setInt(_heroStrategyIndexKey, _heroStrategyIndex);
    prefs.setDouble(_comboBiasKey, _comboBias);
    prefs.setBool(_showKeywordsKey, _showKeywords);
    prefs.setBool(_showMemoKey, _showMemo);
    prefs.setBool(_showQuestKey, _showQuest);
    prefs.setBool(_brightnessKey, _brightness == Brightness.light);
    prefs.setBool(_barricadesModeKey, _barricadesMode);
    prefs.setBool(_soloModeKey, _soloMode);
  }

  HeroSelectionStrategy get heroSelectionStrategy =>
      heroStrategies[_heroStrategyIndex];
  set heroSelectionStrategy(HeroSelectionStrategy strategy) {
    if (heroSelectionStrategy != strategy) {
      _heroStrategyIndex = heroStrategies.indexOf(strategy);
      notifyListeners();
      _updatePrefs();
    }
  }

  // For now, just return the one that is implemented
  MarketSelectionStrategy get marketSelectionStrategy =>
      FirstFitMarketSelectionStrategy();

  double _comboBias = 0.5;
  double get comboBias => _comboBias;
  set comboBias(var value) {
    if (value < 0 || value > 1) {
      throw Exception('Illegal combo bias value: $value must be in [0,1]');
    }
    _comboBias = value;
    _updatePrefs();
    notifyListeners();
  }

  bool _showMemo = true;
  bool get showMemo => _showMemo;
  set showMemo(bool value) {
    _showMemo = value;
    _updatePrefs();
    notifyListeners();
  }

  bool _showKeywords = true;
  bool get showKeywords => _showKeywords;
  set showKeywords(bool value) {
    _showKeywords = value;
    _updatePrefs();
    notifyListeners();
  }

  bool _showQuest = false;
  bool get showQuest => _showQuest;
  set showQuest(bool value) {
    _showQuest = value;
    _updatePrefs();
    notifyListeners();
  }

  Brightness _brightness = Brightness.light;
  Brightness get brightness => _brightness;
  set brightness(Brightness value) {
    _brightness = value;
    _updatePrefs();
    notifyListeners();
  }

  bool _barricadesMode = false;
  bool get barricadesMode => _barricadesMode;
  set barricadesMode(bool value) {
    _barricadesMode = value;
    _updatePrefs();
    notifyListeners();
  }

  bool _soloMode = false;
  bool get soloMode => _soloMode;
  set soloMode(bool value) {
    _soloMode = value;
    _updatePrefs();
    notifyListeners();
  }

  static final List<HeroSelectionStrategy> heroStrategies = [
    OnePerClassHeroSelectionStrategy(),
    FirstMatchHeroSelectionStrategy(),
    RandomHeroSelectionStrategy()
  ];
}

abstract class Strategy {
  final Random _random = new Random();
  String get name;
}

abstract class HeroSelectionStrategy extends Strategy {
  static final classes = ['Fighter', 'Rogue', 'Cleric', 'Wizard'];
  List<tq.Hero> selectHeroesFrom(List<tq.Hero> availableHeroes);
  String get name;
}

// Selects the first four heroes that match the criteria that there
// is at least one of each class.
class FirstMatchHeroSelectionStrategy extends HeroSelectionStrategy {
  String get name => 'First Match';

  final maxTries = 10;

  @override
  List<tq.Hero> selectHeroesFrom(List<tq.Hero> availableHeroes) {
    if (availableHeroes.length < 4) {
      throw new TableauFailureException(
          'Not enough heroes: ${availableHeroes.length}');
    }

    int tries = 0;
    for (;;) {
      try {
        return _doSelection(availableHeroes);
      } on TableauFailureException catch (e) {
        tries++;
        if (tries >= maxTries) {
          throw e;
        }
      }
    }
  }

  List<tq.Hero> _doSelection(List<tq.Hero> availableHeroes) {
    // Try a random set of four
    Set<tq.Hero> result = new Set();

    while (result.length < 4) {
      int index = _random.nextInt(availableHeroes.length);
      var hero = availableHeroes[index];
      result.add(hero);
    }

    // If we have all the classes, we're done.
    // If not, throw an exception
    if (result
        .map((hero) => hero.keywords)
        .expand((element) => element)
        .toSet()
        .containsAll(HeroSelectionStrategy.classes)) {
      List<tq.Hero> heroes = result.toList();
      return heroes;
    } else {
      throw TableauFailureException('Could not find a class match');
    }
  }
}

// There are no constraints on this strategy: it just picks
// completely at random.
class RandomHeroSelectionStrategy extends HeroSelectionStrategy {
  String get name => 'Unconstrained';
  @override
  List<tq.Hero> selectHeroesFrom(List<tq.Hero> availableHeroes) {
    if (availableHeroes.length < 4) {
      print('Short stuff');
      throw new TableauFailureException('Not enough heroes to choose from.');
    }
    availableHeroes.shuffle();
    return availableHeroes.take(4).toList();
  }
}

// Each class has at least one hero. This is the selection strategy
// from the rulebook.
class OnePerClassHeroSelectionStrategy extends HeroSelectionStrategy {
  String get name => 'Traditional';
  @override
  List<tq.Hero> selectHeroesFrom(List<tq.Hero> availableHeroes) {
    List<tq.Hero> result = [];
    HeroSelectionStrategy.classes
      ..shuffle() // Mix up what we look for first
      ..forEach((element) {
        List<tq.Hero> heroesOfClass = availableHeroes
            .where((hero) => hero.keywords.contains(element))
            .toList();

        // If there are no heroes of this class, or if they are
        // all already selected, then it's a failure.
        if (heroesOfClass.length == 0 ||
            result.toSet().containsAll(heroesOfClass)) {
          throw TableauFailureException('Cannot pick heroes.');
        }

        var hero;
        do {
          hero = heroesOfClass[_random.nextInt(heroesOfClass.length)];
        } while (result.contains(hero));
        result.add(hero);
      });
    return result;
  }
}

abstract class MarketSelectionStrategy extends Strategy {
  Marketplace selectMarketCardsFrom(List<tq.Card> availableMarketCards,
      double comboBias, final Tableau tableau);
}

class FirstFitMarketSelectionStrategy extends MarketSelectionStrategy {
  @override
  String get name => 'First Fit (Supports Allies)';

  @override
  Marketplace selectMarketCardsFrom(List<tq.Card> availableMarketCards,
      double comboBias, final Tableau tableau) {
    Random random = Random();
    Marketplace marketplace = Marketplace();

    while (!marketplace.isFull) {
      tq.Card card =
          availableMarketCards[_random.nextInt(availableMarketCards.length)];

      if (random.nextDouble() < comboBias) {
        if (tableau.hasCombo(card)) {
          bool added = _addIfPossible(marketplace, card);
          if (added) {
            print('Added combo card: ${card.name}');
          }
        }
      } else {
        _addIfPossible(marketplace, card);
      }
    }
    return marketplace;
  }

  bool _addIfPossible(Marketplace marketplace, tq.Card card) {
    if (!marketplace.contains(card)) {
      if (card.keywords.contains("Spell")) {
        if (!marketplace.spells.isFull) {
          marketplace.spells.add(card as tq.MarketplaceCard);
          return true;
        } else if (marketplace.anys.canTake(card)) {
          marketplace.anys.add(card as tq.MarketplaceCard);
          return true;
        }
        return false;
      } else if (card.keywords.contains("Item")) {
        if (!marketplace.items.isFull) {
          marketplace.items.add(card as tq.MarketplaceCard);
          return true;
        } else if (marketplace.anys.canTake(card)) {
          marketplace.anys.add(card as tq.MarketplaceCard);
          return true;
        }
        return false;
      } else if (card.keywords.contains("Weapon")) {
        if (!marketplace.weapons.isFull) {
          marketplace.weapons.add(card as tq.MarketplaceCard);
          return true;
        } else if (marketplace.anys.canTake(card)) {
          marketplace.anys.add(card as tq.MarketplaceCard);
          return true;
        }
        return false;
      } else if (card.keywords.contains("Ally")) {
        if (!marketplace.anys.isFull) {
          marketplace.anys.add(card as tq.MarketplaceCard);
          return true;
        }
        return false;
      }
    }
    return false;
  }
}
