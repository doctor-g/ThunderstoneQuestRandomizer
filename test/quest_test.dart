import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tqr/models/database.dart';

import 'test_util.dart';

void main() {
  test('Quest cards accessor returns all cards.', () {
    Quest quest = new Quest("Test Quest");
    quest.add(makeHero());
    quest.add(makeMarketplaceCard());
    expect(quest.cards.length, 2);
  });
}
