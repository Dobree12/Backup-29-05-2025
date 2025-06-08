import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/workout_model.dart';
import '../models/workout_set.dart';
import '../providers/workout_provider.dart';
import 'package:provider/provider.dart';

class EditWorkoutScreen extends StatefulWidget {
  final Workout workout;

  const EditWorkoutScreen({super.key, required this.workout});

  @override
  State<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends State<EditWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late List<WorkoutExercise> _exercises;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.workout.name);
    _exercises = widget.workout.exercises.map((e) => WorkoutExercise(
      id: e.id,
      exercise: e.exercise,
      sets: e.sets.map((s) => WorkoutSet(
        id: s.id,
        reps: s.reps,
        weight: s.weight,
        timestamp: s.timestamp,
      )).toList(),
    )).toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final updatedWorkout = Workout(
        id: widget.workout.id,
        name: _nameController.text.trim(),
        date: widget.workout.date,
        exercises: _exercises,
      );

      final provider = Provider.of<WorkoutProvider>(context, listen: false);
      await provider.updateWorkout(updatedWorkout);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Workout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Workout Name'),
              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            ..._exercises.asMap().entries.map((entry) {
              final exIndex = entry.key;
              final ex = entry.value;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(ex.exercise.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => setState(() => _exercises.removeAt(exIndex)),
                          )
                        ],
                      ),
                      const Text('Sets:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...ex.sets.asMap().entries.map((sEntry) {
                        final sIndex = sEntry.key;
                        final s = sEntry.value;
                        final repsController = TextEditingController(text: s.reps == 0 ? '' : s.reps.toString());
                        final weightController = TextEditingController(text: s.weight == 0 ? '' : s.weight.toStringAsFixed(0));

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Text('Set ${sIndex + 1}'),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 70,
                                child: TextFormField(
                                  controller: repsController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'Reps'),
                                  onChanged: (val) => setState(() => ex.sets[sIndex] = s.copyWith(
                                    reps: int.tryParse(val) ?? 0,
                                  )),
                                  validator: (val) {
                                    if (val == null || val.isEmpty || int.tryParse(val) == null) {
                                      return 'Numere doar';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 80,
                                child: TextFormField(
                                  controller: weightController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'Weight'),
                                  onChanged: (val) => setState(() => ex.sets[sIndex] = s.copyWith(
                                    weight: double.tryParse(val) ?? 0,
                                  )),
                                  validator: (val) {
                                    if (val == null || val.isEmpty || double.tryParse(val) == null) {
                                      return 'Numere doar';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => setState(() => ex.sets.removeAt(sIndex)),
                              )
                            ],
                          ),
                        );
                      }).toList(),
                      TextButton.icon(
                        onPressed: () => setState(() => ex.sets.add(
                          WorkoutSet(
                            id: const Uuid().v4(),
                            reps: 0,
                            weight: 0,
                            timestamp: DateTime.now(),
                          ),
                        )),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Set'),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
