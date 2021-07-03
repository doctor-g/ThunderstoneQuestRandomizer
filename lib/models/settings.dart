import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tqr/models/database.dart' as tq;
import 'package:flutter/foundation.dart';
import 'package:flutter_tqr/models/tableau.dart';
import 'package:flutter_tqr/util/tableau_failure.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database.dart';

part 'settings.g.dart';

class BoolPreference extends ChangeNotifier {
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
  _reset() {
    value = defaultValue;
  }
}

class SettingsModel extends ChangeNotifier {
  static final String _excludedQuestsKey = 'exclude';
  static final String _heroStrategyIndexKey = 'heroStrategyIndex';
  static final String _comboBiasKey = 'comboBias';
  static final String _showKeywordsKey = 'showKeywords';
  static final String _showQuestKey = 'showQuest';
  static final String _brightnessKey = 'lightMode';
  static final String _languageKey = 'lang';
  static final String _barricadesModeKey = 'barricadesMode';
  static final String _soloModeKey = 'soloMode';
  static final String _smallTableauKey = 'smallTableau';
  static final String _randomizeWildernessKey = 'randomizeWilderness';
  static final String _ratChanceKey = 'ratChance';

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // The names of excluded quests
  Set<String> _excludedQuests = new Set();

  int _heroStrategyIndex = 0;

  late final List<BoolPreference> allPrefs;

  SettingsModel() {
    allPrefs = [_showMemo];
    allPrefs.forEach((element) => element.addListener(() => notifyListeners()));
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
      if (prefs.containsKey(_languageKey)) {
        _language = prefs.getString(_languageKey)!;
      }
      if (prefs.containsKey(_smallTableauKey)) {
        _smallTableau = prefs.getBool(_smallTableauKey)!;
      }
      if (prefs.containsKey(_randomizeWildernessKey)) {
        _randomizeWilderness = prefs.getBool(_randomizeWildernessKey)!;
      }
      if (prefs.containsKey(_ratChanceKey)) {
        _ratChance = prefs.getDouble(_ratChanceKey)!;
      }
      notifyListeners();
    });
  }

  void clear() {
    _prefs.then((prefs) => prefs.clear());

    allPrefs.forEach((element) => element._reset());

    _excludedQuests = new Set();
    _heroStrategyIndex = 0;
    _comboBias = 0.5;
    _showKeywords = true;
    _showQuest = false;
    _brightness = Brightness.light;
    _barricadesMode = false;
    _language = 'en';
    _smallTableau = false;
    _randomizeWilderness = false;
    _ratChance = 0.75;
    notifyListeners();
  }

  bool includes(Quest quest) => !excludes(quest);

  bool excludes(Quest quest) => _excludedQuests.contains(quest.name);

  void exclude(Quest quest) {
    bool isNewExclusion = _excludedQuests.add(quest.name);
    if (isNewExclusion) {
      _updatePrefs();
      notifyListeners();
    }
  }

  void include(Quest quest) {
    bool changed = _excludedQuests.remove(quest.name);
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
    prefs.setBool(_showQuestKey, _showQuest);
    prefs.setBool(_brightnessKey, _brightness == Brightness.light);
    prefs.setString(_languageKey, _language);
    prefs.setBool(_barricadesModeKey, _barricadesMode);
    prefs.setBool(_soloModeKey, _soloMode);
    prefs.setBool(_smallTableauKey, _smallTableau);
    prefs.setBool(_randomizeWildernessKey, _randomizeWilderness);
    prefs.setDouble(_ratChanceKey, _ratChance);
  }

  /// Get the current hero selection strategy
  HeroSelectionStrategy get heroSelectionStrategy => _smallTableau
      ? RandomHeroSelectionStrategy(heroes: 2)
      : heroStrategies[_heroStrategyIndex];
  set heroSelectionStrategy(HeroSelectionStrategy strategy) {
    final int selectedIndex = heroStrategies.indexOf(strategy);
    if (_heroStrategyIndex != selectedIndex) {
      _heroStrategyIndex = selectedIndex;
      notifyListeners();
      _updatePrefs();
    }
  }

  MarketSelectionStrategy get marketSelectionStrategy => _smallTableau
      ? SoloModeMarketSelectionStrategy()
      : FirstFitMarketSelectionStrategy();

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

  final BoolPreference _showMemo =
      BoolPreference(key: 'showMemoKey', defaultValue: true);
  bool get showMemo => _showMemo.value;
  set showMemo(bool value) => _showMemo.value = value;

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

  String _language = 'en';
  String get language => _language;
  set language(String language) {
    _language = language;
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

  bool _smallTableau = false;
  bool get smallTableau => _smallTableau;
  set smallTableau(bool value) {
    _smallTableau = value;
    _updatePrefs();
    notifyListeners();
  }

  bool _randomizeWilderness = false;
  bool get randomizeWilderness => _randomizeWilderness;
  set randomizeWilderness(bool value) {
    _randomizeWilderness = value;
    _updatePrefs();
    notifyListeners();
  }

  double _ratChance = 0.75;
  double get ratChance => _ratChance;
  set ratChance(double value) {
    assert(value >= 0 && value <= 1);
    _ratChance = value;
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

  FirstMatchHeroSelectionStrategy();

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

  int heroes;

  RandomHeroSelectionStrategy({this.heroes = 4}) {
    assert(heroes >= 0);
  }

  @override
  List<tq.Hero> selectHeroesFrom(List<tq.Hero> availableHeroes) {
    if (availableHeroes.length < heroes) {
      throw new TableauFailureException('Not enough heroes to choose from.');
    }
    availableHeroes.shuffle();
    return availableHeroes.take(heroes).toList();
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
  Marketplace selectMarketCardsFrom(
      List<tq.MarketplaceCard> availableMarketCards,
      double comboBias,
      final Tableau tableau);
}

class FirstFitMarketSelectionStrategy extends MarketSelectionStrategy {
  @override
  String get name => 'First Fit (Supports Allies)';

  @override
  Marketplace selectMarketCardsFrom(
      List<tq.MarketplaceCard> availableMarketCards,
      double comboBias,
      final Tableau tableau) {
    Random random = Random();
    StandardMarketplace marketplace = StandardMarketplace();

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

  bool _addIfPossible(StandardMarketplace marketplace, tq.Card card) {
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

class SoloModeMarketSelectionStrategy extends MarketSelectionStrategy {
  @override
  String get name => 'Small Tableau Solo Mode';

  @override
  Marketplace selectMarketCardsFrom(
      List<tq.MarketplaceCard> availableMarketCards,
      double comboBias,
      Tableau tableau) {
    Random random = Random();
    SoloModeMarketplace marketplace = SoloModeMarketplace();
    while (!marketplace.isFull) {
      int index = random.nextInt(availableMarketCards.length);
      MarketplaceCard card = availableMarketCards[index];
      if (!marketplace.contains(card)) {
        if (random.nextDouble() < comboBias) {
          if (tableau.hasCombo(card)) {
            marketplace.add(card);
            print('Added combo card: ${card.name}');
          }
        } else {
          marketplace.add(card);
        }
      }
    }
    return marketplace;
  }
}
