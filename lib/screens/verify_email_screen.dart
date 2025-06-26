import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackit/screens/login_screen.dart';
import 'package:trackit/screens/home_screen.dart';
import 'package:trackit/screens/complete_profile_screen.dart';
import 'package:trackit/screens/trainer_home_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool emailSent = false;
  String? message;
  Timer? checkTimer;

  @override
  void initState() {
    super.initState();
    startAutoCheck();
  }

  @override
  void dispose() {
    checkTimer?.cancel();
    super.dispose();
  }

  void startAutoCheck() {
    checkTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      final user = FirebaseAuth.instance.currentUser!;
      await user.reload();
      if (user.emailVerified) {
        timer.cancel();
        if (mounted) {
          await _handleRedirectAfterEmailVerification(user);
        }
      }
    });
  }

  Future<void> _handleRedirectAfterEmailVerification(User user) async {
  final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  final data = doc.data();

  if (data == null) return;

  final role = data['role'] ?? 'user';
  final profileCompleted = data['profileCompleted'] == true;

  if (role == 'trainer') {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => TrainerHomeScreen()),
    );
  } else if (profileCompleted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  } else {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CompleteProfileScreen()),
    );
  }
}


  Future<void> sendVerificationEmail() async {
    final user = FirebaseAuth.instance.currentUser!;
    await user.sendEmailVerification();
    setState(() {
      emailSent = true;
      message = '✅ Email trimis. Verifica-ti inboxul.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email_outlined, size: 80, color: Colors.cyan),
              const SizedBox(height: 24),
              Text(
                'Confirma adresa de email',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Ti-am trimis un email de verificare. Dupa ce l-ai confirmat, vei fi redirectionat automat.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (message != null)
                Text(
                  message!,
                  style: TextStyle(
                    color: message!.startsWith('✅') ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: sendVerificationEmail,
                icon: const Icon(Icons.send),
                label: const Text('Trimite din nou'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (mounted) {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                  }
                },
                child: const Text('Revino la autentificare'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
