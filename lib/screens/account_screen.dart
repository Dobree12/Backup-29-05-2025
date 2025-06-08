import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  String? gender;
  String email = '';

  bool loading = true;

  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = doc.data();

    if (data != null) {
      nameController.text = data['name'] ?? '';
      ageController.text = (data['age'] ?? '').toString();
      weightController.text = (data['weight'] ?? '').toString();
      heightController.text = (data['height'] ?? '').toString();
      gender = data['gender'];
      email = data['email'] ?? '';
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'name': nameController.text.trim(),
      'age': int.tryParse(ageController.text),
      'weight': double.tryParse(weightController.text),
      'height': double.tryParse(heightController.text),
      'gender': gender,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil actualizat')),
    );
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profilul meu')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Email: $email', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nume complet'),
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: 'Vârstă'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: weightController,
              decoration: const InputDecoration(labelText: 'Greutate (kg)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: heightController,
              decoration: const InputDecoration(labelText: 'Înălțime (cm)'),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value: gender,
              items: ['Masculin', 'Feminin', 'Altul'].map((value) {
                return DropdownMenuItem(value: value, child: Text(value));
              }).toList(),
              onChanged: (val) => setState(() => gender = val),
              decoration: const InputDecoration(labelText: 'Sex'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveChanges,
              child: const Text('Salvează modificările'),
            ),
          ],
        ),
      ),
    );
  }
}
