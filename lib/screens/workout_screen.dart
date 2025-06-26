import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackit/screens/edit_workout_screen.dart';
import '../providers/workout_provider.dart';
import 'create_workout_screen.dart';
import 'workout_detail_screen.dart';

class WorkoutScreen extends StatefulWidget {
  final String? clientId;

  const WorkoutScreen({Key? key, this.clientId}) : super(key: key);

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  String searchQuery = '';
  bool sortDescending = true;
  DateTime? startDate;
  DateTime? endDate;

   @override
void didUpdateWidget(covariant WorkoutScreen oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (oldWidget.clientId != widget.clientId) {
    final provider = Provider.of<WorkoutProvider>(context, listen: false);
    provider.loadWorkouts(
      userId: widget.clientId ?? FirebaseAuth.instance.currentUser!.uid,
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        List workouts = provider.workouts;

        List filtered = workouts.where((w) {
          final matchName = searchQuery.isEmpty || w.name.toLowerCase().contains(searchQuery.toLowerCase());
          final matchRange = (startDate == null || w.date.isAfter(startDate!.subtract(const Duration(days: 1)))) &&
              (endDate == null || w.date.isBefore(endDate!.add(const Duration(days: 1))));
          return matchName && matchRange;
        }).toList();

        filtered.sort((a, b) => sortDescending ? b.date.compareTo(a.date) : a.date.compareTo(b.date));

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Antrenamente'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(112),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cauta antrenament dupa nume...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() => searchQuery = value);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.filter_alt),
                          onPressed: () async {
                            final pickedStart = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              helpText: 'Selecteaza data de inceput',
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Colors.cyan,
                                      onPrimary: Colors.black,
                                      onSurface: Colors.black,
                                    ),
                                    dialogBackgroundColor: Colors.white,
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (pickedStart != null) {
                              final pickedEnd = await showDatePicker(
                                context: context,
                                initialDate: pickedStart,
                                firstDate: pickedStart,
                                lastDate: DateTime(2100),
                                helpText: 'Selecteaza data de sfarsit',
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Colors.cyan,
                                        onPrimary: Colors.black,
                                        onSurface: Colors.black,
                                      ),
                                      dialogBackgroundColor: Colors.white,
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              setState(() {
                                startDate = pickedStart;
                                endDate = pickedEnd ?? pickedStart;
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(sortDescending ? Icons.arrow_downward : Icons.arrow_upward),
                          onPressed: () {
                            setState(() => sortDescending = !sortDescending);
                          },
                        ),
                        if (startDate != null || endDate != null)
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(() {
                              startDate = null;
                              endDate = null;
                            }),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Nu exista antrenamente'),
                      const SizedBox(height: 16),
                      if (widget.clientId == null)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CreateWorkoutScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyanAccent, 
                            foregroundColor: Colors.black, 
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Adauga antrenament'),
                        )
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final workout = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkoutDetailScreen(workout: workout),
                            ),
                          );
                        },
                        child: Card(
                          color: Theme.of(context).cardColor,
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      workout.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.fitness_center, size: 16),
                                            const SizedBox(width: 4),
                                            Text('${workout.exercises.length} exercises'),
                                          ],
                                        ),
                                        Text(
                                          _formatDate(workout.date),
                                          style: TextStyle(color: Colors.grey[500]),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditWorkoutScreen(workout: workout),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                                      onPressed: () => _confirmDelete(context, workout.id),
                                    ),
                                  ],
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: widget.clientId == null
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateWorkoutScreen(),
                      ),
                    );
                  },
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _confirmDelete(BuildContext context, String workoutId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sterge workout'),
        content: const Text('Esti sigur ca vrei sa stergi acest workout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Nu'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<WorkoutProvider>(context, listen: false).deleteWorkout(workoutId);
              Navigator.pop(context);
            },
            child: const Text('Da'),
          ),
        ],
      ),
    );
  }
}
