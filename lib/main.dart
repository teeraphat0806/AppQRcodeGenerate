import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrcodegenerator/pages/Auth.dart';
import 'package:qrcodegenerator/pages/createQr.dart';
import 'package:qrcodegenerator/pages/home.dart';
import 'package:qrcodegenerator/pages/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['API_URL'] ?? '', 
    anonKey: dotenv.env['API_KEY'] ?? '',
  );

  runApp(ProviderScope(child: MyApp()));
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Auth UI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/auth': (context) => AuthScreen(),
        '/home': (context) => HomeScreen(),
        '/createqr': (context) => CreateQr(),
      },
    );
  }
}

