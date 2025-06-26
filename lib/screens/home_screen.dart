import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackit/screens/create_workout_screen.dart';
import 'package:trackit/screens/resurse_screen.dart';
import 'package:trackit/services/database_service.dart';
import '../providers/workout_provider.dart';
import 'workout_screen.dart';
import 'exercise_library_screen.dart';
import 'stats_screen.dart';
import 'account_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? clientId;
  final String? clientName;

  const HomeScreen({Key? key, this.clientId, this.clientName}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isDarkMode = true;

  late final List<Widget> _screens;

  @override
 void initState() {
  super.initState();
  Future.microtask(() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await Provider.of<WorkoutProvider>(context, listen: false)
          .loadWorkouts(userId: user.uid);
    }
  });


    _screens = [
      WorkoutScreen(clientId: widget.clientId),
      const ExerciseLibraryScreen(),
      const StatsScreen(),
       ResurseScreen(),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final dbService = DatabaseService();
      await dbService.checkAndPopulateExercises();

      final provider = Provider.of<WorkoutProvider>(context, listen: false);

      try {
        await provider.loadWorkouts(
  userId: widget.clientId ?? FirebaseAuth.instance.currentUser!.uid,
);
      } catch (e) {
        print('Eroare la loadWorkouts: $e');
      }

      try {
        await provider.loadExercises();
      } catch (e) {
        print('Eroare la loadExercises: $e');
      }
    });
  }

  ThemeData get _currentTheme => _isDarkMode
      ? ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF121212),
          appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF121212)),
          cardColor: const Color(0xFF1E1E1E),
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        )
      : ThemeData.light().copyWith(
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
          cardColor: Colors.grey[100],
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        );

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _currentTheme,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            widget.clientName != null ? 'Client: ${widget.clientName}' : 'TrackIT',
            style: TextStyle(
              color: _isDarkMode ? Colors.white.withOpacity(0.87) : Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.person, color: _isDarkMode ? Colors.white : Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccountScreen(
                      isDarkMode: _isDarkMode,
                      onToggleTheme: () {
                        setState(() {
                          _isDarkMode = !_isDarkMode;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
          
            Expanded(child: _screens[_selectedIndex]),
          ],
        ),
        floatingActionButton: _selectedIndex == 0
            ? FloatingActionButton(
                backgroundColor: const Color(0xFF00FFFF),
                child: const Icon(Icons.add, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateWorkoutScreen(
                        predefinedUserId: widget.clientId,
                      ),
                    ),
                  );
                },
              )
            : null,
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          selectedItemColor: const Color(0xFF00FFFF),
          unselectedItemColor: Colors.grey,
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
              icon: Icon(Icons.directions_run),
              label: 'Exercises',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: 'Resurse',
            ),
          ],
        ),
      ),
    );
  }
}

extension DateOnlyCompare on DateTime {
  String toShortString() {
    return "${this.day}/${this.month}/${this.year}";
  }
}
