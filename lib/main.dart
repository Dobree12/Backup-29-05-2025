

// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
//import 'models/workout_model.dart';
import 'providers/workout_provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inițializare Firebase
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymTrack Pro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// lib/models/exercise_model.dart


// lib/models/workout_set.dart

// lib/models/workout_model.dart


// lib/providers/workout_provider.dart


// lib/screens/home_screen.dart


// lib/screens/exercise_library_screen.dart


// lib/screens/exercise_detail_screen.dart

// lib/screens/workout_screen.dart

// lib/services/database_service.dart

// lib/screens/create_workout_screen.dart


// lib/screens/workout_detail_screen.dart


// lib/screens/stats_screen.dart
