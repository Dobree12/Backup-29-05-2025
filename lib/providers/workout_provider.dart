import 'package:flutter/foundation.dart';
import '../models/workout_model.dart';
import '../models/exercise_model.dart';
import '../services/database_service.dart';

class WorkoutProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<Workout> _workouts = [];
  List<Exercise> _exercises = [];

  List<Workout> get workouts => _workouts;
  List<Exercise> get exercises => _exercises;

  Future<void> loadWorkouts() async {
    _workouts = await _dbService.getWorkouts();
    notifyListeners();
  }

  Future<void> loadExercises() async {
    _exercises = await _dbService.getExercises();
    notifyListeners();
  }

  Future<void> addWorkout(Workout workout) async {
    await _dbService.saveWorkout(workout);
    _workouts.add(workout);
    notifyListeners();
  }

  Future<void> updateWorkout(Workout workout) async {
    await _dbService.updateWorkout(workout);
    final index = _workouts.indexWhere((w) => w.id == workout.id);
    if (index != -1) {
      _workouts[index] = workout;
      notifyListeners();
    }
  }

  Future<void> addExercise(Exercise exercise) async {
    await _dbService.saveExercise(exercise);
    _exercises.add(exercise);
    notifyListeners();
  }

  Future<void> deleteWorkout(String workoutId) async {
    final index = _workouts.indexWhere((w) => w.id == workoutId);
    if (index != -1) {
      final workout = _workouts[index];
      await _dbService.deleteWorkout(workout);
      _workouts.removeAt(index);
      notifyListeners();
    }
  }
}
