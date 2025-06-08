import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final ageController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  String? selectedGender;

  Future<void> saveProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'age': int.tryParse(ageController.text),
      'weight': double.tryParse(weightController.text),
      'height': double.tryParse(heightController.text),
      'gender': selectedGender,
      'profileCompleted': true,
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void skip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Completează profilul')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Introdu datele tale (opțional):',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Vârstă'),
            ),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Greutate (kg)'),
            ),
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Înălțime (cm)'),
            ),
            DropdownButtonFormField<String>(
              value: selectedGender,
              items: ['Masculin', 'Feminin', 'Altul'].map((value) {
                return DropdownMenuItem(value: value, child: Text(value));
              }).toList(),
              onChanged: (val) => setState(() => selectedGender = val),
              decoration: const InputDecoration(labelText: 'Sex'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveProfileData,
              child: const Text('Salvează'),
            ),
            TextButton(
              onPressed: skip,
              child: const Text('Skip'),
            ),
          ],
        ),
      ),
    );
  }
}
