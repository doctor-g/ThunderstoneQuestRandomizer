import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tqr/models/settings.dart';
import 'package:flutter_tqr/parser.dart';
import 'package:flutter_tqr/randomizer.dart';
import 'package:flutter_tqr/screens/settings.dart';
import 'package:provider/provider.dart';
import 'domain_model.dart' as tq;

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
  List<tq.Hero> _heroes = new List();

  void _generateHeroes(BuildContext context) {
    List<tq.Hero> heroes = _randomizer.chooseHeroes(
        widget.database, Provider.of<SettingsModel>(context));
    setState(() => _heroes = heroes);
  }

  @override
  Widget build(BuildContext context) {
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
            children: _heroes.isEmpty
                ? [Text('Ready!')]
                : _heroes.map((hero) => HeroCardWidget(hero: hero)).toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _generateHeroes(context),
        tooltip: 'Randomize',
        child: ImageIcon(AssetImage("assets/dice.png")),
      ),
    );
  }
}

class HeroCardWidget extends StatelessWidget {
  final tq.Hero hero;

  HeroCardWidget({Key key, this.hero}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          hero.name,
          style: Theme.of(context).textTheme.headline4,
          textAlign: TextAlign.center,
        ),
        Row(
          children: _makeKeywordRow(hero.keywords),
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ],
    );
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
