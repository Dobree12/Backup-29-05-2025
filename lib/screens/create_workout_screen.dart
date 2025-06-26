import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/workout_model.dart';
import '../models/exercise_model.dart';
import '../models/workout_set.dart';
import '../providers/workout_provider.dart';

class CreateWorkoutScreen extends StatefulWidget {
  final String? predefinedUserId;

  const CreateWorkoutScreen({super.key, this.predefinedUserId});

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final List<WorkoutExercise> _selectedExercises = [];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Workout'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Workout Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a workout name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text('Exercises', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ..._selectedExercises
                .asMap()
                .entries
                .map((entry) => _buildExerciseCard(context, isDark, entry.value, entry.key))
                .toList(),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _addExercise,
              icon: const Icon(Icons.add),
              label: const Text('Add Exercise'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Workout'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, bool isDark, WorkoutExercise we, int index) {
    final exercise = we.exercise;

    return Card(
      color: isDark ? Colors.grey[900] : Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    exercise.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => setState(() => _selectedExercises.removeAt(index)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Sets:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...we.sets.asMap().entries.map((entry) {
              final i = entry.key;
              final s = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text('Set ${i + 1}')),
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        initialValue: s.reps > 0 ? s.reps.toString() : '',
                        decoration: const InputDecoration(labelText: 'Reps'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => setState(() => we.sets[i] = s.copyWith(reps: int.tryParse(value) ?? 0)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        initialValue: s.weight > 0 ? s.weight.toString() : '',
                        decoration: const InputDecoration(labelText: 'Weight'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => setState(() => we.sets[i] = s.copyWith(weight: double.tryParse(value) ?? 0)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => we.sets.removeAt(i)),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => setState(() => we.sets.add(
                WorkoutSet(id: const Uuid().v4(), reps: 0, weight: 0, timestamp: DateTime.now()),
              )),
              icon: const Icon(Icons.add),
              label: const Text('Add Set'),
            )
          ],
        ),
      ),
    );
  }

  void _addExercise() async {
    final provider = Provider.of<WorkoutProvider>(context, listen: false);
    final exercises = provider.exercises;

    final selected = await showDialog<Exercise>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select Exercise'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: exercises.length,
            itemBuilder: (_, i) => ListTile(
              leading: exercises[i].gifUrl != null && exercises[i].gifUrl!.isNotEmpty
                  ? Image.network(exercises[i].gifUrl!, width: 48, height: 48, fit: BoxFit.cover)
                  : const Icon(Icons.fitness_center),
              title: Text(exercises[i].name),
              subtitle: Text(exercises[i].muscleGroup),
              onTap: () => Navigator.of(context).pop(exercises[i]),
            ),
          ),
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedExercises.add(
          WorkoutExercise(
            exercise: selected,
            sets: [
              WorkoutSet(id: const Uuid().v4(), reps: 0, weight: 0, timestamp: DateTime.now()),
            ],
          ),
        );
      });
    }
  }

  void _saveWorkout() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one exercise')),
      );
      return;
    }

   try {
  final workout = Workout(
    id: const Uuid().v4(),
    name: _nameController.text.trim(),
    exercises: _selectedExercises,
    date: DateTime.now(),
    userId: widget.predefinedUserId ?? 'fallback_user_id', // temporar pt test
  );

  final provider = Provider.of<WorkoutProvider>(context, listen: false);
  await provider.addWorkout(workout, userId: workout.userId);
  Navigator.pop(context);
} catch (e) {
  print('Eroare la salvare: $e');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Eroare la salvare: $e')),
  );
}
}}