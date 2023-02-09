import 'package:flutter/material.dart';
import 'package:hms_callkit/Utilities.dart';
import 'package:hms_callkit/app_router.dart';
import 'package:hms_callkit/home_page.dart';
import 'package:hms_callkit/navigation_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override 
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>  with WidgetsBindingObserver{
  @override
  void initState() {
    super.initState();
    initFirebase();
    WidgetsBinding.instance.addObserver(this);
    //Checks call when open app from terminated
  }


  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    print("HMSSDK $state");
    if (state == AppLifecycleState.resumed) {
      //Checks call when app is brought back from background
      checkAndNavigationCallingPage();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "HMS-Callkit Demo",
      onGenerateRoute: AppRoute.generateRoute,
      initialRoute: AppRoute.homePage,
      navigatorKey: NavigationService.instance.navigationKey,
      navigatorObservers: <NavigatorObserver>[
        NavigationService.instance.routeObserver
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
