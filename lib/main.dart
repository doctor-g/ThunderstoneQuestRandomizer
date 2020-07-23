import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tqr/models/settings.dart';
import 'package:flutter_tqr/screens/randomizer.dart';
import 'package:flutter_tqr/util/parser.dart';
import 'package:flutter_tqr/screens/about.dart';
import 'package:flutter_tqr/screens/settings.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tqr/models/database.dart' as tq;

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
            _database == null ? Container() : SettingsPage(_database),
        '/about': (context) => AboutPage(),
      },
      title: 'Thunderstone Quest Randomizer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          subtitle1: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          subtitle2: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
          bodyText1: TextStyle(fontSize: 16),
          bodyText2: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
        ),
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
