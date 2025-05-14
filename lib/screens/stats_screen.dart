import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/workout_provider.dart';
import '../models/exercise_model.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Exercise? _selectedExercise;
  final List<Color> _gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        final exercises = provider.exercises;
        final workouts = provider.workouts;
        
        // Filter workouts to get only those with the selected exercise
        final exerciseWorkouts = _selectedExercise != null
            ? workouts
                .where((workout) => workout.exercises.any(
                    (we) => we.exercise.id == _selectedExercise!.id))
                .toList()
            : [];
        
        // Extract exercise data for charts
        final exerciseData = <DateTime, double>{};
        if (_selectedExercise != null) {
          for (final workout in exerciseWorkouts) {
            for (final we in workout.exercises) {
              if (we.exercise.id == _selectedExercise!.id) {
                // Find the highest weight for this exercise in this workout
                double maxWeight = 0;
                for (final set in we.sets) {
                  if (set.weight > maxWeight) {
                    maxWeight = set.weight;
                  }
                }
                exerciseData[workout.date] = maxWeight;
              }
            }
          }
        }
        
        // Convert exercise data to chart points
        final sortedDates = exerciseData.keys.toList()
          ..sort((a, b) => a.compareTo(b));
        
        final spots = sortedDates
            .map((date) => FlSpot(
                date.millisecondsSinceEpoch.toDouble(), exerciseData[date]!))
            .toList();
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise selection dropdown
              DropdownButtonFormField<Exercise>(
                decoration: const InputDecoration(
                  labelText: 'Select Exercise',
                  border: OutlineInputBorder(),
                ),
                value: _selectedExercise,
                items: exercises.map((exercise) {
                  return DropdownMenuItem<Exercise>(
                    value: exercise,
                    child: Text(exercise.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedExercise = value;
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              if (_selectedExercise != null) ...[
                Text(
                  'Progress Chart for ${_selectedExercise!.name}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                
                const SizedBox(height: 16),
                
                if (spots.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No data available for this exercise'),
                    ),
                  )
                else
                  AspectRatio(
                    aspectRatio: 1.70,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    '${date.day}/${date.month}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              },
                              reservedSize: 30,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                  ),
                                );
                              },
                              reservedSize: 40,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: const Color(0xff37434d)),
                        ),
                        minX: spots.isNotEmpty ? spots.first.x : 0,
                        maxX: spots.isNotEmpty ? spots.last.x : 0,
                        minY: 0,
                        maxY: spots.isNotEmpty ? spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.2 : 10,
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            gradient: LinearGradient(
                              colors: _gradientColors,
                            ),
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: _gradientColors
                                    .map((color) => color.withOpacity(0.3))
                                    .toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                const SizedBox(height: 24),
                
                // Exercise stats summary
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Statistics',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: 'Max Weight',
                                value: spots.isNotEmpty
                                    ? '${spots.map((s) => s.y).reduce((a, b) => a > b ? a : b)} kg'
                                    : 'N/A',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _StatCard(
                                title: 'Total Workouts',
                                value: '${exerciseWorkouts.length}',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  
  const _StatCard({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}