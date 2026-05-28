import 'package:flutter/material.dart';
import 'package:getfit/features/meals/data/meals_api_connector.dart';
import '../domain/meal.dart';

class MealDetailsScreen extends StatefulWidget {
  final Meal meal;

  const MealDetailsScreen({super.key, required this.meal});

  @override
  State<MealDetailsScreen> createState() => _MealDetailsScreenState();
}

class _MealDetailsScreenState extends State<MealDetailsScreen> {
  Meal? meal;

  @override
  void initState() {
    super.initState();
    _loadMealDetails();
  }

  Future<void> _loadMealDetails() async {
    final mealDetails = await MealsApiConnector().getMealDetails(
      mealId: widget.meal.id,
    );

    setState(() {
      meal = mealDetails;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (meal != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(meal!.title),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (meal!.imageUrl.isNotEmpty)
                  Image.network(
                    meal!.imageUrl,
                    height: 300,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 300,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 48),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 300,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.restaurant, size: 48),
                    ),
                  ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        meal!.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Summary
                      if (meal?.summary != null)
                        Text(
                          'Summary\n' + (meal!.summary as String),
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.black87,
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Instructions
                      if (meal?.summary != null)
                        Text(
                          'Instructions\n' + (meal!.instructions as String),
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.black87,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.green[700],
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(meal);
                          },
                          child: const Text(
                            'Confirm',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey[400]!),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(null);
                          },
                          child: const Text(
                            'Reject',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}
