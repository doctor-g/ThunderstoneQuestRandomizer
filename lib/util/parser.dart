import 'package:yaml/yaml.dart';
import 'package:flutter_tqr/models/database.dart';

class ThunderstoneYamlCardParser {
  CardDatabase parse(String yaml, {String? languageCode}) {
    List<Quest> quests = [];
    var document = loadYaml(yaml);
    for (var questNode in document) {
      Quest quest = _parseQuest(questNode, languageCode);
      quests.add(quest);
    }
    return CardDatabase(quests);
  }

  // Current quest being built.
  Quest? _quest;

  Quest _parseQuest(var node, String? languageCode) {
    final empty = [];
    _quest = Quest(_lookupLocalized(node, 'Quest', languageCode));
    _quest!.canonicalName = node['Quest'];
    _quest!.number = node['Number'];

    for (var entry in node['Heroes'] ?? empty) {
      HeroBuilder builder = HeroBuilder();
      _parseCard(entry, builder, languageCode);
      _quest!.add(builder.build());
    }

    for (var entry in node['Marketplace'] ?? empty) {
      MarketplaceCardBuilder builder = MarketplaceCardBuilder();
      _parseCard(entry, builder, languageCode);
      _quest!.add(builder.build());
    }

    for (var entry in node['Guardians'] ?? empty) {
      GuardianBuilder builder = GuardianBuilder();
      _parseCard(entry, builder, languageCode);
      _quest!.add(builder.build());
    }

    for (var entry in node['Dungeon Rooms'] ?? empty) {
      RoomBuilder builder = RoomBuilder();
      _parseCard(entry, builder, languageCode);
      builder.level = entry['Level'];
      _quest!.add(builder.build());
    }

    for (var entry in node['Monsters'] ?? empty) {
      MonsterBuilder builder = new MonsterBuilder();
      _parseCard(entry, builder, languageCode);
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

  // Look up the localized name for an entry. If no localized entry is available,
  // or the language code is null, return the default value.
  String _lookupLocalized(var node, String key, String? languageCode) {
    if (languageCode != null) {
      return node['${key}_$languageCode'] ?? node[key];
    } else {
      return node[key];
    }
  }

  // Parse the shared elements of all cards
  void _parseCard(var entry, CardBuilder cardBuilder, String? languageCode) {
    if (_quest == null)
      throw Exception("_quest must be initialized before calling this method");
    cardBuilder.quest = _quest!;
    cardBuilder.name = _lookupLocalized(entry, 'Name', languageCode);
    if (entry['Keywords'] != null) {
      for (var keyword in entry['Keywords']) {
        cardBuilder.keywords.add(keyword);
      }
    }

    cardBuilder.canonicalName = entry['Name'];

    cardBuilder.memo = _processLocalizedMemo(entry, 'Memo', languageCode);

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
  }

  // If the language code is set, then look for a localized version first
  // and use that. If not, fall back to English, if there is one.
  String? _processLocalizedMemo(var entry, String key, String? languageCode) {
    if (languageCode != null) {
      final localizedKey = '${key}_$languageCode';
      if (entry[localizedKey] != null) {
        return entry[localizedKey];
      }
    }
    if (entry[key] != null) {
      return entry[key];
    }
    return null;
  }
}
