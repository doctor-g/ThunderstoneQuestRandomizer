import 'package:test/test.dart';
import 'package:flutter_tqr/models/database.dart';

void main() {
  test('Quest cards accessor returns all cards.', () {
    Quest quest = new Quest("Test Quest");
    quest.add(new Hero());
    quest.add(new MarketplaceCard());
    expect(quest.cards.length, 2);
  });
}
