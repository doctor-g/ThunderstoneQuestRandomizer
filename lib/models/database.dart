import 'package:flutter/foundation.dart';
import 'package:flutter_tqr/domain_model.dart';

class CardDatabaseModel extends ChangeNotifier {
  CardDatabase _database;

  CardDatabase get database => _database;

  set database(CardDatabase database) {
    assert(database != null);
    this._database = database;
    print('Database is now $database');
    notifyListeners();
  }
}
