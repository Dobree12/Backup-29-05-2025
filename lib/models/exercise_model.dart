import 'package:cloud_firestore/cloud_firestore.dart';

class Exercise {
  final String id;
  final String name;
  final String description;
  final String muscleGroup;
  final String equipment;
  final List<String> instructions;
  final String gifUrl;
  final String? bodyPart;
  final String? target;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.muscleGroup,
    required this.equipment,
    this.instructions = const [],
    this.gifUrl = '',
    this.bodyPart,
    this.target,
  });

  /// Creează un obiect Exercise dintr-un document Firestore
  factory Exercise.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Exercise(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      muscleGroup: data['muscleGroup'] ?? '',
      equipment: data['equipment'] ?? '',
      instructions: List<String>.from(data['instructions'] ?? []),
      gifUrl: data['gifUrl'] ?? '',
    );
  }

  /// Creează un obiect Exercise dintr-o mapă locală
  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      muscleGroup: map['muscleGroup'] ?? '',
      equipment: map['equipment'] ?? '',
      instructions: List<String>.from(map['instructions'] ?? []),
      gifUrl: map['gifUrl'] ?? '',
    );
  }

  /// Convertește un Exercise într-un map compatibil cu Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'muscleGroup': muscleGroup,
      'equipment': equipment,
      'instructions': instructions,
      'gifUrl': gifUrl,
    };
  }
}
