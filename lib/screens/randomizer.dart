import 'package:flutter/material.dart';
import 'package:flutter_tqr/models/database.dart' as tq;
import 'package:flutter_tqr/models/settings.dart';
import 'package:flutter_tqr/models/tableau.dart';
import 'package:flutter_tqr/util/randomizer.dart';
import 'package:provider/provider.dart';

class RandomizerPage extends StatefulWidget {
  final tq.CardDatabase database;

  RandomizerPage(tq.CardDatabase database) : database = database;

  @override
  _RandomizerPageState createState() => _RandomizerPageState();
}

class _RandomizerPageState extends State<RandomizerPage> {
  Randomizer _randomizer = new Randomizer();
  Tableau _tableau;

  void _generateTableau(BuildContext context) {
    setState(() {
      _tableau = _randomizer.generateTableau(
          widget.database, Provider.of<SettingsModel>(context));
    });
  }

  @override
  Widget build(BuildContext context) {
    final market = _tableau == null ? null : _tableau.marketplace;
    return Scaffold(
      appBar: AppBar(
        title: Text('Thunderstone Quest Randomizer'),
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _tableau == null
                ? [Text('Ready!', style: Theme.of(context).textTheme.subtitle1)]
                : [
                    ..._section('Heroes', _tableau.heroes),
                    Divider(),
                    ..._section('Marketplace'),
                    ..._subsection('Spells', market.allSpells),
                    ..._subsection('Items', market.allItems),
                    ..._subsection('Weapons', market.allWeapons),
                    ..._subsection('Allies', market.allAllies),
                    Divider(),
                    ..._section('Guardian', [_tableau.guardian]),
                    Divider(),
                    ..._section('Dungeon'),
                    ..._subsection('Level 1', _tableau.dungeon.roomsMap[1]),
                    ..._subsection('Level 2', _tableau.dungeon.roomsMap[2]),
                    ..._subsection('Level 3', _tableau.dungeon.roomsMap[3]),
                    Divider(),
                    ..._section('Monsters'),
                    ..._subsection('Level 1', [_tableau.monsters[0]]),
                    ..._subsection('Level 2', [_tableau.monsters[1]]),
                    ..._subsection('Level 3', [_tableau.monsters[2]]),
                  ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _generateTableau(context),
        tooltip: 'Randomize',
        child: ImageIcon(AssetImage("assets/dice.png")),
      ),
    );
  }

  int _cardSorter(tq.Card card1, tq.Card card2) =>
      card1.name.compareTo(card2.name);

  List<Widget> _section(String name, [List<tq.Card> contents]) {
    var result = <Widget>[
      Text(name, style: Theme.of(context).textTheme.subtitle1)
    ];
    if (contents != null) {
      contents.sort(_cardSorter);
      result.addAll(contents.map((card) => CardWidget(card: card)).toList());
    }
    return result;
  }

  List<Widget> _subsection(String name, List<tq.Card> contents) {
    if (contents.isEmpty) {
      return <Widget>[];
    } else {
      contents.sort(_cardSorter);
      return [
        Text(name, style: Theme.of(context).textTheme.subtitle2),
        ...contents.map((card) => CardWidget(card: card)).toList()
      ];
    }
  }
}

class CardWidget extends StatelessWidget {
  final tq.Card card;

  CardWidget({Key key, this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          card.name +
              (card.runtimeType == tq.Guardian
                  ? ' (Level ${_toRoman((card as tq.Guardian).level)})'
                  : ''),
          style: Theme.of(context).textTheme.bodyText1,
          textAlign: TextAlign.center,
        ),
        Row(
          children: _makeKeywordRow(context, card.keywords),
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ],
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
      default:
        throw Exception('Unexpected guardian level: $level');
    }
  }

  List<Widget> _makeKeywordRow(BuildContext context, List<String> keywords) {
    List<Widget> result = new List();
    for (var i = 0; i < keywords.length; i++) {
      result
          .add(Text(keywords[i], style: Theme.of(context).textTheme.bodyText2));
      if (i < keywords.length - 1) {
        result.add(Text(' • '));
      }
    }
    return result;
  }
}
