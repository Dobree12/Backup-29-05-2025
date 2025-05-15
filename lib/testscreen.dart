import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseTestScreen extends StatelessWidget {
  FirebaseTestScreen({super.key});

  final String uid = FirebaseAuth.instance.currentUser!.uid;
  late final CollectionReference people = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('people');

  Future<void> addPerson() async {
    try {
      await people.add({
        'name': 'John Doe',
        'age': 30,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('✅ Person added to Firestore');
    } catch (e) {
      print('❌ Error adding person: $e');
    }
  }

  Future<void> deletePerson(String docId) async {
    try {
      await people.doc(docId).delete();
      print('🗑️ Person deleted');
    } catch (e) {
      print('❌ Error deleting person: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Test'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                FirebaseAuth.instance.signOut();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Log out'),
              ),
            ],
            icon: const Icon(Icons.account_circle),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: people.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No data found.'));
          }

          final docs = snapshot.data!.docs;
          return ListView(
            children: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['name'] ?? 'No name'),
                subtitle: Text('Age: ${data['age']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => deletePerson(doc.id),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addPerson,
        child: const Icon(Icons.add),
      ),
    );
  }
}
