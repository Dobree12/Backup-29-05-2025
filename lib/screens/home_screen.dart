import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:trackit/data/exercise_data.dart';
import 'package:trackit/services/database_service.dart';
import '../providers/workout_provider.dart';
import 'workout_screen.dart';
import 'exercise_library_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const WorkoutScreen(),
    const ExerciseLibraryScreen(),
    const StatsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final dbService = DatabaseService();

      // Populează exercițiile dacă Firestore e gol
      await dbService.checkAndPopulateExercises();

      final provider = Provider.of<WorkoutProvider>(context, listen: false);
      await provider.loadWorkouts();
      await provider.loadExercises();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GymTrack Pro'),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workouts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Exercises',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}
