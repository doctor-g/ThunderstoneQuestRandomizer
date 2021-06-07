import 'package:test/test.dart';
import 'package:flutter_tqr/util/parser.dart';
import 'package:flutter_tqr/models/database.dart';

void main() {
  group('Parse YAML', () {
    late CardDatabase db;
    late Quest quest;

    setUp(() {
      ThunderstoneYamlCardParser parser = new ThunderstoneYamlCardParser();
      db = parser.parse('''
- Quest: The First Quest
  Number: 1
  Heroes:
    - Name: Hero1
      Keywords: [ Human, Fighter ]
      Memo: Sample memo
      Combo: [ Combo1 ]
      Meta: [ Meta1 ]
    - Name: Hero2
  Marketplace:
    - Name: Item1
      Keywords: [Item]
    - Name: Spell1
      Keywords: [Spell]
    - Name: Weapon1
      Keywords: [Weapon]
    - Name: Ally1
      Keywords: [Ally]
  Guardians:
    - Name: Guardian1
  Dungeon Rooms:
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

    test('Get the number of the first quest', () {
      expect(quest.number, 1);
    });

    test('Get the right number of heroes', () {
      expect(quest.heroes.length, 2);
    });

    test('Get the hero keywords', () {
      expect(
          quest.heroes[0].keywords, containsAllInOrder(['Human', 'Fighter']));
    });

    test('Read the hero memo', () {
      expect(quest.heroes[0].memo, 'Sample memo');
    });

    test('Read the hero combo', () {
      expect(quest.heroes[0].combo, contains('Combo1'));
    });

    test('Read the hero meta', () {
      expect(quest.heroes[0].meta, contains('Meta1'));
    });

    test('Get the items', () {
      expect(quest.items.length, 1);
      expect(quest.items[0].name, 'Item1');
    });

    test('Read the keywords of the item', () {
      expect(quest.items[0].keywords, ['Item']);
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
