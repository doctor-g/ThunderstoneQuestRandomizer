import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tqr/models/database.dart' as tq;
import 'package:flutter/foundation.dart';
import 'package:flutter_tqr/models/tableau.dart';
import 'package:flutter_tqr/util/preferences.dart';
import 'package:flutter_tqr/util/tableau_failure.dart';

import 'database.dart';

part 'settings.g.dart';

class SettingsModel extends ChangeNotifier {
  final StringSetPreference _excludedQuests =
      StringSetPreference(key: 'exclude');
  final BoolPreference _showMemo =
      BoolPreference(key: 'showMemo', defaultValue: true);
  final BoolPreference _showKeywords =
      BoolPreference(key: 'showKeywords', defaultValue: true);
  final BoolPreference _showQuest =
      BoolPreference(key: 'showQuest', defaultValue: false);
  final BoolPreference _barricadesMode =
      BoolPreference(key: 'barricadesMode', defaultValue: false);
  final BoolPreference _soloMode =
      BoolPreference(key: 'soloMode', defaultValue: false);
  final BoolPreference _smallTableau =
      BoolPreference(key: 'smallTableau', defaultValue: false);
  final BoolPreference _randomizeWilderness =
      BoolPreference(key: 'randomizeWilderness', defaultValue: false);
  final BrightnessPreference _brightness =
      BrightnessPreference(key: 'lightMode', defaultValue: Brightness.light);
  final IntPreference _heroStrategyIndex =
      IntPreference(key: 'heroStrategyIndex', defaultValue: 0);
  final DoublePreference _comboBias =
      DoublePreference(key: 'comboBias', defaultValue: 0.4);
  final DoublePreference _ratChance =
      DoublePreference(key: 'ratChance', defaultValue: 0.75);
  final StringPreference _language =
      StringPreference(key: 'lang', defaultValue: 'en');

  SettingsModel() {
    allPrefs.forEach((element) => element.addListener(() => notifyListeners()));
  }

  void clear() {
    // We will notify all the listeners once, after resetting the values.
    allPrefs.forEach((element) => element.reset(notifyListeners: false));
    notifyListeners();
  }

  bool includes(Quest quest) => _excludedQuests.includes(quest.name);

  bool excludes(Quest quest) => _excludedQuests.excludes(quest.name);

  void exclude(Quest quest) => _excludedQuests.exclude(quest.name);

  void include(Quest quest) => _excludedQuests.include(quest.name);

  /// Get the current hero selection strategy
  HeroSelectionStrategy get heroSelectionStrategy => _smallTableau.value
      ? RandomHeroSelectionStrategy(heroes: 2)
      : heroStrategies[_heroStrategyIndex.value];
  set heroSelectionStrategy(HeroSelectionStrategy strategy) {
    final int selectedIndex = heroStrategies.indexOf(strategy);
    if (_heroStrategyIndex.value != selectedIndex) {
      _heroStrategyIndex.value = selectedIndex;
    }
  }

  MarketSelectionStrategy get marketSelectionStrategy => _smallTableau.value
      ? SoloModeMarketSelectionStrategy()
      : FirstFitMarketSelectionStrategy();

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
