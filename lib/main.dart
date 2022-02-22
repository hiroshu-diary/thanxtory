import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutterfire_ui/auth.dart';
import 'package:provider/provider.dart';
import 'package:thanxtory/pages/home/home_page.dart';
import 'model/scaffold_messenger_controller.dart';
import 'routes/routes.dart';

//todo リリース前に20220309に変える

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => GlobalKey<NavigatorState>()),
        Provider(create: (_) => ScaffoldMessengerController()),
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

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providerConfigs: [
              Platform.isIOS
                  ? const AppleProviderConfiguration()
                  : const GoogleProviderConfiguration(
                      clientId:
                          '369803051167-n1ab0tnulgn6e7s09jtldijococ22nsa.apps.googleusercontent.com',
                    )

              ///端末がiOSで、もしeGiftを受けとったらGoogle認証を行わせる
            ],
          );
        }
        return const ScaffoldMessengerNavigator();
      },
    );
  }
}

class ScaffoldMessengerNavigator extends StatelessWidget {
  const ScaffoldMessengerNavigator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: context.select<ScaffoldMessengerController, Key>(
          (c) => c.scaffoldMessengerKey),
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
      // child: const HomePage(),
    );
  }
}
