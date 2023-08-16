import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tqr/models/settings.dart';
import 'package:flutter_tqr/screens/randomizer.dart';
import 'package:flutter_tqr/util/parser.dart';
import 'package:flutter_tqr/screens/about.dart';
import 'package:flutter_tqr/screens/settings.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tqr/models/database.dart' as tq;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
        create: (context) => SettingsModel(), child: _TQRandomizerApp()),
  );
}

class _TQRandomizerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsModel>(context);
    return ChangeNotifierProvider<tq.CardDatabaseModel>(
      create: (context) => tq.CardDatabaseModel(),
      child: MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => Consumer<tq.CardDatabaseModel>(
                builder: (context, dbmodel, child) => dbmodel.database == null
                    ? _LoadingPage(dbmodel: dbmodel)
                    : RandomizerPage(dbmodel.database!),
              ),
          '/settings': (context) => Consumer<tq.CardDatabaseModel>(
              builder: (context, dbmodel, child) => dbmodel.database == null
                  ? Container()
                  : SettingsPage(dbmodel.database!)),
          '/about': (context) => AboutPage(),
        },
        title: 'Thunderstone Quest Randomizer',
        onGenerateTitle: (BuildContext context) =>
            AppLocalizations.of(context)!.appTitle,
        theme: ThemeData(
          brightness: settings.brightness,
          primarySwatch: Colors.blueGrey,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Cormorant',
          textTheme: TextTheme(
            titleMedium: TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold, height: 1.5),
            titleSmall: TextStyle(
                fontSize: 22, fontStyle: FontStyle.italic, height: 1.5),
            bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            bodyMedium: TextStyle(fontSize: 14),
          ),
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}

class _LoadingPage extends StatefulWidget {
  late final tq.CardDatabaseModel dbmodel;

  _LoadingPage({Key? key, required this.dbmodel}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<_LoadingPage> {
  @override
  void initState() {
    // This will load and parse the cards.yaml file in the app's
    // current language. It would be possible in the future to
    // change the language with a setting, but as of this writing,
    // there is no translation in place, so it would be premature
    // to implement.
    rootBundle.loadString('assets/cards.yaml').then((data) {
      ThunderstoneYamlCardParser parser = new ThunderstoneYamlCardParser();
      var database = parser.parse(data);
      widget.dbmodel.database = database;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
