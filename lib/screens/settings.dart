import 'package:flutter/material.dart';
import 'package:flutter_tqr/models/database.dart';
import 'package:flutter_tqr/models/settings.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Consumer<CardDatabaseModel>(
          builder: (context, value, child) => value.database == null
              ? Text('No data!')
              : Consumer<SettingsModel>(
                  builder: (context, settings, child) => Column(
                      children: value.database.quests
                          .map((quest) => Row(
                                children: [
                                  Checkbox(
                                    value: settings.includes(quest.name),
                                    onChanged: (value) {
                                      if (value) {
                                        settings.include(quest.name);
                                      } else {
                                        settings.exclude(quest.name);
                                      }
                                    },
                                  ),
                                  Text(quest.name)
                                ],
                              ))
                          .toList()),
                ),
        ),
      ),
    );
  }
}
