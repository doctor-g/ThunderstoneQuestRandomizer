import 'package:flutter_test/flutter_test.dart';
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
  - Name: Monster2
    Level: 2
    Restriction: [NoSolo]
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
      expect(quest.monsters.length, equals(2));
      expect(quest.monsters[0].name, equals('Monster1'));
      expect(quest.monsters[1].name, equals('Monster2'));
      expect(quest.monsters[0].soloRestriction, isFalse);
      expect(quest.monsters[1].soloRestriction, isTrue);
    });
  });

  group('Localized cards', () {
    late Quest quest;

    setUp(() {
      ThunderstoneYamlCardParser parser = new ThunderstoneYamlCardParser();
      CardDatabase db = parser.parse('''
- Quest: One
  Quest_es: Uno
  Heroes:
    - Name: Blue
      Name_es: Azul
      Memo: Blue Man
      Memo_es: Hombre Azul
  Marketplace:
    - Name: Item1
      Name_es: Articulo
      Keywords: [Item]
    - Name: Spell1
      Keywords: [Spell]
    - Name: Weapon1
      Keywords: [Weapon]
    - Name: Ally1
      Keywords: [Ally]
  Guardians:
    - Name: Guardian1
      Name_es: Guardiana
  Dungeon Rooms:
  - Name: Room1
    Name_es: Habitación
    Level: 1
  Monsters:
  - Name: Monster1
    Name_es: Monstruo
    Level: 1
  - Name: Monster2
    Level: 2
    Restriction: [NoSolo]
''');
      quest = db.quests[0];
    });

    test("Localized name is stored in the quest", () {
      expect(quest.localizedNames["es"], equals('Uno'));
    });

    test("Localized name is stored in the cards", () {
      expect(quest.heroes[0].localizedNames["es"], equals('Azul'));
      expect(quest.items[0].localizedNames['es'], equals('Articulo'));
      expect(quest.guardians[0].localizedNames['es'], equals('Guardiana'));
      expect(quest.rooms[0].localizedNames['es'], equals('Habitación'));
      expect(quest.monsters[0].localizedNames['es'], equals('Monstruo'));
    });

    test("Localized memos", () {
      expect(quest.heroes[0].localizedMemos["es"], equals('Hombre Azul'));
    });
  });
}
