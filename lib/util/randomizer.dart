import 'dart:math';

import 'package:flutter_tqr/models/settings.dart';
import 'package:flutter_tqr/models/database.dart';
import 'package:flutter_tqr/models/tableau.dart';

class Randomizer {
  static final classes = ['Fighter', 'Rogue', 'Cleric', 'Wizard'];
  Random _random = new Random();

  Tableau generateTableau(CardDatabase db, SettingsModel settings) {
    Tableau tableau = new Tableau();
    tableau.heroes = chooseHeroes(db, settings);
    tableau.marketplace = chooseMarket(db, settings);
    tableau.guardian = chooseGuardian(db, settings);
    tableau.dungeon = generateDungeon(db, settings);
    tableau.monsters = chooseMonsters(db, settings);
    return tableau;
  }

  List<Hero> chooseHeroes(CardDatabase db, SettingsModel settings) {
    // Make a master list of all the heroes
    List<Hero> allHeroes = new List();
    for (Quest quest in db.quests) {
      if (settings.includes(quest.name)) {
        allHeroes += quest.heroes;
      }
    }

    return settings.heroSelectionStrategy.selectHeroesFrom(allHeroes);
  }

  Marketplace chooseMarket(CardDatabase db, SettingsModel settings) {
    // Get all possible market cards
    List<Card> allMarketCards = new List();
    for (Quest quest in db.quests) {
      if (settings.includes(quest.name)) {
        allMarketCards += quest.spells;
        allMarketCards += quest.items;
        allMarketCards += quest.weapons;
        allMarketCards += quest.allies;
      }
    }
    return settings.marketSelectionStrategy
        .selectMarketCardsFrom(allMarketCards);
  }

  Guardian chooseGuardian(CardDatabase db, SettingsModel settings) {
    List<Guardian> allGuardians = new List();
    for (Quest quest in db.quests) {
      if (settings.includes(quest.name)) {
        allGuardians += quest.guardians;
      }
    }

    Guardian guardian = allGuardians[_random.nextInt(allGuardians.length)];

    // This is a bit of a kludge, but it seems better than recording three
    // levels of each guardian in the data.
    guardian.level = 4 + _random.nextInt(3);

    return guardian;
  }

  Dungeon generateDungeon(CardDatabase db, SettingsModel settings) {
    Map<int, List<Room>> availableRooms = {
      1: List<Room>(),
      2: List<Room>(),
      3: List<Room>()
    };
    for (Quest quest in db.quests) {
      if (settings.includes(quest.name)) {
        quest.rooms.forEach((element) {
          availableRooms[element.level].add(element);
        });
      }
    }

    Dungeon dungeon = new Dungeon();
    [1, 2, 3].forEach((level) {
      List<Room> rooms = availableRooms[level];
      [1, 2].forEach((_i) {
        Room room = rooms.removeAt(_random.nextInt(rooms.length));
        dungeon.roomsMap[level].add(room);
      });
    });
    return dungeon;
  }

  List<Monster> chooseMonsters(CardDatabase db, SettingsModel settings) {
    Map<int, List<Monster>> availableMonsters = {
      1: List(),
      2: List(),
      3: List()
    };
    for (Quest quest in db.quests) {
      if (settings.includes(quest.name)) {
        quest.monsters.forEach(
            (monster) => availableMonsters[monster.level].add(monster));
      }
    }

    List<Monster> result = List();
    [1, 2, 3].forEach((level) {
      List<Monster> list = availableMonsters[level];
      Monster monster = list[_random.nextInt(list.length)];
      result.add(monster);
    });

    return result;
  }
}
