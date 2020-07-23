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
      _parseCard(entry, hero);
      quest.heroes.add(hero);
    }

    for (var entry in node['Items']) {
      Item item = new Item();
      _parseCard(entry, item);
      quest.items.add(item);
    }

    for (var entry in node['Spells']) {
      Spell spell = new Spell();
      _parseCard(entry, spell);
      quest.spells.add(spell);
    }

    for (var entry in node['Weapons']) {
      Weapon weapon = new Weapon();
      _parseCard(entry, weapon);
      quest.weapons.add(weapon);
    }

    if (node['Allies'] != null) {
      for (var entry in node['Allies']) {
        Ally ally = new Ally();
        _parseCard(entry, ally);
        quest.allies.add(ally);
      }
    }

    for (var entry in node['Guardians']) {
      Guardian guardian = new Guardian();
      _parseCard(entry, guardian);
      quest.guardians.add(guardian);
    }

    if (node['Dungeon Rooms'] != null) {
      for (var entry in node['Dungeon Rooms']) {
        Room room = new Room();
        _parseCard(entry, room);
        room.level = entry['Level'];
        quest.rooms.add(room);
      }
    }

    if (node['Monsters'] != null) {
      for (var entry in node['Monsters']) {
        Monster monster = new Monster();
        _parseCard(entry, monster);
        monster.level = entry['Level'];
        quest.monsters.add(monster);
      }
    }

    return quest;
  }

  // Parse the shared elements of all cards
  void _parseCard(var entry, Card card) {
    card.name = entry['Name'];
    if (entry['Keywords'] != null) {
      for (var keyword in entry['Keywords']) {
        card.keywords.add(keyword);
      }
    }
    if (entry['Memo'] != null) {
      card.memo = entry['Memo'];
    }
    if (entry['Combo'] != null) {
      for (var combo in entry['Combo']) {
        card.combo.add(combo);
      }
    }
  }
}
