import 'package:test/test.dart';
import 'package:flutter_tqr/parser.dart';
import 'package:flutter_tqr/quest.dart';

void main() {
  test('Get the right number of heroes', () {
    QuestParser parser = new QuestParser();
    Quest result = parser.parse('''
Heroes:
  - Name: Hero1
  - Name: Hero2
    ''');
    expect(result.heroes.length, 2);
  });
}
