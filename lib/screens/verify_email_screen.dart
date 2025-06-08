import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackit/screens/login_screen.dart';
import 'package:trackit/screens/home_screen.dart';
import 'package:trackit/screens/complete_profile_screen.dart';


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
    checkTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
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

    if (data != null && data['profileCompleted'] == true) {
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
      message = '✅ Email trimis. Verifică-ți inboxul.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificare email')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Contul a fost creat. Te rugăm să confirmi emailul pentru a continua.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            if (message != null)
              Text(
                message!,
                style: TextStyle(
                  color: message!.startsWith('✅') ? Colors.green : Colors.red,
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendVerificationEmail,
              child: const Text('Trimite din nou emailul de verificare'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
              child: const Text('Revino la autentificare'),
            ),
          ],
        ),
      ),
    );
  }
}
