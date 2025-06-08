class WorkoutSet {
  final String id;
  final int reps;
  final double weight;
  final DateTime timestamp;
  
  WorkoutSet({
    required this.id,
    required this.reps,
    required this.weight,
    required this.timestamp,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reps': reps,
      'weight': weight,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // aici adaugi:
  WorkoutSet copyWith({
    String? id,
    int? reps,
    double? weight,
    DateTime? timestamp,
  }) {
    return WorkoutSet(
      id: id ?? this.id,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      timestamp: timestamp ?? this.timestamp,
    );
  }
  
  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      id: json['id'],
      reps: json['reps'],
      weight: json['weight'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}