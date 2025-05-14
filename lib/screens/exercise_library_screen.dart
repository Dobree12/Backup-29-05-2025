import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
//import '../models/exercise_model.dart';
import 'exercise_detail_screen.dart';

class ExerciseLibraryScreen extends StatelessWidget {
  const ExerciseLibraryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        final exercises = provider.exercises;
        
        return ListView.builder(
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            return ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(exercise.gifUrl),
                  ),
                ),
              ),
              title: Text(exercise.name),
              subtitle: Text(exercise.muscleGroup),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExerciseDetailScreen(exercise: exercise),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}