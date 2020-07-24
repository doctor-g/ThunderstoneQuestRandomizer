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
    final empty = List();
    Quest quest = new Quest();
    quest.name = node['Quest'];
    quest.code = node['Code'];

    for (var entry in node['Heroes'] ?? empty) {
      Hero hero = new Hero();
      _parseCard(entry, hero);
      quest.heroes.add(hero);
    }

    for (var entry in node['Items'] ?? empty) {
      Item item = new Item();
      _parseCard(entry, item);
      quest.items.add(item);
    }

    for (var entry in node['Spells'] ?? empty) {
      Spell spell = new Spell();
      _parseCard(entry, spell);
      quest.spells.add(spell);
    }

    if (node['Weapons'] != null) {
      for (var entry in node['Weapons'] ?? empty) {
        Weapon weapon = new Weapon();
        _parseCard(entry, weapon);
        quest.weapons.add(weapon);
      }
    }

    for (var entry in node['Allies'] ?? empty) {
      Ally ally = new Ally();
      _parseCard(entry, ally);
      quest.allies.add(ally);
    }

    for (var entry in node['Guardians'] ?? empty) {
      Guardian guardian = new Guardian();
      _parseCard(entry, guardian);
      quest.guardians.add(guardian);
    }

    for (var entry in node['Dungeon Rooms'] ?? empty) {
      Room room = new Room();
      _parseCard(entry, room);
      room.level = entry['Level'];
      quest.rooms.add(room);
    }

    for (var entry in node['Monsters'] ?? empty) {
      Monster monster = new Monster();
      _parseCard(entry, monster);
      monster.level = entry['Level'];
      quest.monsters.add(monster);
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
    if (entry['Meta'] != null) {
      for (var meta in entry['Meta']) {
        card.meta.add(meta);
      }
    }
  }
}
