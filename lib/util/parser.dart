import 'package:yaml/yaml.dart';
import 'package:flutter_tqr/models/database.dart';

class ThunderstoneYamlCardParser {
  CardDatabase parse(String yaml) {
    List<Quest> quests = [];
    var document = loadYaml(yaml);
    for (var questNode in document) {
      Quest quest = _parseQuest(questNode);
      quests.add(quest);
    }
    return CardDatabase(quests);
  }

  // Current quest being built.
  Quest? _quest;

  Quest _parseQuest(YamlMap node) {
    final empty = [];
    _quest = Quest(node['Quest']);
    _quest!.number = node['Number'];
    _quest!.wildernessMonster = node['WildernessMonster'];

    for (String key in node.keys) {
      if (key.startsWith("Quest_")) {
        String languageCode = key.substring("Quest_".length);
        _quest!.localizedNames[languageCode] = node[key];
      }
    }

    for (var entry in node['Heroes'] ?? empty) {
      HeroBuilder builder = HeroBuilder();
      _parseCard(entry, builder);
      _quest!.add(builder.build());
    }

    for (var entry in node['Marketplace'] ?? empty) {
      MarketplaceCardBuilder builder = MarketplaceCardBuilder();
      _parseCard(entry, builder);
      _quest!.add(builder.build());
    }

    for (var entry in node['Guardians'] ?? empty) {
      GuardianBuilder builder = GuardianBuilder();
      _parseCard(entry, builder);
      _quest!.add(builder.build());
    }

    for (var entry in node['Dungeon Rooms'] ?? empty) {
      RoomBuilder builder = RoomBuilder();
      _parseCard(entry, builder);
      builder.level = entry['Level'];
      _quest!.add(builder.build());
    }

    for (var entry in node['Monsters'] ?? empty) {
      MonsterBuilder builder = MonsterBuilder();
      _parseCard(entry, builder);
      if (entry['Restriction'] != null) {
        for (var restriction in entry['Restriction']) {
          if (restriction == 'NoSolo') {
            builder.soloRestriction = true;
          }
        }
      }
      builder.level = entry['Level'];
      _quest!.add(builder.build());
    }

    return _quest!;
  }

  // Parse the shared elements of all cards
  void _parseCard(dynamic entry, CardBuilder cardBuilder) {
    if (_quest == null) {
      throw Exception("_quest must be initialized before calling this method");
    }
    cardBuilder.quest = _quest!;
    cardBuilder.name = entry['Name'];

    if (entry['Keywords'] != null) {
      for (var keyword in entry['Keywords']) {
        cardBuilder.keywords.add(keyword);
      }
    }

    cardBuilder.memo = entry['Memo'];

    if (entry['Combo'] != null) {
      for (var combo in entry['Combo']) {
        cardBuilder.combo.add(combo);
      }
    }

    if (entry['Meta'] != null) {
      for (var meta in entry['Meta']) {
        cardBuilder.meta.add(meta);
      }
    }

    // Process localizable entries
    for (String key in entry.keys) {
      if (key.startsWith("Name_")) {
        String languageCode = key.substring("Name_".length);
        cardBuilder.localizedNames[languageCode] = entry[key];
      }
      if (key.startsWith("Memo_")) {
        String languageCode = key.substring("Memo_".length);
        cardBuilder.localizedMemos[languageCode] = entry[key];
      }
    }
  }
}
