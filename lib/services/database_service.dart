import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackit/data/exercise_data.dart';
import 'package:trackit/models/exercise_model.dart';        // pentru Exercise + fromFirestore()
import 'package:trackit/models/workout_model.dart';         // pentru Workout și WorkoutExercise
import 'package:trackit/models/workout_set.dart';           // pentru WorkoutSet
//import 'package:uuid/uuid.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ------------------------------
  // EXERCISES
  // ------------------------------

  Future<void> saveExercise(Exercise exercise) async {
    await _firestore
        .collection('exercises')
        .doc(exercise.id)
        .set(exercise.toMap());
  }

  Future<List<Exercise>> getExercises() async {
    final snapshot = await _firestore.collection('exercises').get();
    return snapshot.docs.map((doc) => Exercise.fromFirestore(doc)).toList();
  }

  // ------------------------------
  // WORKOUTS
  // ------------------------------

  Future<void> saveWorkout(Workout workout) async {
    final workoutDoc = _firestore.collection('workouts').doc(workout.id);

    // Salvează metadatele antrenamentului
    await workoutDoc.set({
      'id': workout.id,
      'name': workout.name,
      'date': workout.date.toIso8601String(),
    });

    // Salvează fiecare exercițiu ca subdocument + seturile
    for (final we in workout.exercises) {
      final weDoc = workoutDoc.collection('exercises').doc(we.id);

      await weDoc.set({
        'exercise': we.exercise.toMap(),
      });

      for (final set in we.sets) {
        await weDoc.collection('sets').doc(set.id).set(set.toJson());
      }
    }
  }

  Future<List<Workout>> getWorkouts() async {
    final snapshot = await _firestore.collection('workouts').get();

    List<Workout> workouts = [];

    for (final doc in snapshot.docs) {
      final workoutId = doc.id;
      final workoutData = doc.data();
      final date = DateTime.parse(workoutData['date']);

      final exerciseSnapshots = await _firestore
          .collection('workouts')
          .doc(workoutId)
          .collection('exercises')
          .get();

      List<WorkoutExercise> workoutExercises = [];

      for (final weDoc in exerciseSnapshots.docs) {
        final weData = weDoc.data();
        final exerciseMap = Map<String, dynamic>.from(weData['exercise']);
        final exercise = Exercise.fromMap(exerciseMap);

        final setsSnapshot = await _firestore
            .collection('workouts')
            .doc(workoutId)
            .collection('exercises')
            .doc(weDoc.id)
            .collection('sets')
            .get();

        final sets = setsSnapshot.docs
            .map((s) => WorkoutSet.fromJson(s.data()))
            .toList();

        workoutExercises.add(WorkoutExercise(
          id: weDoc.id,
          exercise: exercise,
          sets: sets,
        ));
      }

      workouts.add(Workout(
        id: workoutId,
        name: workoutData['name'],
        date: date,
        exercises: workoutExercises,
      ));
    }

    return workouts;
  }

  Future<void> deleteWorkout(Workout workout) async {
    final workoutDoc = _firestore.collection('workouts').doc(workout.id);

    final exerciseSnapshots = await workoutDoc.collection('exercises').get();

    for (final weDoc in exerciseSnapshots.docs) {
      final sets = await weDoc.reference.collection('sets').get();
      for (final set in sets.docs) {
        await set.reference.delete();
      }
      await weDoc.reference.delete();
    }

    await workoutDoc.delete();
  }

  Future<void> updateWorkout(Workout workout) async {
    await deleteWorkout(workout);
    await saveWorkout(workout);
  }

  // Verificare + populare inițială
  Future<void> checkAndPopulateExercises() async {
    final snapshot = await _firestore.collection('exercises').get();
    if (snapshot.docs.isEmpty) {
      // Apelează populateExerciseDatabase din ExerciseData
      // Exemplu:
       await ExerciseData.populateExerciseDatabase(this);
    }
  }
}
