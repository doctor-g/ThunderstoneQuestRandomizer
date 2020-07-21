import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tqr/models/database.dart';
import 'package:flutter_tqr/models/settings.dart';
import 'package:flutter_tqr/parser.dart';
import 'package:flutter_tqr/randomizer.dart';
import 'package:flutter_tqr/screens/settings.dart';
import 'package:provider/provider.dart';
import 'domain_model.dart' as tq;

void main() {
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(
        create: (context) => CardDatabaseModel(),
      ),
      ChangeNotifierProvider(
        create: (context) => SettingsModel(),
      ),
    ], child: TQRandomizerApp()),
  );
}

class TQRandomizerApp extends StatelessWidget {
  void _initData(BuildContext context) async {
    String data = await rootBundle.loadString('assets/cards.yaml');
    ThunderstoneYamlCardParser parser = new ThunderstoneYamlCardParser();
    var db = parser.parse(data);
    Provider.of<CardDatabaseModel>(context).database = db;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (Provider.of<CardDatabaseModel>(context).database == null) {
      _initData(context);
    }

    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => RandomizerPage(),
        '/settings': (context) => SettingsPage()
      },
      title: 'Thunderstone Quest Randomizer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class RandomizerPage extends StatefulWidget {
  @override
  _RandomizerPageState createState() => _RandomizerPageState();
}

class _RandomizerPageState extends State<RandomizerPage> {
  tq.CardDatabase _db;
  Randomizer _randomizer = new Randomizer();
  List<tq.Hero> _heroes = new List();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    String data = await rootBundle.loadString('assets/cards.yaml');
    ThunderstoneYamlCardParser parser = new ThunderstoneYamlCardParser();
    var db = parser.parse(data);
    setState(() => _db = db);
  }

  void _incrementCounter(BuildContext context) {
    List<tq.Hero> heroes =
        _randomizer.chooseHeroes(_db, Provider.of<SettingsModel>(context));
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
        child: _db == null
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _heroes.isEmpty
                    ? [Text('Ready!')]
                    : _heroes
                        .map((hero) => HeroCardWidget(hero: hero))
                        .toList(),
              ),
      ),
      floatingActionButton: _db == null
          ? Container()
          : FloatingActionButton(
              onPressed: () => _incrementCounter(context),
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
