import 'package:yaml/yaml.dart';
import 'package:flutter_tqr/models/database.dart';

class ThunderstoneYamlCardParser {
  CardDatabase parse(String yaml) {
    List<Quest> quests = new List();
    var document = loadYaml(yaml);
    for (var questNode in document) {
      Quest quest = _parseQuest(questNode);
      quests.add(quest);
    }
    return CardDatabase(quests);
  }

  Quest _parseQuest(var node) {
    Quest quest = new Quest();
    quest.name = node['Quest'];
    quest.code = node['Code'];
    for (var entry in node['Heroes']) {
      Hero hero = new Hero();
      hero.name = entry['Name'];
      if (entry['Keywords'] != null) {
        for (var keyword in entry['Keywords']) {
          hero.keywords.add(keyword);
        }
      }
      quest.heroes.add(hero);
    }

    for (var entry in node['Items']) {
      Item item = new Item();
      item.name = entry['Name'];
      quest.items.add(item);
    }

    for (var entry in node['Spells']) {
      Spell spell = new Spell();
      spell.name = entry['Name'];
      quest.spells.add(spell);
    }

    for (var entry in node['Weapons']) {
      Weapon weapon = new Weapon();
      weapon.name = entry['Name'];
      quest.weapons.add(weapon);
    }

    if (node['Allies'] != null) {
      for (var entry in node['Allies']) {
        Ally ally = new Ally();
        ally.name = entry['Name'];
        quest.allies.add(ally);
      }
    }

    for (var entry in node['Guardians']) {
      Guardian guardian = new Guardian();
      guardian.name = entry['Name'];
      quest.guardians.add(guardian);
    }

    if (node['Dungeon Rooms'] != null) {
      for (var entry in node['Dungeon Rooms']) {
        Room room = new Room();
        room.name = entry['Name'];
        room.level = entry['Level'];
        quest.rooms.add(room);
      }
    }

    if (node['Monsters'] != null) {
      for (var entry in node['Monsters']) {
        Monster monster = new Monster();
        monster.name = entry['Name'];
        monster.level = entry['Level'];
        quest.monsters.add(monster);
      }
    }

    return quest;
  }
}
