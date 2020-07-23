import 'dart:math';
import 'package:flutter_tqr/models/database.dart' as tq;
import 'package:flutter/foundation.dart';
import 'package:flutter_tqr/models/tableau.dart';
import 'package:flutter_tqr/util/tableau_failure.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel extends ChangeNotifier {
  static final String _excludedQuestsKey = 'exclude';
  static final String _heroStrategyIndexKey = 'heroStrategyIndex';

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
        _excludedQuests = prefs.getStringList(_excludedQuestsKey).toSet();
      }
      if (prefs.containsKey(_heroStrategyIndexKey)) {
        _heroStrategyIndex = prefs.getInt(_heroStrategyIndexKey);
      }
      notifyListeners();
    });
  }

  void clear() {
    _prefs.then((prefs) => prefs.clear());
    _excludedQuests = new Set();
    _heroStrategyIndex = 0;
    notifyListeners();
  }

  bool includes(String questName) {
    return !excludes(questName);
  }

  bool excludes(String questName) {
    return _excludedQuests.contains(questName);
  }

  void exclude(String questName) {
    bool newExclusion = _excludedQuests.add(questName);
    if (newExclusion) {
      _updatePrefs();
      notifyListeners();
    }
  }

  void include(String questName) {
    bool changed = _excludedQuests.remove(questName);
    if (changed) {
      _updatePrefs();
      notifyListeners();
    }
  }

  void _updatePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(_excludedQuestsKey, _excludedQuests.toList());
    prefs.setInt(_heroStrategyIndexKey, _heroStrategyIndex);
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
      return heroes;
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
      double comboBias, Set<String> presentKeywords, Set<String> seekingCombos);
}

class FirstFitMarketSelectionStrategy extends MarketSelectionStrategy {
  @override
  String get name => 'First Fit (Supports Allies)';

  @override
  Marketplace selectMarketCardsFrom(
      List<tq.Card> availableMarketCards,
      double comboBias,
      Set<String> presentKeywords,
      Set<String> seekingCombos) {
    Random random = Random();
    Marketplace marketplace = Marketplace();

    while (!marketplace.isFull) {
      tq.Card card =
          availableMarketCards[_random.nextInt(availableMarketCards.length)];

      if (random.nextDouble() < comboBias) {
        // Looking for a combo here, which can either be that this card
        // matches one of my combos, or the combos on this card matches
        // something I already have in the tableau.
        bool isKeywordInSet = card.keywords.fold(
            false,
            (previousValue, keyword) =>
                previousValue || seekingCombos.contains(keyword));
        //print('$isKeywordInSet: ${card.name} has a keyword in the set!');

        bool cardhasKeywordOnTableau = card.combo.fold(
            false,
            (previousValue, cardComboTerm) =>
                previousValue || presentKeywords.contains(cardComboTerm));
        //print('$cardhasKeywordOnTableau: ${card.name} has a combo with something on the table');

        if (isKeywordInSet || cardhasKeywordOnTableau) {
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
      switch (card.runtimeType) {
        case tq.Spell:
          if (!marketplace.spells.isFull) {
            marketplace.spells.add(card);
            return true;
          } else if (marketplace.anys.canTake(card)) {
            marketplace.anys.add(card);
            return true;
          }
          return false;
        case tq.Item:
          if (!marketplace.items.isFull) {
            marketplace.items.add(card);
            return true;
          } else if (marketplace.anys.canTake(card)) {
            marketplace.anys.add(card);
            return true;
          }
          return false;
        case tq.Weapon:
          if (!marketplace.weapons.isFull) {
            marketplace.weapons.add(card);
            return true;
          } else if (marketplace.anys.canTake(card)) {
            marketplace.anys.add(card);
            return true;
          }
          return false;
        case tq.Ally:
          if (!marketplace.anys.isFull) {
            marketplace.anys.add(card);
            return true;
          }
          return false;
        default:
          throw Exception('Unexpected type ${card.runtimeType}');
      }
    }
    return false;
  }
}
