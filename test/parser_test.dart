import 'package:test/test.dart';
import 'package:flutter_tqr/parser.dart';
import 'package:flutter_tqr/domain_model.dart';

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
  });
}
