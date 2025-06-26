import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/exercise_model.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({
    Key? key,
    required this.exercise,
  }) : super(key: key);

  Future<void> _addExerciseToWorkout(String workoutId, Exercise exercise) async {
    final workoutRef = FirebaseFirestore.instance.collection('workouts').doc(workoutId);

    await workoutRef.update({
      'exercises': FieldValue.arrayUnion([
        {
          'id': exercise.id,
          'name': exercise.name,
          'gifUrl': exercise.gifUrl,
          'muscleGroup': exercise.muscleGroup,
          'equipment': exercise.equipment,
        }
      ])
    });
  }

  Future<void> _showWorkoutPicker(BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nu esti autentificat.')),
      );
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('workouts')
        .where('userId', isEqualTo: userId)
        .get();

    final workouts = snapshot.docs;

    if (workouts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nu ai niciun workout salvat.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          itemCount: workouts.length,
          itemBuilder: (context, index) {
            final workout = workouts[index];
            final name = workout['name'];
            final id = workout.id;

            return ListTile(
              leading: const Icon(Icons.fitness_center),
              title: Text(name),
              onTap: () async {
                Navigator.pop(context);
                await _addExerciseToWorkout(id, exercise);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Exercitiul a fost adaugat in "$name"')),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(exercise.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: exercise.gifUrl,
                width: double.infinity,
                height: 500,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              exercise.name,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              exercise.muscleGroup,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(exercise.equipment),
              backgroundColor: colorScheme.surfaceVariant,
              labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),

            Card(
              color: colorScheme.surface,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: theme.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Description',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      exercise.description,
                      style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Instructions',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...exercise.instructions.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final instruction = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline, size: 20, color: theme.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$index. $instruction',
                        style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onBackground),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => _showWorkoutPicker(context),
            icon: const Icon(Icons.add),
            label: const Text('Adauga la workout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }
}
