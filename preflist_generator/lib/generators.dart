import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'src/preflist_generator.dart';

Builder preflistGeneratorBuilder(BuilderOptions options) =>
    SharedPartBuilder([PrefListGenerator()], 'preflist');
