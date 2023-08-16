import 'package:flutter/material.dart';
import 'package:flutter_tqr/models/database.dart' as tq;
import 'package:flutter_tqr/models/settings.dart';
import 'package:flutter_tqr/models/tableau.dart';
import 'package:flutter_tqr/util/barricades_blacklist.dart';
import 'package:flutter_tqr/util/randomizer.dart';
import 'package:flutter_tqr/util/tableau_failure.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RandomizerPage extends StatefulWidget {
  final tq.CardDatabase database;

  RandomizerPage(this.database);

  @override
  _RandomizerPageState createState() => _RandomizerPageState();
}

class _RandomizerPageState extends State<RandomizerPage>
    with SingleTickerProviderStateMixin {
  Randomizer _randomizer = new Randomizer();
  Tableau? _tableau;
  bool _failure = false;

  late Animation<double> _animation;
  late AnimationController _controller;

  final _maxWidthForSingleColumn = 600;
  final _forwardDuration = Duration(milliseconds: 500);
  final _backwardDuration = Duration(milliseconds: 250);

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: _forwardDuration)
      ..addListener(() {
        setState(() {});
      });
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
    super.initState();
  }

  void _randomize(BuildContext context) {
    // If there is already one being shown, fade it out.
    // Otherwise, go ahead and generate it.
    if (_tableau != null) {
      _controller.addStatusListener(_animationStatusListener);
      _controller.duration = _backwardDuration;
      _controller.reverse();
    } else {
      _generateTableau(context);
    }
  }

  void _generateTableau(BuildContext context) {
    setState(() {
      try {
        var settings = Provider.of<SettingsModel>(context, listen: false);
        var database = widget.database;
        if (settings.barricadesMode) {
          database = database
              .where((card) => !barricadesBlacklist.contains(card.name));
        }
        _tableau = _randomizer.generateTableau(database, settings);
        _controller.duration = _forwardDuration;
        _controller.forward();
      } on TableauFailureException {
        _failure = true;
        _tableau = null;
      }
    });
  }

  void _animationStatusListener(AnimationStatus status) {
    // 'dismissed' means stopped at the beginning (a.k.a. finished reverse)
    if (status == AnimationStatus.dismissed) {
      _controller.removeStatusListener(_animationStatusListener);
      _generateTableau(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsNotifier = Provider.of<SettingsModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          IconButton(
              icon: Icon(Icons.info),
              onPressed: () => Navigator.pushNamed(context, '/about')),
        ],
      ),
      body: Center(
        child: _tableau == null
            ? (_failure
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(AppLocalizations.of(context)!.home_no_tableau,
                        style: Theme.of(context).textTheme.bodyLarge),
                  )
                : WelcomeMessage())
            : SingleChildScrollView(
                child: FadeTransition(
                  opacity: _animation,
                  child: MediaQuery.of(context).size.width >
                          _maxWidthForSingleColumn
                      ? Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [..._heroesAndMarketplace()],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      ..._guardianAndDungeonAndMonsters()
                                    ],
                                  ),
                                )
                              ],
                            ),
                            _makeModeReminder(context),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ..._heroesAndMarketplace(),
                            Divider(),
                            ..._guardianAndDungeonAndMonsters(),
                            _makeModeReminder(context),
                          ],
                        ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _randomize(context),
        tooltip: AppLocalizations.of(context)!.home_randomize,
        child: ImageIcon(
          AssetImage(settingsNotifier.brightness == Brightness.light
              ? "assets/dice_white.png"
              : "assets/dice_black.png"),
        ),
      ),
    );
  }

  int _cardSorter(tq.Card card1, tq.Card card2) =>
      card1.name.compareTo(card2.name);

  List<Widget> _section(String name, [List<tq.Card>? contents]) {
    var result = <Widget>[
      Text(name, style: Theme.of(context).textTheme.titleMedium)
    ];
    if (contents != null) {
      contents.sort(_cardSorter);
      result.addAll(contents.map((card) => CardWidget(card: card)).toList());
    }
    return result;
  }

  List<Widget> _subsection(String name, List<tq.Card> contents,
      {bool sort = true}) {
    if (contents.isEmpty) {
      return <Widget>[];
    } else {
      if (sort) {
        contents.sort(_cardSorter);
      }
      return [
        _subsectionHeading(name),
        ...contents.map((card) => CardWidget(card: card)).toList()
      ];
    }
  }

  Text _subsectionHeading(String content) =>
      Text(content, style: Theme.of(context).textTheme.titleSmall);

  List<Widget> _heroesAndMarketplace() {
    if (_tableau == null) {
      return [];
    }

    final Marketplace market = _tableau!.marketplace!;

    // Compute this ahead of time so that we don't have to recompute
    // it below.
    final allItems = market.allItems;

    // Damilu Husky is an item and an ally, but a card like this
    // should be listed only once. Hence, we need to remove cards
    // like this from the allies list. As of this writing, the Husky
    // is the only Item and Ally card, but we search for it by these
    // properties rather than by name.
    final List<tq.Card> nonItemAllies = market.allAllies
        .where((element) => !allItems.contains(element))
        .toList();

    return [
      ..._section(
          AppLocalizations.of(context)!.tableau_heroes, _tableau!.heroes),
      Divider(),
      ..._section(AppLocalizations.of(context)!.tableau_marketplace),
      ..._subsection(AppLocalizations.of(context)!.tableau_items, allItems),
      ..._subsection(
          AppLocalizations.of(context)!.tableau_spells, market.allSpells),
      ..._subsection(
          AppLocalizations.of(context)!.tableau_weapons, market.allWeapons),
      ..._subsection(
          AppLocalizations.of(context)!.tableau_allies, nonItemAllies)
    ];
  }

  List<Widget> _guardianAndDungeonAndMonsters() {
    if (_tableau == null) {
      return [];
    } else {
      return [
        ..._section(AppLocalizations.of(context)!.tableau_guardian,
            [_tableau!.guardian!]),
        Divider(),
        ..._section(AppLocalizations.of(context)!.tableau_dungeon),
        ..._subsection(AppLocalizations.of(context)!.tableau_dungeon_level(1),
            _tableau!.dungeon!.roomsMap[1]!,
            sort: false),
        ..._subsection(AppLocalizations.of(context)!.tableau_dungeon_level(2),
            _tableau!.dungeon!.roomsMap[2]!,
            sort: false),
        ..._subsection(AppLocalizations.of(context)!.tableau_dungeon_level(3),
            _tableau!.dungeon!.roomsMap[3]!,
            sort: false),
        Divider(),
        ..._section(AppLocalizations.of(context)!.tableau_monsters),
        _tableau!.wildernessMonster == null
            ? Container()
            : Column(children: [
                _subsectionHeading(
                    AppLocalizations.of(context)!.tableau_wilderness),
                Text(
                    _tableau!.wildernessMonster == WildernessMonster.GiantRat
                        ? AppLocalizations.of(context)!.tableau_wilderness_rat
                        : AppLocalizations.of(context)!
                            .tableau_wilderness_mosquitoes,
                    style: Theme.of(context).textTheme.bodyLarge),
              ]),
        ..._subsection(AppLocalizations.of(context)!.tableau_monster_level(1),
            [_tableau!.monsters![0]]),
        ..._subsection(AppLocalizations.of(context)!.tableau_monster_level(2),
            [_tableau!.monsters![1]]),
        ..._subsection(AppLocalizations.of(context)!.tableau_monster_level(3),
            [_tableau!.monsters![2]]),
      ];
    }
  }

  Widget _makeModeReminder(BuildContext context) {
    List<String> reminders = [];

    final bool barricadesMode = _tableau!.modes.contains(GameMode.Barricades);
    final bool soloMode = _tableau!.modes.contains(GameMode.Solo);
    final bool smallTableauMode =
        _tableau!.modes.contains(GameMode.SmallTableau);

    if (barricadesMode) {
      reminders.add(AppLocalizations.of(context)!.tableau_barricades_hint);
    }
    if (soloMode) {
      reminders.add(AppLocalizations.of(context)!.tableau_solo_hint);
    }
    if (smallTableauMode) {
      reminders.add(AppLocalizations.of(context)!.tableau_smallTableau_hint);
    }

    String reminder = reminders.join(" • ");

    if (reminder != "") {
      return Column(
        children: [
          Divider(),
          Text(reminder,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontFamily: 'CormorantSC')),
        ],
      );
    } else {
      return SizedBox();
    }
  }
}

class WelcomeMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(AppLocalizations.of(context)!.appTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(AppLocalizations.of(context)!.home_instructions,
                style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

class CardWidget extends StatelessWidget {
  late final tq.Card card;

  CardWidget({Key? key, required tq.Card card}) : super(key: key) {
    this.card = card;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsModel>(
      builder: (BuildContext context, SettingsModel settings, Widget? child) =>
          Column(
        children: <Widget>[
          Text(
            card.getLocalizedName(settings.language) +
                (card.runtimeType == tq.Guardian
                    ? '\n' +
                        AppLocalizations.of(context)!.tableau_guardian_level(
                            _toRoman((card as tq.Guardian).level!))
                    : ''),
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          settings.showQuest
              ? Text(card.quest.number == null
                  ? card.quest.getLocalizedName(settings.language)
                  : AppLocalizations.of(context)!.tableau_quest_source(
                      card.quest.number!,
                      card.quest.getLocalizedName(settings.language)))
              : Container(),
          settings.showKeywords
              ? Wrap(
                  children: _makeKeywordRow(context, card.keywords),
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.center,
                )
              : Container(),
          card.getLocalizedMemo(settings.language) == null || !settings.showMemo
              ? Container()
              : ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 400),
                  child: Text(card.getLocalizedMemo(settings.language)!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
          Container(
            height: 6,
          )
        ],
      ),
    );
  }

  String _toRoman(int level) {
    switch (level) {
      case 4:
        return 'IV';
      case 5:
        return 'V';
      case 6:
        return 'VI';
      case 7:
        return 'VII';
      default:
        throw Exception('Unexpected guardian level: $level');
    }
  }

  List<Widget> _makeKeywordRow(BuildContext context, List<String> keywords) {
    List<Widget> result = [];
    for (var i = 0; i < keywords.length; i++) {
      result.add(Text(keywords[i],
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontFamily: 'CormorantSC')));
      if (i < keywords.length - 1) {
        result.add(Text(' • '));
      }
    }
    return result;
  }
}
