import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

Future<void> loadWorkouts({required String userId}) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('workouts')
      .where('userId', isEqualTo: userId)
      .orderBy('date', descending: true)
      .get();
      print("Loading workouts for userId: $userId");


  _workouts.clear();

  _workouts = snapshot.docs.map((doc) {
    final map = doc.data();
    map['id'] = doc.id;
    return Workout.fromMap(map);
  }).toList();
print("Found ${snapshot.docs.length} workouts in Firestore");

  notifyListeners();
}


  Future<void> loadExercises() async {
    _exercises = await _dbService.getExercises();
    print("Exercitii afisate: ${_exercises.length}");
    notifyListeners();
  }

 Future<void> addWorkout(Workout workout, {String? userId}) async {
  final id = await _dbService.saveWorkout(workout, userId: userId);
  final workoutWithId = Workout(
    id: id,
    name: workout.name,
    exercises: workout.exercises,
    date: workout.date,
    userId: userId ?? FirebaseAuth.instance.currentUser!.uid,
  );

  _workouts.add(workoutWithId);
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
