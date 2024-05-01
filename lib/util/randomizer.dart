import 'dart:math';

import 'package:flutter_tqr/models/settings.dart';
import 'package:flutter_tqr/models/database.dart';
import 'package:flutter_tqr/models/tableau.dart';
import 'package:flutter_tqr/util/tableau_failure.dart';

class Randomizer {
  static final classes = ['Fighter', 'Rogue', 'Cleric', 'Wizard'];
  Random _random = new Random();

  Tableau generateTableau(CardDatabase db, SettingsModel settings) {
    final maxTries = 10;
    Tableau tableau = new Tableau();

    if (settings.randomizeWilderness) {
      List<String> nonRatOptions = _collectWildernesses(db, settings);
      if (nonRatOptions.isEmpty || _random.nextDouble() <= settings.ratChance) {
        tableau.wildernessMonster = "Giant Rat";
      } else {
        tableau.wildernessMonster = _pickRandom(nonRatOptions);
      }
    }

    if (settings.barricadesMode) {
      tableau.modes.add(GameMode.Barricades);
    }
    if (settings.soloMode) {
      tableau.modes.add(GameMode.Solo);
    }
    if (settings.smallTableau) {
      tableau.modes.add(GameMode.SmallTableau);
    }
    if (!settings.useCorruption) {
      db = db
          .where((card) => !card.combo.union(card.meta).contains('Corruption'));
    }

    int tries = 0;
    for (;;) {
      try {
        tableau.heroes = chooseHeroes(db, settings);
        tableau.guardian = chooseGuardian(db, settings, tableau);
        tableau.dungeon =
            generateDungeon(db, settings); // No combos for dungeon.
        tableau.marketplace = chooseMarket(db, settings, tableau);
        tableau.monsters = chooseMonsters(db, settings, tableau);
        return tableau;
      } on TableauFailureException catch (e) {
        tries++;
        print('Got exception: ${e.cause}\nTries remaining ${maxTries - tries}');
        if (tries >= maxTries) {
          throw e;
        }
      }
    }
  }

  List<String> _collectWildernesses(CardDatabase db, SettingsModel settings) {
    List<String> result = [];
    for (var quest in db.quests) {
      if (settings.includes(quest) && quest.wilderness != null) {
        result.add(quest.wilderness!);
      }
    }
    return result;
  }

  T _pickRandom<T>(List<T> list) {
    return list[_random.nextInt(list.length)];
  }

  List<Hero> chooseHeroes(CardDatabase db, SettingsModel settings) {
    // Make a master list of all the heroes
    List<Hero> allHeroes = [];
    for (Quest quest in db.quests) {
      if (settings.includes(quest)) {
        allHeroes += quest.heroes;
      }
    }

    List<Hero> result =
        settings.heroSelectionStrategy.selectHeroesFrom(allHeroes);
    return result;
  }

  Marketplace chooseMarket(
      CardDatabase db, SettingsModel settings, Tableau tableau) {
    // Get all possible market cards
    List<MarketplaceCard> allMarketCards = [];
    for (Quest quest in db.quests) {
      if (settings.includes(quest)) {
        allMarketCards += quest.spells;
        allMarketCards += quest.items;
        allMarketCards += quest.weapons;
        allMarketCards += quest.allies;
      }
    }
    return settings.marketSelectionStrategy.selectMarketCardsFrom(
        allMarketCards,
        // If not using combo bias, then the bias is essentially 0%.
        // That is, we never worry about whether a card has a combo or not.
        settings.useComboBias ? settings.comboBias : 0.0,
        tableau);
  }

  Guardian chooseGuardian(
      CardDatabase db, SettingsModel settings, ComboFinder tableau) {
    List<Guardian> allGuardians = [];
    for (Quest quest in db.quests) {
      if (settings.includes(quest)) {
        allGuardians += quest.guardians;
      }
    }

    while (_seekCombo(settings)) {
      Guardian guardian = allGuardians[_random.nextInt(allGuardians.length)];
      if (tableau.hasCombo(guardian)) {
        print('Combo guardian');
        return _randomlyLevel(settings, guardian);
      }
    }

    // Not going for combos, just choose one.
    Guardian guardian = allGuardians[_random.nextInt(allGuardians.length)];
    return _randomlyLevel(settings, guardian);
  }

  bool _seekCombo(SettingsModel settings) =>
      settings.useComboBias && Random().nextDouble() < settings.comboBias;

  Guardian _randomlyLevel(SettingsModel settings, Guardian guardian) {
    if (settings.barricadesMode) {
      guardian.level = 7;
    } else {
      guardian.level = 4 + _random.nextInt(3);
    }
    return guardian;
  }

  Dungeon generateDungeon(CardDatabase db, SettingsModel settings) {
    Map<int, List<Room>> availableRooms = {1: [], 2: [], 3: []};
    for (Quest quest in db.quests) {
      if (settings.includes(quest)) {
        quest.rooms.forEach((element) {
          availableRooms[element.level]!.add(element);
        });
      }
    }

    Dungeon dungeon = new Dungeon();
    [1, 2, 3].forEach((level) {
      List<Room> rooms = availableRooms[level]!;
      [1, 2].forEach((_i) {
        Room room = rooms.removeAt(_random.nextInt(rooms.length));
        dungeon.roomsMap[level]!.add(room);
      });
    });
    return dungeon;
  }

  List<Monster> chooseMonsters(
      CardDatabase db, SettingsModel settings, ComboFinder tableau) {
    Map<int, List<Monster>> availableMonsters = {1: [], 2: [], 3: []};
    for (Quest quest in db.quests) {
      if (settings.includes(quest)) {
        quest.monsters.forEach(
            (monster) => availableMonsters[monster.level]!.add(monster));
      }
    }

    if (settings.soloMode) {
      [1, 2, 3].forEach((level) {
        availableMonsters[level]!
            .removeWhere((monster) => monster.soloRestriction);
      });
    }

    List<Monster> result = [];
    [1, 2, 3].forEach((level) {
      List<Monster> list = availableMonsters[level]!;
      bool done = false;
      while (!done && _seekCombo(settings)) {
        Monster monster = list[_random.nextInt(list.length)];
        if (tableau.hasCombo(monster)) {
          result.add(monster);
          done = true;
          print('Combo monster: ${monster.name}');
        }
      }
      // No combo, just pick one.
      if (!done) {
        Monster monster = list[_random.nextInt(list.length)];
        result.add(monster);
      }
    });

    return result;
  }
}
