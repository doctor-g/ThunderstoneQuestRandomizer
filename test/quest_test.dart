import 'package:test/test.dart';
import 'package:flutter_tqr/domain_model.dart';

void main() {
  test('Quest cards accessor returns all cards.', () {
    Quest quest = new Quest();
    quest.heroes.add(new Hero());
    quest.items.add(new Item());
    quest.spells.add(new Spell());
    quest.weapons.add(new Weapon());
    quest.allies.add(new Ally());
    expect(quest.cards.length, 5);
  });
}
