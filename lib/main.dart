import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'core/di/dependency_injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const PernitApp());
}
