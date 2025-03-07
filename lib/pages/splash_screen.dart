import 'Auth.dart';
import 'home.dart';
import 'package:flutter/material.dart';

import 'package:supabase_auth_ui/supabase_auth_ui.dart';

final activeSession = Supabase.instance.client.auth.currentSession;

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: activeSession == null ? AuthScreen() : HomeScreen()),
    );
  }
}