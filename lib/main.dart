import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChrome;
import 'package:gps_maps/screens/map_view.dart';
import 'package:gps_maps/setup_locator.dart';
import 'package:gps_maps/states/app_state.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';
import 'package:after_layout/after_layout.dart';

/// Main function to run application
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIOverlays([]);

  setupLocator();

  Wakelock.enable();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (context) => AppState(),
      child: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AfterLayoutMixin<HomeScreen> {
  // init state
  @override
  void initState() {
    super.initState();
    print('ini initstate');
  }

  @override
  void afterFirstLayout(BuildContext context) {
    Provider.of<AppState>(context).initializationProcess();
    print('ini afterFirstLayout');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: MapsView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
