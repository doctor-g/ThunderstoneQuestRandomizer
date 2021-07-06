import 'dart:async';

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

class PrefListGenerator extends Generator {
  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    var buffer = StringBuffer();

    for (final classElement in library.classes) {
      var prefs = classElement.fields.where((element) =>
          element.type.getDisplayString(withNullability: false) ==
          'BoolPreference');

      if (prefs.length > 0) {
        buffer.write(
            'extension PrefList on SettingsModel {\n List<BoolPreference> get allPrefs => [');
        var names = prefs.map((element) => '${element.name}').toList();
        buffer.write(names.join(','));
        buffer.writeln('];\n');

        prefs.forEach((pref) {
          if (pref.name[0] != '_') {
            throw UnsupportedError('Preference variables must be private');
          }
          var name = '${pref.name}'.substring(1); // Strip off leading '_'
          buffer.writeln('bool get $name => ${pref.name}.value;');
          buffer
              .writeln('set $name(bool value) => ${pref.name}.value = value;');
        });

        buffer.writeln('}');
      }
    }
    return buffer.toString();
  }
}
