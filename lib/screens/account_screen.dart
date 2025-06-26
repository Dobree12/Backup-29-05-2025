import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const AccountScreen({super.key, required this.isDarkMode, required this.onToggleTheme});

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

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
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

  Future<void> resetPassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email de resetare trimis.')),
      );
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    if (loading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        title: Text(
          'Profilul meu',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          sectionTitle('Date personale', isDark),
          profileField('Email', email, isDark, readOnly: true),
          profileTextField('Nume complet', nameController, isDark),
          profileTextField('Vârstă', ageController, isDark, type: TextInputType.number),
          profileTextField('Greutate (kg)', weightController, isDark, type: TextInputType.number),
          profileTextField('Înălțime (cm)', heightController, isDark, type: TextInputType.number),
          genderDropdown(isDark),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FFFF),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: saveChanges,
            child: const Text('Salvează modificările'),
          ),
          const SizedBox(height: 30),
          sectionTitle('Securitate', isDark),
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.blueAccent),
            title: const Text('Schimbă parola'),
            onTap: () async {
              final result = await showDialog<String>(
                context: context,
                builder: (context) => ChangePasswordDialog(isDark: isDark),
              );
              if (result != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
              }
            },
            textColor: isDark ? Colors.white : Colors.black,
          ),
          ListTile(
            leading: const Icon(Icons.lock_reset, color: Colors.orange),
            title: const Text('Resetează parola'),
            onTap: resetPassword,
            textColor: isDark ? Colors.white : Colors.black,
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmare'),
                  content: const Text('Ești sigur că vrei să te deloghezi?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Anulează'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Deloghează-te'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await logout();
              }
            },
            textColor: isDark ? Colors.white : Colors.black,
          ),
        ],
      ),
    );
  }

  Widget sectionTitle(String title, bool isDark) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      );

  Widget profileTextField(String label, TextEditingController controller, bool isDark, {TextInputType type = TextInputType.text}) =>
      TextField(
        controller: controller,
        keyboardType: type,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: isDark ? Colors.white54 : Colors.grey),
          ),
        ),
      );

  Widget profileField(String label, String value, bool isDark, {bool readOnly = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          '$label: $value',
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      );

  Widget genderDropdown(bool isDark) => DropdownButtonFormField<String>(
        dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        value: gender,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        items: ['Masculin', 'Feminin', 'Altul'].map((value) {
          return DropdownMenuItem(value: value, child: Text(value));
        }).toList(),
        onChanged: (val) => setState(() => gender = val),
        decoration: InputDecoration(
          labelText: 'Sex',
          labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: isDark ? Colors.white54 : Colors.grey),
          ),
        ),
      );
}

class ChangePasswordDialog extends StatefulWidget {
  final bool isDark;
  const ChangePasswordDialog({super.key, required this.isDark});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool loading = false;

  Future<void> changePassword() async {
    if (newPasswordController.text != confirmPasswordController.text) {
      Navigator.pop(context, 'Parolele nu se potrivesc');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    final cred = EmailAuthProvider.credential(
      email: user!.email!,
      password: oldPasswordController.text,
    );

    try {
      setState(() => loading = true);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPasswordController.text);
      Navigator.pop(context, 'Parola a fost schimbata cu succes');
    } catch (e) {
      Navigator.pop(context, 'Parola veche nu este corectă sau a parola nouă nu îndeplinește cerințele de securitate');
    }
  }

 @override
Widget build(BuildContext context) {
 final isDark = Theme.of(context).brightness == Brightness.dark;
  return AlertDialog(
    backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
    title: Text(
      'Schimbă parola',
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
    ),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: oldPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Parola veche'),
          ),
          TextField(
            controller: newPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Parola nouă'),
          ),
          TextField(
            controller: confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Confirmă parola nouă'),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Anulează'),
      ),
      TextButton(
        onPressed: loading ? null : changePassword,
        child: const Text('Salvează'),
      ),
    ],
  );
}
}