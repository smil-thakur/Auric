import 'dart:async';

import 'package:auric/screens/home_screen.dart';
import 'package:auric/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:logger/web.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
    await Supabase.initialize(
      url: dotenv.env["SUPABASE_URL"]!,
      anonKey: dotenv.env["SUPABASE_ANON_KEY"]!,
    );
  } catch (err) {
    Logger().f("enable to initialize the App");
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final supabase = Supabase.instance.client;
  StreamSubscription<AuthState>? authSteam;
  User? currentUser;
  @override
  void initState() {
    currentUser = supabase.auth.currentUser;
    authSteam = supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      if (event == AuthChangeEvent.signedIn) {
        setState(() {
          currentUser = session!.user;
        });
      } else if (event == AuthChangeEvent.signedOut) {
        setState(() {
          currentUser = null;
          Get.offAll(() => const WelcomeScreen());
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    if (authSteam != null) {
      authSteam!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShadApp.custom(
      themeMode: ThemeMode.dark,
      darkTheme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadSlateColorScheme.dark(),
      ),

      appBuilder: (context) {
        return GetMaterialApp(
          theme: Theme.of(context),
          home: currentUser != null ? HomeScreen() : WelcomeScreen(),
          builder: (context, child) {
            return ShadAppBuilder(child: child!);
          },
        );
      },
    );
  }
}
