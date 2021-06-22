import 'package:flutter_tqr/models/database.dart';

CardBuilder _assembleBuilder(CardBuilder builder,
    {String? name,
    Map<String, String>? localizedNames,
    String? memo,
    Map<String, String>? localizedMemos,
    List<String>? keywords,
    List<String>? combo,
    List<String>? meta}) {
  builder.quest = Quest("Quest");
  builder.name = name ?? "Name";

  if (localizedNames != null) builder.localizedNames.addAll(localizedNames);
  if (keywords != null) builder.keywords = keywords;
  if (combo != null) builder.combo = combo.toSet();
  if (meta != null) builder.meta = meta.toSet();
  if (memo != null) builder.memo = memo;
  if (localizedMemos != null) builder.localizedMemos.addAll(localizedMemos);

  return builder;
}

Monster makeMonster(
    {List<String>? keywords, List<String>? combo, List<String>? meta}) {
  var builder = MonsterBuilder();
  _assembleBuilder(builder, keywords: keywords, combo: combo, meta: meta);
  return builder.build();
}

Hero makeHero(
    {String? name,
    Map<String, String>? localizedNames,
    String? memo,
    Map<String, String>? localizedMemos,
    List<String>? keywords,
    List<String>? combo,
    List<String>? meta}) {
  var builder = HeroBuilder();
  _assembleBuilder(builder,
      name: name,
      localizedNames: localizedNames,
      memo: memo,
      localizedMemos: localizedMemos,
      keywords: keywords,
      combo: combo,
      meta: meta);
  return builder.build();
}

MarketplaceCard makeMarketplaceCard(
    {String? name,
    List<String>? keywords,
    List<String>? combo,
    List<String>? meta}) {
  var builder = MarketplaceCardBuilder();
  _assembleBuilder(builder,
      name: name, keywords: keywords, combo: combo, meta: meta);
  return builder.build();
}
