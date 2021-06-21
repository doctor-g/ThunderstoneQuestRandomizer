import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tqr/util/parser.dart';
import 'package:flutter_tqr/models/database.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  group('Parse localized YAML', () {
    late CardDatabase db;
    late Quest quest;

    setUp(() {
      ThunderstoneYamlCardParser parser = new ThunderstoneYamlCardParser();
      db = parser.parse('''
- Quest: The First Quest
  Quest_es: La Búsqueda Primera
  Number: 1
  Heroes:
    - Name: Hero1
      Name_es: HeroUno
      Keywords: [ Human, Fighter ]
      Memo: Sample memo
      Memo_es: Spanish memo
      Combo: [ Combo1 ]
      Meta: [ Meta1 ]
    - Name: Hero2
      Memo: Untranslated memo
    - Name: Hero3
      Memo_es: Solo Español
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
- Quest: Untranslated Quest
''', languageCode: 'es');
      quest = db.quests[0];
    });

    // This is a learning test to help ensure that I understand the
    // localization plumbing.
    testWidgets('Changing locale works as expected',
        (WidgetTester tester) async {
      await tester.pumpAndSettle();

      var placeholder = Placeholder();

      var localizations = Localizations(
          delegates: AppLocalizations.localizationsDelegates,
          locale: Locale('es'),
          child: placeholder);
      expect(localizations.locale.languageCode == 'es', isTrue);
    });

    test('Parse Spanish names', () {
      expect(quest.name, equals('La Búsqueda Primera'));
      expect(quest.heroes[0].name, equals('HeroUno'));
      expect(quest.heroes[0].memo, equals('Spanish memo'));
      expect(quest.items[0].name, equals('Articulo'));
      expect(quest.guardians[0].name, equals('Guardiana'));
      expect(quest.rooms[0].name, equals('Habitación'));
      expect(quest.monsters[0].name, equals('Monstruo'));
    });

    test('English card names are retained as canonical names', () {
      expect(quest.canonicalName, equals('The First Quest'));
      expect(quest.heroes[0].canonicalName, equals('Hero1'));
      expect(quest.items[0].canonicalName, equals('Item1'));
      expect(quest.guardians[0].canonicalName, equals('Guardian1'));
      expect(quest.rooms[0].canonicalName, equals('Room1'));
      expect(quest.monsters[0].canonicalName, equals('Monster1'));
    });

    test('English is used as fallback when there is no translation', () {
      expect(db.quests[1].name, equals('Untranslated Quest'));
      expect(quest.heroes[1].name, equals('Hero2'));
      expect(quest.heroes[1].memo, equals('Untranslated memo'));
    });

    test('Use Spanish memo even if there is no English one', () {
      expect(quest.heroes[2].memo, equals('Solo Español'));
    });
  });
}
