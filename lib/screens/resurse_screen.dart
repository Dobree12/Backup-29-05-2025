import 'package:flutter/material.dart';

class ResurseScreen extends StatelessWidget {
  final List<_ResursaCategorie> categorii = [
    _ResursaCategorie(
      titlu: 'Nutritie',
      icon: Icons.local_dining,
      culoare: Colors.orangeAccent,
      continut: [
        'Proteina este esentiala pentru refacerea si cresterea masei musculare.',
        'Carbohidratii furnizeaza energie pentru antrenamente si functiile zilnice.',
        'Macronutrientii principali sunt: proteine, carbohidrati si grasimi.',
        'Zaharul in exces poate afecta sanatatea metabolica si greutatea corporala.',
        'Grasimile sanatoase (avocado, nuci, ulei de masline) sunt vitale pentru hormoni si energie.',
      ],
    ),
    _ResursaCategorie(
      titlu: 'Antrenament',
      icon: Icons.fitness_center,
      culoare: Colors.blueAccent,
      continut: [],
    ),
    _ResursaCategorie(
      titlu: 'Tips & Tricks',
      icon: Icons.lightbulb,
      culoare: Colors.greenAccent,
      continut: [],
    ),
    _ResursaCategorie(
      titlu: 'Recuperare',
      icon: Icons.self_improvement,
      culoare: Colors.purpleAccent,
      continut: [],
    ),
    _ResursaCategorie(
      titlu: 'Suplimente',
      icon: Icons.medical_services,
      culoare: Colors.redAccent,
      continut: [],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resurse'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: categorii.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final categorie = categorii[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategorieResursaScreen(
                      titlu: categorie.titlu,
                      continut: categorie.continut,
                    ),
                  ),
                );
              },
              child: Hero(
                tag: categorie.titlu,
                child: Material(
                  color: categorie.culoare,
                  borderRadius: BorderRadius.circular(24),
                  elevation: 6,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(categorie.icon, size: 48, color: Colors.white),
                        const SizedBox(height: 16),
                        Text(
                          categorie.titlu,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ResursaCategorie {
  final String titlu;
  final IconData icon;
  final Color culoare;
  final List<String> continut;

  _ResursaCategorie({
    required this.titlu,
    required this.icon,
    required this.culoare,
    required this.continut,
  });
}

class CategorieResursaScreen extends StatelessWidget {
  final String titlu;
  final List<String> continut;

  const CategorieResursaScreen({super.key, required this.titlu, required this.continut});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titlu)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: continut.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              title: Text(
                continut[index],
                style: const TextStyle(fontSize: 16),
              ),
            ),
          );
        },
      ),
    );
  }
}