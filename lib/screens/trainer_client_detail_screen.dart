import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trackit/screens/create_workout_screen.dart';
import 'package:trackit/screens/workout_detail_screen.dart';
import 'package:trackit/models/workout_model.dart';

class TrainerClientDetailScreen extends StatefulWidget {
  final String clientId;
  final String clientName;

  const TrainerClientDetailScreen({
    Key? key,
    required this.clientId,
    required this.clientName,
  }) : super(key: key);

  @override
  State<TrainerClientDetailScreen> createState() => _TrainerClientDetailScreenState();
}

class _TrainerClientDetailScreenState extends State<TrainerClientDetailScreen> {
  String _searchQuery = '';
  bool _sortDescending = true;
  DateTime? _selectedMonth;

  Stream<List<Workout>> _getClientWorkouts() {
    return FirebaseFirestore.instance
        .collection('workouts')
        .where('userId', isEqualTo: widget.clientId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final map = doc.data() as Map<String, dynamic>;
              map['id'] = doc.id;
              return Workout.fromMap(map);
            }).toList());
  }

  void _goToCreateWorkout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateWorkoutScreen(
          predefinedUserId: widget.clientId,
        ),
      ),
    );
  }

  void _goToWorkoutDetail(Workout workout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutDetailScreen(workout: workout),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Client: ${widget.clientName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyanAccent,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: _goToCreateWorkout,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Caută după nume',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _sortDescending ? Icons.arrow_downward : Icons.arrow_upward,
                  ),
                  onPressed: () {
                    setState(() => _sortDescending = !_sortDescending);
                  },
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.calendar_month),
                  label: Text(_selectedMonth == null
                      ? 'Filtru lună'
                      : '${_selectedMonth!.month}/${_selectedMonth!.year}'),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      helpText: 'Alege luna și anul',
                    );

                    if (picked != null) {
                      setState(() => _selectedMonth = picked);
                    }
                  },
                ),
                if (_selectedMonth != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _selectedMonth = null),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<Workout>>(
              stream: _getClientWorkouts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final all = snapshot.data ?? [];

                var filtered = all.where((w) {
                  final matchesName = w.name.toLowerCase().contains(_searchQuery);
                  final matchesMonth = _selectedMonth == null ||
                      (w.date.month == _selectedMonth!.month &&
                          w.date.year == _selectedMonth!.year);
                  return matchesName && matchesMonth;
                }).toList();

                filtered.sort((a, b) =>
                    _sortDescending ? b.date.compareTo(a.date) : a.date.compareTo(b.date));

                if (filtered.isEmpty) {
                  return const Center(child: Text('Niciun workout găsit.'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final workout = filtered[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(workout.name),
                        subtitle: Text(
                          '${workout.exercises.length} exerciții • ${workout.date.day}/${workout.date.month}/${workout.date.year}',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _goToWorkoutDetail(workout),
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
