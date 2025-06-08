// Populate database with exercises
// Create a method to load this initial data

//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackit/services/database_service.dart';
import 'package:uuid/uuid.dart';
import '../models/exercise_model.dart';

class ExerciseData {
  static List<Exercise> getInitialExercises() {
    final uuid = Uuid();
    
    return [
      // Chest Exercises
      Exercise(
        id: uuid.v4(),
        name: 'Bench Press',
        description: 'A compound exercise that targets the chest, shoulders, and triceps.',
        muscleGroup: 'Chest',
        gifUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Barbell-Bench-Press.gif',
        instructions: [
          'Lie on a flat bench with your feet flat on the floor.',
          'Grip the barbell with hands slightly wider than shoulder-width apart.',
          'Lower the bar to your mid-chest.',
          'Press the bar back up to full arm extension.',
          'Breathe out as you push the bar up.',
        ], equipment: 'Barbell',
        
      ),
      Exercise(
        id: uuid.v4(),
        name: 'Incline Dumbbell Press',
        description: 'Targets the upper chest muscles and shoulders.',
        muscleGroup: 'Chest',
        gifUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Incline-Dumbbell-Press.gif',
        instructions: [
          'Set an adjustable bench to a 30-45 degree incline.',
          'Sit on the bench with a dumbbell in each hand resting on your thighs.',
          'Lift the dumbbells to shoulder level with palms facing forward.',
          'Press the dumbbells up until your arms are fully extended.',
          'Lower the weights back to shoulder level and repeat.',
        ], equipment: 'Dumbbells',
      ),
      Exercise(
        id: uuid.v4(),
        name: 'Cable Fly',
        description: 'Isolation exercise that targets the chest muscles.',
        muscleGroup: 'Chest',
        gifUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Cable-Crossover.gif',
        instructions: [
          'Stand between two cable machines with handles attached.',
          'Grab the handles with arms extended out to the sides.',
          'Keep a slight bend in your elbows throughout the movement.',
          'Bring your hands together in front of you in a hugging motion.',
          'Slowly return to the starting position with controlled movement.',
        ], equipment: 'Cable Machine',
      ),
      
      // Back Exercises
      Exercise(
        id: uuid.v4(),
        name: 'Pull-Up',
        description: 'A compound upper body exercise that targets the lats, biceps, and middle back.',
        muscleGroup: 'Back',
        gifUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Pull-up.gif',
        instructions: [
          'Hang from a pull-up bar with hands shoulder-width apart, palms facing away.',
          'Pull your body up until your chin is above the bar.',
          'Lower your body back to the starting position with control.',
          'Keep your core engaged throughout the movement.',
          'For beginners, use an assisted pull-up machine if available.',
        ], equipment: 'Pull-Up Bar',
      ),
      Exercise(
        id: uuid.v4(),
        name: 'Barbell Row',
        description: 'A compound exercise that targets the middle back, lats, and rhomboids.',
        muscleGroup: 'Back',
        gifUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Barbell-Bent-Over-Row.gif',
        instructions: [
          'Stand with feet shoulder-width apart, holding a barbell with hands slightly wider than shoulder width.',
          'Bend at the hips and knees, keeping your back straight until your torso is almost parallel to the floor.',
          'Pull the barbell up to your lower chest/upper abdomen.',
          'Squeeze your shoulder blades together at the top of the movement.',
          'Lower the barbell with control and repeat.',
        ], equipment: 'Barbell',
      ),
      Exercise(
        id: uuid.v4(),
        name: 'Lat Pulldown',
        description: 'Machine exercise that targets the latissimus dorsi and biceps.',
        muscleGroup: 'Back',
        gifUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Lat-Pulldown.gif',
        instructions: [
          'Sit at a lat pulldown machine with a wide grip on the bar.',
          'Keep your back straight and chest up.',
          'Pull the bar down to your upper chest while squeezing your shoulder blades together.',
          'Slowly return the bar to the starting position with controlled movement.',
          'Avoid leaning too far back during the exercise.',
        ], equipment: 'Lat Pulldown Machine',
      ),
      
      // Leg Exercises
      Exercise(
        id: uuid.v4(),
        name: 'Squat',
        description: 'A compound lower body exercise that targets the quadriceps, hamstrings, and glutes.',
        muscleGroup: 'Legs',
        gifUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/BARBELL-SQUAT.gif',
        instructions: [
          'Stand with feet shoulder-width apart, toes slightly turned out.',
          'Hold a barbell across your upper back on the trapezius muscles.',
          'Bend at the knees and hips to lower your body until thighs are parallel to the floor.',
          'Keep your chest up and back straight throughout the movement.',
          'Push through your heels to return to the starting position.',
        ], equipment: 'Barbell',
      ),
      Exercise(
        id: uuid.v4(),
        name: 'Leg Press',
        description: 'Machine exercise that targets the quadriceps, hamstrings, and glutes.',
        muscleGroup: 'Legs',
        gifUrl: 'https://fitnessprogramer.com/wp-content/uploads/2015/11/Leg-Press.gif',
        instructions: [
          'Sit on the leg press machine with your back against the padded support.',
          'Place your feet shoulder-width apart on the platform.',
          'Release the safety bars and lower the platform by bending your knees.',
          'Lower until your knees form a 90-degree angle.',
          'Push through your heels to extend your legs without locking your knees.',
        ], equipment: 'Leg Press Machine',
      ),
      Exercise(
        id: uuid.v4(),
        name: 'Romanian Deadlift',
        description: 'A hip-hinge movement that targets the hamstrings, glutes, and lower back.',
        muscleGroup: 'Legs',
        gifUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Barbell-Romanian-Deadlift.gif',
        instructions: [
          'Stand with feet hip-width apart, holding a barbell in front of your thighs.',
          'Keep your back straight and shoulders back.',
          'Hinge at the hips and lower the barbell while keeping it close to your legs.',
          'Lower until you feel a stretch in your hamstrings, typically just below the knees.',
          'Drive your hips forward to return to the starting position.',
        ], equipment: 'Barbell',
      ),
      
      // Shoulder Exercises
      Exercise(
        id: uuid.v4(),
        name: 'Overhead Press',
        description: 'A compound exercise that targets the deltoids, trapezius, and triceps.',
        muscleGroup: 'Shoulders',
        gifUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/07/Barbell-Standing-Military-Press.gif',
        instructions: [
          'Stand with feet shoulder-width apart holding a barbell at shoulder height.',
          'Keep your core tight and back straight.',
          'Press the bar overhead until your arms are fully extended.',
          'Lower the bar back to shoulder level with control.',
          'Avoid arching your lower back during the movement.',
        ], equipment: 'Barbell',
        
      ),
      Exercise(
        id: uuid.v4(),
        name: 'Lateral Raise',
        description: 'Isolation exercise that targets the lateral deltoids.',
        muscleGroup: 'Shoulders',
        gifUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Lateral-Raise.gif',
        instructions: [
          'Stand with feet shoulder-width apart holding a dumbbell in each hand at your sides.',
          'Keep a slight bend in your elbows throughout the movement.',
          'Raise the dumbbells out to the sides until they reach shoulder level.',
          'Pause briefly at the top of the movement.',
          'Lower the dumbbells with control and repeat.',
        ], equipment: '',
      ),
      Exercise(
        id: uuid.v4(),
        name: 'Face Pull',
        description: 'Cable exercise that targets the rear deltoids and upper back muscles.',
        muscleGroup: 'Shoulders',
        gifUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Face-Pull.gif',
        instructions: [
          'Set a cable pulley to slightly above head height with a rope attachment.',
          'Grip the rope with both hands and step back to create tension.',
          'Pull the rope toward your face, separating your hands at the end of the movement.',
          'Focus on squeezing your shoulder blades together.',
          'Return to the starting position with control and repeat.',
        ], equipment: 'Cable Machine',
      ),
      
      // Arm Exercises
      Exercise(
        id: uuid.v4(),
        name: 'Bicep Curl',
        description: 'Isolation exercise that targets the biceps.',
        muscleGroup: 'Arms',
        gifUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Curl.gif',
        instructions: [
          'Stand with feet shoulder-width apart holding a dumbbell in each hand.',
          'Keep your elbows close to your torso and palms facing forward.',
          'Curl the weights up to shoulder level while keeping upper arms stationary.',
          'Squeeze your biceps at the top of the movement.',
          'Lower the weights back to the starting position with control.',
        ], equipment: 'Dumbbells',
      ),
      Exercise(
        id: uuid.v4(),
        name: 'Tricep Pushdown',
        description: 'Cable exercise that targets the triceps.',
        muscleGroup: 'Arms',
        gifUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Pushdown.gif',
        instructions: [
          'Stand facing a cable machine with a straight bar attachment at upper chest height.',
          'Grip the bar with hands shoulder-width apart, palms facing down.',
          'Keep your elbows close to your sides and push the bar down until arms are fully extended.',
          'Squeeze your triceps at the bottom of the movement.',
          'Slowly return to the starting position and repeat.',
        ], equipment: 'Cable Machine',
      ),
      Exercise(
        id: uuid.v4(),
        name: 'Hammer Curl',
        description: 'Variation of the bicep curl that also targets the brachialis and forearms.',
        muscleGroup: 'Arms',
        gifUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Hammer-Curl.gif',
        instructions: [
          'Stand with feet shoulder-width apart holding a dumbbell in each hand.',
          'Keep your elbows close to your torso with palms facing your body (neutral grip).',
          'Curl the weights up while keeping your wrists straight and thumbs pointing up.',
          'Pause briefly at the top of the movement.',
          'Lower the weights with control and repeat.',
        ], equipment: 'Dumbbells',
      ),
      
      // Core Exercises
      Exercise(
        id: uuid.v4(),
        name: 'Plank',
        description: 'An isometric core strength exercise that involves maintaining a position similar to a push-up for the maximum possible time.',
        muscleGroup: 'Core',
        gifUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/plank.gif',
        instructions: [
          'Start in a push-up position with your forearms on the ground.',
          'Keep your elbows directly beneath your shoulders.',
          'Maintain a straight line from head to heels.',
          'Engage your core and hold the position.',
          'Breathe normally and aim to increase holding time with practice.',
        ], equipment: 'no equipment needed',
      ),
      Exercise(
        id: uuid.v4(),
        name: 'Russian Twist',
        description: 'A rotational exercise that targets the obliques and abdominal muscles.',
        muscleGroup: 'Core',
        gifUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Russian-Twist.gif',
        instructions: [
          'Sit on the floor with knees bent and feet either flat or elevated.',
          'Lean back slightly to engage your core, maintaining a straight back.',
          'Hold your hands together or hold a weight in front of your chest.',
          'Rotate your torso to the right, then to the left, touching the floor on each side if possible.',
          'Keep your movements controlled and breathe steadily throughout.',
        ], equipment: 'Dumbbell or Medicine Ball',
      ),
      Exercise(
        id: uuid.v4(),
        name: 'Hanging Leg Raise',
        description: 'Advanced core exercise that targets the lower abdominals and hip flexors.',
        muscleGroup: 'Core',
        gifUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/08/Hanging-Leg-Raises.gif',
        instructions: [
          'Hang from a pull-up bar with hands shoulder-width apart.',
          'Keep your shoulders engaged to protect your joints.',
          'Raise your legs together until they are parallel to the floor (or higher if possible).',
          'Lower your legs with control, avoiding swinging.',
          'For beginners, try bent knee raises first.',
        ], equipment: 'Pull-Up Bar',
      ),
    ];
  }
  /// Method to add these exercises to Firestore using DatabaseService
  static Future<void> populateExerciseDatabase(DatabaseService dbService) async {
    final exercises = getInitialExercises();

    for (final exercise in exercises) {
      await dbService.saveExercise(exercise);
    }
  }
  
}