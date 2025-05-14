import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/workout_provider.dart';
import '../models/workout_model.dart';
import '../models/exercise_model.dart';
import '../models/workout_set.dart';

class CreateWorkoutScreen extends StatefulWidget {
  const CreateWorkoutScreen({Key? key}) : super(key: key);

  @override
  _CreateWorkoutScreenState createState() => _CreateWorkoutScreenState();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Workout'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Workout Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a workout name';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            Text(
              'Exercises',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            
            ..._buildExercisesList(),
            
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addExercise,
              icon: const Icon(Icons.add),
              label: const Text('Add Exercise'),
            ),
            
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveWorkout,
              child: const Text('Save Workout'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  List<Widget> _buildExercisesList() {
    return _selectedExercises.map((workoutExercise) {
      final exercise = workoutExercise.exercise;
      final exerciseIndex = _selectedExercises.indexOf(workoutExercise);
      
      return Card(
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      exercise.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _selectedExercises.removeAt(exerciseIndex);
                      });
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              const Text(
                'Sets:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              
              ...workoutExercise.sets.asMap().entries.map((entry) {
                final setIndex = entry.key;
                final set = entry.value;
                
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('Set ${setIndex + 1}'),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextFormField(
                          initialValue: set.reps.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Reps',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              final newSet = WorkoutSet(
                                id: set.id,
                                reps: int.tryParse(value) ?? 0,
                                weight: set.weight,
                                timestamp: set.timestamp,
                              );
                              workoutExercise.sets[setIndex] = newSet;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 80,
                        child: TextFormField(
                          initialValue: set.weight.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Weight',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              final newSet = WorkoutSet(
                                id: set.id,
                                reps: set.reps,
                                weight: double.tryParse(value) ?? 0,
                                timestamp: set.timestamp,
                              );
                              workoutExercise.sets[setIndex] = newSet;
                            });
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            workoutExercise.sets.removeAt(setIndex);
                          });
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
              
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    workoutExercise.sets.add(
                      WorkoutSet(
                        id: const Uuid().v4(),
                        reps: 0,
                        weight: 0,
                        timestamp: DateTime.now(),
                      ),
                    );
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Set'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
  
  void _addExercise() async {
    final provider = Provider.of<WorkoutProvider>(context, listen: false);
    final exercises = provider.exercises;
    
    final selectedExercise = await showDialog<Exercise>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Exercise'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return ListTile(
                  title: Text(exercise.name),
                  subtitle: Text(exercise.muscleGroup),
                  onTap: () {
                    Navigator.of(context).pop(exercise);
                  },
                );
              },
            ),
          ),
        );
      },
    );
    
    if (selectedExercise != null) {
      setState(() {
        _selectedExercises.add(
          WorkoutExercise(
            exercise: selectedExercise,
            sets: [
              WorkoutSet(
                id: const Uuid().v4(),
                reps: 0,
                weight: 0,
                timestamp: DateTime.now(),
              ),
            ],
          ),
        );
      });
    }
  }
  
  void _saveWorkout() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedExercises.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one exercise'),
          ),
        );
        return;
      }
      
      final workout = Workout(
        id: const Uuid().v4(),
        name: _nameController.text,
        exercises: _selectedExercises,
        date: DateTime.now(),
      );
      
      final provider = Provider.of<WorkoutProvider>(context, listen: false);
      await provider.addWorkout(workout);
      
      Navigator.pop(context);
    }
  }
}