import 'package:uuid/uuid.dart';
import 'package:trackit/models/exercise_model.dart';
import 'package:trackit/models/workout_set.dart';

class Workout {
  final String id;
  final String name;
  final List<WorkoutExercise> exercises;
  final DateTime date;
  final String userId;

  Workout({
    required this.id,
    required this.name,
    required this.exercises,
    required this.date,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'userId': userId, // adaugam userId in map
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'],
      name: map['name'],
      date: DateTime.parse(map['date']),
      userId: map['userId'], // citim userId din map
      exercises: [], // se populeaza separat
    );
  }
}


class WorkoutExercise {
  final String id;
  final Exercise exercise;
  List<WorkoutSet> sets;

  WorkoutExercise({
    required this.exercise,
    required this.sets,
    String? id,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exercise': exercise.toMap(),
      'sets': sets.map((set) => set.toJson()).toList(),
    };
  }

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutExercise(
      id: map['id'],
      exercise: Exercise.fromMap(Map<String, dynamic>.from(map['exercise'])),
      sets: (map['sets'] as List<dynamic>)
          .map((s) => WorkoutSet.fromJson(Map<String, dynamic>.from(s)))
          .toList(),
    );
  }
}
