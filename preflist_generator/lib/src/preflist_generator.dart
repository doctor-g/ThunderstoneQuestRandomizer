import 'dart:async';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';

class PrefListGenerator extends Generator {
  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    var buffer = StringBuffer();

    library.classes
        .where((element) => element.name == 'SettingsModel')
        .forEach((classElement) {
      var prefs = classElement.fields.where(
          (element) => element.type.getDisplayString().endsWith('Preference'));

      if (prefs.length > 0) {
        buffer.write(
            'extension PreferenceManager on SettingsModel {\n List<Preference> get allPrefs => [');
        var names = prefs.map((element) => '${element.name}').toList();
        buffer.write(names.join(','));
        buffer.writeln('];\n');

        prefs.forEach((pref) {
          if (pref.name![0] != '_') {
            throw UnsupportedError('Preference variables must be private');
          }

          // Strip off leading '_'
          var name = '${pref.name}'.substring(1);

          // Find the type of preference (the parameter to Preference<T>)
          var type = (pref.type.element as ClassElement)
              .allSupertypes
              .where((element) =>
                  element.getDisplayString().startsWith('Preference'))
              .first
              .typeArguments[0];

          // Generate accessor and mutator
          buffer.writeln('$type get $name => ${pref.name}.value;');
          buffer
              .writeln('set $name($type value) => ${pref.name}.value = value;');
        });

        buffer.writeln('}');
      }
    });
    return buffer.toString();
  }
}
