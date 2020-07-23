import 'package:test/test.dart';
import 'package:flutter_tqr/util/parser.dart';
import 'package:flutter_tqr/models/database.dart';

void main() {
  group('Parse YAML', () {
    CardDatabase db;
    Quest quest;

    setUp(() {
      ThunderstoneYamlCardParser parser = new ThunderstoneYamlCardParser();
      db = parser.parse('''
- Quest: The First Quest
  Code: Q
  Heroes:
    - Name: Hero1
      Keywords: [ Human, Fighter ]
    - Name: Hero2
  Items:
    - Name: Item1
  Spells:
    - Name: Spell1
  Weapons:
    - Name: Weapon1
  Allies:
    - Name: Ally1
  Guardians:
    - Name: Guardian1
  Rooms:
  - Name: Room1
    Level: 1
  Monsters:
  - Name: Monster1
    Level: 1
''');
      quest = db.quests[0];
    });

    test('Get the right number of quests', () {
      expect(db.quests.length, 1);
    });

    test('Get the name of the first quest', () {
      expect(quest.name, 'The First Quest');
    });

    test('Get the code of the first quest', () {
      expect(quest.code, 'Q');
    });

    test('Get the right number of heroes', () {
      expect(quest.heroes.length, 2);
    });

    test('Get the hero keywords', () {
      expect(
          quest.heroes[0].keywords, containsAllInOrder(['Human', 'Fighter']));
    });

    test('Get the items', () {
      expect(quest.items.length, 1);
      expect(quest.items[0].name, 'Item1');
    });

    test('Get the spells', () {
      expect(quest.spells.length, 1);
      expect(quest.spells[0].name, 'Spell1');
    });

    test('Get the weapons', () {
      expect(quest.weapons.length, 1);
      expect(quest.weapons[0].name, 'Weapon1');
    });

    test('Get the allies', () {
      expect(quest.allies.length, 1);
      expect(quest.allies[0].name, 'Ally1');
    });

    test('Get the guardian', () {
      expect(quest.guardians.length, 1);
      expect(quest.guardians[0].name, 'Guardian1');
    });

    test('Get the rooms', () {
      expect(quest.rooms.length, 1);
      expect(quest.rooms[0].name, 'Room1');
    });

    test('Get the monsters', () {
      expect(quest.monsters.length, 1);
      expect(quest.monsters[0].name, 'Monster1');
    });
  });
}
