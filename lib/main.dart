import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trackit/screens/login_screen.dart';
import 'package:trackit/screens/trainer_home_screen.dart';
import 'package:trackit/services/database_service.dart';
import 'package:trackit/screens/verify_email_screen.dart';
import 'screens/home_screen.dart';
//import 'package:trackit/register_screen.dart';
import 'providers/workout_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Iniializare Firebase


 //daca vrem sa facem reload la exercitiile din baza de date 
 //await DatabaseService().reloadAllExercises(); 

 await DatabaseService().deleteWorkoutsWithoutUserId();

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
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrackIT',
      debugShowCheckedModeBanner: false,
     theme: ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(seedColor:  Colors.blue,),
  useMaterial3: true, // recomandat pentru stil modern
),

      darkTheme: ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(seedColor:  Colors.blue, brightness: Brightness.dark),
  useMaterial3: true,
),

      themeMode: ThemeMode.system,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          if (snapshot.hasData) {
            final user = FirebaseAuth.instance.currentUser!;
            if (user.emailVerified) {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));

                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final role = data['role'] ?? 'user';

                  if (role == 'trainer') {
                    return TrainerHomeScreen();
                  } else {
                    return const HomeScreen();
                  }
                },
              );
            } else {
              return const VerifyEmailScreen();
            }
          }
          return const LoginScreen(); // Nu e logat
        },
      ),
    );
  }
}
