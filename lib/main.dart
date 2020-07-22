import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tqr/models/settings.dart';
import 'package:flutter_tqr/parser.dart';
import 'package:flutter_tqr/randomizer.dart';
import 'package:flutter_tqr/screens/settings.dart';
import 'package:provider/provider.dart';
import 'domain_model.dart' as tq;
import 'models/tableau.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
        create: (context) => SettingsModel(), child: TQRandomizerApp()),
  );
}

class TQRandomizerApp extends StatefulWidget {
  @override
  _TQRandomizerAppState createState() => _TQRandomizerAppState();
}

class _TQRandomizerAppState extends State<TQRandomizerApp> {
  tq.CardDatabase _database;

  @override
  void initState() {
    super.initState();
    _loadCardDatabase();
  }

  void _loadCardDatabase() {
    rootBundle.loadString('assets/cards.yaml').then((data) {
      ThunderstoneYamlCardParser parser = new ThunderstoneYamlCardParser();
      var database = parser.parse(data);
      setState(() {
        _database = database;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) =>
            _database == null ? LoadingPage() : RandomizerPage(_database),
        '/settings': (context) =>
            _database == null ? Container() : SettingsPage(_database)
      },
      title: 'Thunderstone Quest Randomizer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}

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
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _tableau == null
                ? [Text('Ready!')]
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

  List<Widget> _section(String name, [List<tq.Card> contents]) {
    var result = <Widget>[
      Text(name, style: Theme.of(context).textTheme.headline3)
    ];
    if (contents != null) {
      result.addAll(contents.map((card) => CardWidget(card: card)).toList());
    }
    return result;
  }

  List<Widget> _subsection(String name, List<tq.Card> contents) {
    if (contents.isEmpty) {
      return <Widget>[];
    } else {
      return [
        Text(name, style: Theme.of(context).textTheme.headline4),
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
          style: Theme.of(context).textTheme.headline6,
          textAlign: TextAlign.center,
        ),
        Row(
          children: _makeKeywordRow(card.keywords),
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

  List<Widget> _makeKeywordRow(List<String> keywords) {
    List<Widget> result = new List();
    for (var i = 0; i < keywords.length; i++) {
      result.add(Text(keywords[i]));
      if (i < keywords.length - 1) {
        result.add(Text(' • '));
      }
    }
    return result;
  }
}
