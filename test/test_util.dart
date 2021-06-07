import 'package:flutter_tqr/models/database.dart';

CardBuilder _assembleBuilder(CardBuilder builder,
    {List<String>? keywords, List<String>? combo, List<String>? meta}) {
  builder.quest = Quest("Quest");
  builder.name = "Name";

  if (keywords != null) builder.keywords = keywords;
  if (combo != null) builder.combo = combo.toSet();
  if (meta != null) builder.meta = meta.toSet();

  return builder;
}

Monster makeMonster(
    {List<String>? keywords, List<String>? combo, List<String>? meta}) {
  var builder = MonsterBuilder();
  _assembleBuilder(builder, keywords: keywords, combo: combo, meta: meta);
  return builder.build();
}

Hero makeHero(
    {List<String>? keywords, List<String>? combo, List<String>? meta}) {
  var builder = HeroBuilder();
  _assembleBuilder(builder, keywords: keywords, combo: combo, meta: meta);
  return builder.build();
}

MarketplaceCard makeMarketplaceCard(
    {List<String>? keywords, List<String>? combo, List<String>? meta}) {
  var builder = MarketplaceCardBuilder();
  _assembleBuilder(builder, keywords: keywords, combo: combo, meta: meta);
  return builder.build();
}
