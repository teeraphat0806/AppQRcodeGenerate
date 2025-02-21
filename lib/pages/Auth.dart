import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24.0, 96.0, 24.0, 24.0),
        children: [
          Column(
            children: [
              const Text(
                'QRCode Generator',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 24.0),
              SupaEmailAuth(
                redirectTo: "io.supabase.flutter://",
                onSignInComplete: (res) => Navigator.of(context).pushReplacementNamed('/home'),
                onSignUpComplete: (res) => Navigator.of(context).pushReplacementNamed('/home'),
                onError: (error) => ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text(error.toString()))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}