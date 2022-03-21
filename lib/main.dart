import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thanxtory/pages/home/home_page.dart';
import 'package:thanxtory/pages/login/login_page.dart';

import 'firebase_options.dart';
import 'model/constant.dart';
import 'model/scaffold_messenger_controller.dart';
import 'routes/routes.dart';

var isFirstLaunch = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var _prefs = await SharedPreferences.getInstance();
  _prefs.setBool('isFirstLaunch', true);
  var isFirstLaunch = _prefs.getBool('isFirstLaunch') ?? true;
  if (isFirstLaunch) {
    try {
      FirebaseAuth.instance.signOut();
      _prefs.setBool('isFirstLaunch', false);
    } on Exception {
      print('ERROR');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => GlobalKey<NavigatorState>()),
        Provider(create: (_) => SMController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.black54,
        ),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(color: C.subColor);
        }
        if (snapshot.hasData) {
          return const ScaffoldMessengerNavigator();
        }
        return const LoginPage();
      },
    );
  }
}

class ScaffoldMessengerNavigator extends StatelessWidget {
  const ScaffoldMessengerNavigator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: context.select<SMController, Key>((c) => c.scaffoldMessengerKey),
      child: Scaffold(
        body: Navigator(
          key: context.watch<GlobalKey<NavigatorState>>(),
          initialRoute: HomePage.path,
          onGenerateRoute: (rootSettings) {
            return MaterialPageRoute<dynamic>(
              settings: rootSettings,
              builder: (context) {
                return routeBuilder[rootSettings.name]!(context);
              },
            );
          },
        ),
      ),
    );
  }
}
