import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trackit/screens/verify_email_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  String selectedRole = 'user';
  String? errorMessage;

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

          final user = credential.user!;
    await user.reload(); // 🔁 reîncarcă statusul din Firebase
    final refreshedUser = FirebaseAuth.instance.currentUser!;

    // Salvează userul în Firestore
    await FirebaseFirestore.instance.collection('users').doc(refreshedUser.uid).set({
      'email': email,
      'role': selectedRole,
      'createdAt': FieldValue.serverTimestamp(),
      'profileCompleted': selectedRole == 'trainer' ? true : false,
    });

    // Trimite emailul de verificare
    await refreshedUser.sendEmailVerification();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => errorMessage = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Icon(Icons.person_add, size: 80, color: Colors.cyanAccent),
                    const SizedBox(height: 16),
                    const Text(
                      'Înregistrare',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (errorMessage != null)
                      Text(errorMessage!, style: const TextStyle(color: Colors.redAccent)),
                    const SizedBox(height: 12),
                    _buildTextField(emailController, 'Email', Icons.email, false, (value) {
                      if (value == null || value.trim().isEmpty) return 'Completează emailul';
                      return null;
                    }),
                    const SizedBox(height: 12),
                    _buildTextField(passwordController, 'Parolă', Icons.lock, true, (value) {
                      if (value == null || value.trim().isEmpty) return 'Completează parola';
                      if (value.length < 6) return 'Parola trebuie să aibă cel puțin 6 caractere';
                      return null;
                    }),
                    const SizedBox(height: 12),
                    _buildTextField(confirmController, 'Confirmare parolă', Icons.lock_outline, true, (value) {
                      if (value == null || value.trim().isEmpty) return 'Confirmă parola';
                      if (value != passwordController.text) return 'Parolele nu coincid';
                      return null;
                    }),
                    const SizedBox(height: 12),
                    _buildDropdownField(),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Creează cont'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, bool obscure, String? Function(String?) validator) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.cyanAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonFormField<String>(
        value: selectedRole,
        dropdownColor: const Color(0xFF1E1E2F),
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.account_circle, color: Colors.cyanAccent),
          hintText: 'Tip cont',
          hintStyle: TextStyle(color: Colors.white54),
          border: InputBorder.none,
        ),
        items: const [
          DropdownMenuItem(
            value: 'user',
            child: Text('Utilizator', style: TextStyle(color: Colors.white)),
          ),
          DropdownMenuItem(
            value: 'trainer',
            child: Text('Antrenor', style: TextStyle(color: Colors.white)),
          ),
        ],
        onChanged: (value) {
          setState(() => selectedRole = value ?? 'user');
        },
      ),
    );
  }
}
