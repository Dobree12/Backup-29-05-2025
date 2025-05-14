import 'package:flutter/material.dart';
import '../models/exercise_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;
  
  const ExerciseDetailScreen({
    Key? key,
    required this.exercise,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise GIF/animation
            Container(
              height: 250,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: exercise.gifUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(exercise.description),
                  
                  const SizedBox(height: 16),
                  Text(
                    'Instructions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ...exercise.instructions.map((instruction) {
                    final index = exercise.instructions.indexOf(instruction);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${index + 1}. '),
                          Expanded(child: Text(instruction)),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
