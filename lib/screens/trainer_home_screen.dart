import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trackit/screens/home_screen.dart';

class TrainerHomeScreen extends StatefulWidget {
  const TrainerHomeScreen({super.key});

  @override
  State<TrainerHomeScreen> createState() => _TrainerHomeScreenState();
}

class _TrainerHomeScreenState extends State<TrainerHomeScreen> {
  final _auth = FirebaseAuth.instance;
  String _searchQuery = '';

  void _showAddClientSheet() {
    final nameController = TextEditingController();
    final heightController = TextEditingController();
    final weightController = TextEditingController();
    String sex = 'masculin';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Adaugă client nou',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Nume complet',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: sex,
                decoration: InputDecoration(
                  labelText: 'Sex',
                  prefixIcon: const Icon(Icons.wc),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'masculin', child: Text('Masculin')),
                  DropdownMenuItem(value: 'feminin', child: Text('Feminin')),
                ],
                onChanged: (value) => sex = value!,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: heightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Înălțime (cm)',
                  prefixIcon: const Icon(Icons.height),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Greutate (kg)',
                  prefixIcon: const Icon(Icons.monitor_weight),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Anulează'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final name = nameController.text.trim();
                      final height = int.tryParse(heightController.text.trim());
                      final weight = int.tryParse(weightController.text.trim());

                      if (name.isEmpty || height == null || weight == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Completează toate câmpurile corect.')),
                        );
                        return;
                      }

                      final trainerId = _auth.currentUser!.uid;

                      await FirebaseFirestore.instance
                          .collection('trainers')
                          .doc(trainerId)
                          .collection('clients')
                          .add({
                        'name': name,
                        'sex': sex,
                        'height': height,
                        'weight': weight,
                      });

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Client adăugat cu succes!')),
                      );
                    },
                    child: const Text('Adaugă'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteClient(String clientId, String clientName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmare'),
        content: Text(
          'Stergi clientul "$clientName" si toate workout-urile asociate? Aceasta actiune este permanenta.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuleaza'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final trainerId = _auth.currentUser!.uid;

              try {
                await FirebaseFirestore.instance
                    .collection('trainers')
                    .doc(trainerId)
                    .collection('clients')
                    .doc(clientId)
                    .delete();

                final snapshot = await FirebaseFirestore.instance
                    .collection('workouts')
                    .where('userId', isEqualTo: clientId)
                    .get();

                final batch = FirebaseFirestore.instance.batch();
                for (final doc in snapshot.docs) {
                  batch.delete(doc.reference);
                }
                await batch.commit();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Client si workout-uri sterse.')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Eroare la stergere: $e')),
                );
              }
            },
            child: const Text('Sterge', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getClients() {
    final trainerId = _auth.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('trainers')
        .doc(trainerId)
        .collection('clients')
        .orderBy('name')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Clientii mei',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddClientSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cauta client...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getClients(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                final filteredDocs = docs.where((doc) {
                  final name = (doc['name'] as String).toLowerCase();
                  return name.contains(_searchQuery);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(child: Text('Nu ai niciun client adaugat.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final data = filteredDocs[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: ListTile(
                        title: Text(data['name'] ?? ''),
                        subtitle: Text('${data['sex']}, ${data['height']} cm, ${data['weight']} kg'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDeleteClient(filteredDocs[index].id, data['name']),
                            ),
                            const Icon(Icons.arrow_forward_ios),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HomeScreen(
                                clientId: filteredDocs[index].id,
                                clientName: data['name'] ?? '',
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
