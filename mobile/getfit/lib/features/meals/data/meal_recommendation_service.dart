import '../domain/meal_ingredient.dart';
import '../domain/meal_recommendation.dart';

class MealRecommendationService {
  Future<List<MealRecommendation>> getMealsWithConstraints({
    required String city,
    required String goal,
    required double remainingCalories,
    required double remainingProtein,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final pool = _buildPool(city, goal);
    pool.sort((a, b) {
      final scoreA = (a.calories - remainingCalories).abs() +
          (a.proteinGrams - remainingProtein).abs() * 4;
      final scoreB = (b.calories - remainingCalories).abs() +
          (b.proteinGrams - remainingProtein).abs() * 4;
      return scoreA.compareTo(scoreB);
    });

    return pool.take(5).toList();
  }

  List<MealRecommendation> _buildPool(String city, String goal) {
    final cityLower = city.toLowerCase();

    if (['athens', 'thessaloniki', 'patras', 'heraklion', 'larissa'].contains(cityLower)) {
      return _greekMeals + _goalMeals(goal);
    }
    if (['nicosia', 'limassol', 'larnaca', 'paphos'].contains(cityLower)) {
      return _cypriotMeals + _goalMeals(goal);
    }
    if (['london', 'manchester', 'birmingham', 'edinburgh', 'glasgow'].contains(cityLower)) {
      return _ukMeals + _goalMeals(goal);
    }
    if (['berlin', 'munich', 'hamburg', 'frankfurt', 'cologne'].contains(cityLower)) {
      return _germanMeals + _goalMeals(goal);
    }
    if (['paris', 'lyon', 'marseille', 'toulouse', 'nice'].contains(cityLower)) {
      return _frenchMeals + _goalMeals(goal);
    }
    if (['rome', 'milan', 'naples', 'turin', 'florence'].contains(cityLower)) {
      return _italianMeals + _goalMeals(goal);
    }
    if (['madrid', 'barcelona', 'valencia', 'seville', 'bilbao'].contains(cityLower)) {
      return _spanishMeals + _goalMeals(goal);
    }
    return _genericMeals + _goalMeals(goal);
  }

  List<MealRecommendation> _goalMeals(String goal) => switch (goal) {
        'lose_weight' => _loseMeals,
        'gain_weight' => _gainMeals,
        _ => _maintainMeals,
      };

  static final _greekMeals = const [
    MealRecommendation(
      id: 'gr1', title: 'Souvlaki Wrap', category: 'Lunch', imageEmoji: '🥙',
      calories: 520, proteinGrams: 38, carbsGrams: 45, fatsGrams: 18,
      description: 'Classic Greek pork or chicken souvlaki in a warm pita with tzatziki, tomato and onion.',
      ingredients: [
        MealIngredient(name: 'Chicken breast', amount: 200, unit: 'g'),
        MealIngredient(name: 'Pita bread', amount: 2, unit: 'pcs'),
        MealIngredient(name: 'Tzatziki', amount: 60, unit: 'g'),
        MealIngredient(name: 'Tomato', amount: 1, unit: 'pcs'),
        MealIngredient(name: 'Onion', amount: 0.5, unit: 'pcs'),
        MealIngredient(name: 'Olive oil', amount: 15, unit: 'ml'),
      ],
    ),
    MealRecommendation(
      id: 'gr2', title: 'Horiatiki Salad + Feta', category: 'Lunch', imageEmoji: '🥗',
      calories: 310, proteinGrams: 14, carbsGrams: 12, fatsGrams: 22,
      description: 'Traditional Greek village salad with ripe tomatoes, cucumber, olives and generous feta.',
      ingredients: [
        MealIngredient(name: 'Tomatoes', amount: 200, unit: 'g'),
        MealIngredient(name: 'Cucumber', amount: 150, unit: 'g'),
        MealIngredient(name: 'Feta cheese', amount: 80, unit: 'g'),
        MealIngredient(name: 'Kalamata olives', amount: 40, unit: 'g'),
        MealIngredient(name: 'Olive oil', amount: 30, unit: 'ml'),
        MealIngredient(name: 'Oregano', amount: 2, unit: 'g'),
      ],
    ),
    MealRecommendation(
      id: 'gr3', title: 'Grilled Lavraki & Greens', category: 'Dinner', imageEmoji: '🐟',
      calories: 430, proteinGrams: 44, carbsGrams: 8, fatsGrams: 24,
      description: 'Whole sea bass grilled with lemon and herbs, served with steamed wild greens (horta).',
      ingredients: [
        MealIngredient(name: 'Sea bass', amount: 350, unit: 'g'),
        MealIngredient(name: 'Lemon', amount: 2, unit: 'pcs'),
        MealIngredient(name: 'Wild greens (horta)', amount: 200, unit: 'g'),
        MealIngredient(name: 'Olive oil', amount: 20, unit: 'ml'),
        MealIngredient(name: 'Garlic', amount: 3, unit: 'pcs'),
      ],
    ),
    MealRecommendation(
      id: 'gr4', title: 'Greek Yogurt Bowl', category: 'Breakfast', imageEmoji: '🫙',
      calories: 340, proteinGrams: 22, carbsGrams: 38, fatsGrams: 10,
      description: 'Thick strained Greek yogurt topped with honey, walnuts and seasonal fresh fruit.',
      ingredients: [
        MealIngredient(name: 'Greek yogurt 0%', amount: 250, unit: 'g'),
        MealIngredient(name: 'Honey', amount: 20, unit: 'g'),
        MealIngredient(name: 'Walnuts', amount: 25, unit: 'g'),
        MealIngredient(name: 'Banana', amount: 1, unit: 'pcs'),
        MealIngredient(name: 'Blueberries', amount: 60, unit: 'g'),
      ],
    ),
  ];

  static final _cypriotMeals = const [
    MealRecommendation(
      id: 'cy1', title: 'Halloumi & Watermelon Salad', category: 'Lunch', imageEmoji: '🧀',
      calories: 370, proteinGrams: 20, carbsGrams: 28, fatsGrams: 22,
      description: 'Grilled halloumi paired with chilled watermelon, mint and a drizzle of balsamic.',
      ingredients: [
        MealIngredient(name: 'Halloumi', amount: 150, unit: 'g'),
        MealIngredient(name: 'Watermelon', amount: 300, unit: 'g'),
        MealIngredient(name: 'Fresh mint', amount: 10, unit: 'g'),
        MealIngredient(name: 'Balsamic glaze', amount: 15, unit: 'ml'),
        MealIngredient(name: 'Olive oil', amount: 10, unit: 'ml'),
      ],
    ),
    MealRecommendation(
      id: 'cy2', title: 'Koupepia (Stuffed Vine Leaves)', category: 'Dinner', imageEmoji: '🫙',
      calories: 480, proteinGrams: 26, carbsGrams: 52, fatsGrams: 16,
      description: 'Vine leaves stuffed with minced pork, rice, tomatoes and herbs, slow-cooked in lemon broth.',
      ingredients: [
        MealIngredient(name: 'Vine leaves', amount: 20, unit: 'pcs'),
        MealIngredient(name: 'Minced pork', amount: 200, unit: 'g'),
        MealIngredient(name: 'Rice', amount: 80, unit: 'g'),
        MealIngredient(name: 'Tomatoes', amount: 150, unit: 'g'),
        MealIngredient(name: 'Lemon juice', amount: 30, unit: 'ml'),
        MealIngredient(name: 'Fresh parsley', amount: 15, unit: 'g'),
      ],
    ),
  ];

  static final _ukMeals = const [
    MealRecommendation(
      id: 'uk1', title: 'Chicken Tikka Masala', category: 'Dinner', imageEmoji: '🍛',
      calories: 560, proteinGrams: 42, carbsGrams: 48, fatsGrams: 20,
      description: 'Tender chicken in a rich tomato-cream sauce with aromatic spices, served with basmati rice.',
      ingredients: [
        MealIngredient(name: 'Chicken breast', amount: 250, unit: 'g'),
        MealIngredient(name: 'Basmati rice', amount: 120, unit: 'g'),
        MealIngredient(name: 'Tikka masala paste', amount: 40, unit: 'g'),
        MealIngredient(name: 'Coconut cream', amount: 100, unit: 'ml'),
        MealIngredient(name: 'Tomato passata', amount: 150, unit: 'ml'),
        MealIngredient(name: 'Onion', amount: 1, unit: 'pcs'),
      ],
    ),
    MealRecommendation(
      id: 'uk2', title: 'Smoked Salmon Bagel', category: 'Breakfast', imageEmoji: '🥯',
      calories: 420, proteinGrams: 28, carbsGrams: 40, fatsGrams: 16,
      description: 'Toasted everything bagel loaded with cream cheese, smoked salmon and capers.',
      ingredients: [
        MealIngredient(name: 'Bagel', amount: 1, unit: 'pcs'),
        MealIngredient(name: 'Smoked salmon', amount: 80, unit: 'g'),
        MealIngredient(name: 'Cream cheese', amount: 40, unit: 'g'),
        MealIngredient(name: 'Capers', amount: 15, unit: 'g'),
        MealIngredient(name: 'Red onion', amount: 0.25, unit: 'pcs'),
        MealIngredient(name: 'Fresh dill', amount: 5, unit: 'g'),
      ],
    ),
  ];

  static final _germanMeals = const [
    MealRecommendation(
      id: 'de1', title: 'Hähnchen Schnitzel & Kartoffeln', category: 'Dinner', imageEmoji: '🍗',
      calories: 640, proteinGrams: 48, carbsGrams: 54, fatsGrams: 24,
      description: 'Crispy chicken schnitzel with roasted potatoes and a fresh cucumber salad.',
      ingredients: [
        MealIngredient(name: 'Chicken breast', amount: 250, unit: 'g'),
        MealIngredient(name: 'Breadcrumbs', amount: 50, unit: 'g'),
        MealIngredient(name: 'Potatoes', amount: 250, unit: 'g'),
        MealIngredient(name: 'Egg', amount: 1, unit: 'pcs'),
        MealIngredient(name: 'Lemon', amount: 1, unit: 'pcs'),
        MealIngredient(name: 'Sunflower oil', amount: 30, unit: 'ml'),
      ],
    ),
    MealRecommendation(
      id: 'de2', title: 'Vollkorn Müsli Bowl', category: 'Breakfast', imageEmoji: '🥣',
      calories: 390, proteinGrams: 14, carbsGrams: 62, fatsGrams: 10,
      description: 'Hearty whole-grain müsli with oats, nuts, seeds and fresh berries in cold milk.',
      ingredients: [
        MealIngredient(name: 'Rolled oats', amount: 80, unit: 'g'),
        MealIngredient(name: 'Mixed nuts', amount: 20, unit: 'g'),
        MealIngredient(name: 'Sunflower seeds', amount: 10, unit: 'g'),
        MealIngredient(name: 'Mixed berries', amount: 100, unit: 'g'),
        MealIngredient(name: 'Milk', amount: 200, unit: 'ml'),
      ],
    ),
  ];

  static final _frenchMeals = const [
    MealRecommendation(
      id: 'fr1', title: 'Poulet Rôti & Ratatouille', category: 'Dinner', imageEmoji: '🍗',
      calories: 590, proteinGrams: 46, carbsGrams: 30, fatsGrams: 28,
      description: 'Classic roasted Provençal chicken thighs served alongside a rich vegetable ratatouille.',
      ingredients: [
        MealIngredient(name: 'Chicken thighs', amount: 300, unit: 'g'),
        MealIngredient(name: 'Zucchini', amount: 150, unit: 'g'),
        MealIngredient(name: 'Eggplant', amount: 150, unit: 'g'),
        MealIngredient(name: 'Bell pepper', amount: 1, unit: 'pcs'),
        MealIngredient(name: 'Tomatoes', amount: 200, unit: 'g'),
        MealIngredient(name: 'Olive oil', amount: 25, unit: 'ml'),
        MealIngredient(name: 'Herbes de Provence', amount: 5, unit: 'g'),
      ],
    ),
    MealRecommendation(
      id: 'fr2', title: 'Crêpes aux Champignons', category: 'Lunch', imageEmoji: '🥞',
      calories: 430, proteinGrams: 18, carbsGrams: 48, fatsGrams: 18,
      description: 'Thin savoury buckwheat crêpes filled with sautéed mushrooms, gruyère and fresh herbs.',
      ingredients: [
        MealIngredient(name: 'Buckwheat flour', amount: 80, unit: 'g'),
        MealIngredient(name: 'Mushrooms', amount: 200, unit: 'g'),
        MealIngredient(name: 'Gruyère cheese', amount: 40, unit: 'g'),
        MealIngredient(name: 'Egg', amount: 1, unit: 'pcs'),
        MealIngredient(name: 'Milk', amount: 150, unit: 'ml'),
        MealIngredient(name: 'Butter', amount: 15, unit: 'g'),
      ],
    ),
  ];

  static final _italianMeals = const [
    MealRecommendation(
      id: 'it1', title: 'Pasta al Pomodoro', category: 'Lunch', imageEmoji: '🍝',
      calories: 520, proteinGrams: 18, carbsGrams: 82, fatsGrams: 14,
      description: 'Al dente pasta in a simple, vibrant San Marzano tomato sauce with fresh basil.',
      ingredients: [
        MealIngredient(name: 'Spaghetti', amount: 120, unit: 'g'),
        MealIngredient(name: 'San Marzano tomatoes', amount: 250, unit: 'g'),
        MealIngredient(name: 'Garlic', amount: 2, unit: 'pcs'),
        MealIngredient(name: 'Fresh basil', amount: 10, unit: 'g'),
        MealIngredient(name: 'Olive oil', amount: 20, unit: 'ml'),
        MealIngredient(name: 'Parmesan', amount: 20, unit: 'g'),
      ],
    ),
    MealRecommendation(
      id: 'it2', title: 'Frittata di Verdure', category: 'Breakfast', imageEmoji: '🍳',
      calories: 360, proteinGrams: 24, carbsGrams: 10, fatsGrams: 24,
      description: 'Italian baked egg frittata loaded with seasonal vegetables and melted pecorino.',
      ingredients: [
        MealIngredient(name: 'Eggs', amount: 4, unit: 'pcs'),
        MealIngredient(name: 'Zucchini', amount: 100, unit: 'g'),
        MealIngredient(name: 'Cherry tomatoes', amount: 80, unit: 'g'),
        MealIngredient(name: 'Pecorino cheese', amount: 30, unit: 'g'),
        MealIngredient(name: 'Olive oil', amount: 15, unit: 'ml'),
        MealIngredient(name: 'Fresh parsley', amount: 8, unit: 'g'),
      ],
    ),
  ];

  static final _spanishMeals = const [
    MealRecommendation(
      id: 'es1', title: 'Tortilla Española', category: 'Lunch', imageEmoji: '🥚',
      calories: 440, proteinGrams: 20, carbsGrams: 38, fatsGrams: 22,
      description: 'Thick Spanish potato omelette with caramelised onions, served warm or at room temperature.',
      ingredients: [
        MealIngredient(name: 'Eggs', amount: 4, unit: 'pcs'),
        MealIngredient(name: 'Potatoes', amount: 300, unit: 'g'),
        MealIngredient(name: 'Onion', amount: 1, unit: 'pcs'),
        MealIngredient(name: 'Olive oil', amount: 40, unit: 'ml'),
        MealIngredient(name: 'Salt', amount: 3, unit: 'g'),
      ],
    ),
    MealRecommendation(
      id: 'es2', title: 'Pollo al Ajillo', category: 'Dinner', imageEmoji: '🍗',
      calories: 510, proteinGrams: 44, carbsGrams: 8, fatsGrams: 30,
      description: 'Chicken pieces sautéed in a generous amount of garlic, white wine and smoked paprika.',
      ingredients: [
        MealIngredient(name: 'Chicken thighs', amount: 300, unit: 'g'),
        MealIngredient(name: 'Garlic', amount: 8, unit: 'pcs'),
        MealIngredient(name: 'White wine', amount: 80, unit: 'ml'),
        MealIngredient(name: 'Smoked paprika', amount: 4, unit: 'g'),
        MealIngredient(name: 'Olive oil', amount: 30, unit: 'ml'),
        MealIngredient(name: 'Fresh parsley', amount: 10, unit: 'g'),
      ],
    ),
  ];

  static final _genericMeals = const [
    MealRecommendation(
      id: 'gn1', title: 'Chicken & Rice Bowl', category: 'Lunch', imageEmoji: '🍚',
      calories: 580, proteinGrams: 46, carbsGrams: 62, fatsGrams: 14,
      description: 'Lean grilled chicken over fluffy basmati rice with steamed broccoli and teriyaki glaze.',
      ingredients: [
        MealIngredient(name: 'Chicken breast', amount: 200, unit: 'g'),
        MealIngredient(name: 'Basmati rice', amount: 120, unit: 'g'),
        MealIngredient(name: 'Broccoli', amount: 150, unit: 'g'),
        MealIngredient(name: 'Teriyaki sauce', amount: 30, unit: 'ml'),
        MealIngredient(name: 'Sesame seeds', amount: 5, unit: 'g'),
      ],
    ),
    MealRecommendation(
      id: 'gn2', title: 'Overnight Oats', category: 'Breakfast', imageEmoji: '🥣',
      calories: 430, proteinGrams: 18, carbsGrams: 60, fatsGrams: 12,
      description: 'Creamy oats soaked overnight in milk with chia seeds, topped with peanut butter and banana.',
      ingredients: [
        MealIngredient(name: 'Rolled oats', amount: 80, unit: 'g'),
        MealIngredient(name: 'Milk', amount: 200, unit: 'ml'),
        MealIngredient(name: 'Chia seeds', amount: 10, unit: 'g'),
        MealIngredient(name: 'Peanut butter', amount: 20, unit: 'g'),
        MealIngredient(name: 'Banana', amount: 1, unit: 'pcs'),
      ],
    ),
    MealRecommendation(
      id: 'gn3', title: 'Salmon & Quinoa', category: 'Dinner', imageEmoji: '🐟',
      calories: 550, proteinGrams: 42, carbsGrams: 38, fatsGrams: 22,
      description: 'Baked salmon fillet over quinoa with roasted asparagus and lemon-dill dressing.',
      ingredients: [
        MealIngredient(name: 'Salmon fillet', amount: 200, unit: 'g'),
        MealIngredient(name: 'Quinoa', amount: 100, unit: 'g'),
        MealIngredient(name: 'Asparagus', amount: 150, unit: 'g'),
        MealIngredient(name: 'Lemon', amount: 1, unit: 'pcs'),
        MealIngredient(name: 'Olive oil', amount: 15, unit: 'ml'),
        MealIngredient(name: 'Fresh dill', amount: 8, unit: 'g'),
      ],
    ),
  ];

  static final _loseMeals = const [
    MealRecommendation(
      id: 'lose1', title: 'Grilled Chicken Salad', category: 'Lunch', imageEmoji: '🥗',
      calories: 320, proteinGrams: 36, carbsGrams: 14, fatsGrams: 12,
      description: 'Light and filling salad with grilled chicken breast, mixed greens and a light vinaigrette.',
      ingredients: [
        MealIngredient(name: 'Chicken breast', amount: 180, unit: 'g'),
        MealIngredient(name: 'Mixed greens', amount: 120, unit: 'g'),
        MealIngredient(name: 'Cherry tomatoes', amount: 80, unit: 'g'),
        MealIngredient(name: 'Cucumber', amount: 80, unit: 'g'),
        MealIngredient(name: 'Balsamic vinegar', amount: 15, unit: 'ml'),
        MealIngredient(name: 'Olive oil', amount: 10, unit: 'ml'),
      ],
    ),
    MealRecommendation(
      id: 'lose2', title: 'Egg White Omelette', category: 'Breakfast', imageEmoji: '🍳',
      calories: 280, proteinGrams: 28, carbsGrams: 12, fatsGrams: 8,
      description: 'High-protein egg white omelette with spinach, mushrooms and low-fat cheese.',
      ingredients: [
        MealIngredient(name: 'Egg whites', amount: 6, unit: 'pcs'),
        MealIngredient(name: 'Spinach', amount: 80, unit: 'g'),
        MealIngredient(name: 'Mushrooms', amount: 100, unit: 'g'),
        MealIngredient(name: 'Low-fat cheese', amount: 30, unit: 'g'),
        MealIngredient(name: 'Olive oil spray', amount: 5, unit: 'ml'),
      ],
    ),
  ];

  static final _gainMeals = const [
    MealRecommendation(
      id: 'gain1', title: 'Mass Builder Bowl', category: 'Lunch', imageEmoji: '💪',
      calories: 820, proteinGrams: 58, carbsGrams: 88, fatsGrams: 22,
      description: 'Calorie-dense bowl with beef, sweet potato, avocado and brown rice for serious muscle gain.',
      ingredients: [
        MealIngredient(name: 'Lean beef mince', amount: 250, unit: 'g'),
        MealIngredient(name: 'Brown rice', amount: 150, unit: 'g'),
        MealIngredient(name: 'Sweet potato', amount: 200, unit: 'g'),
        MealIngredient(name: 'Avocado', amount: 0.5, unit: 'pcs'),
        MealIngredient(name: 'Olive oil', amount: 15, unit: 'ml'),
        MealIngredient(name: 'Soy sauce', amount: 15, unit: 'ml'),
      ],
    ),
    MealRecommendation(
      id: 'gain2', title: 'Peanut Butter Banana Shake', category: 'Breakfast', imageEmoji: '🥤',
      calories: 620, proteinGrams: 35, carbsGrams: 72, fatsGrams: 20,
      description: 'Thick high-calorie shake with banana, peanut butter, oats, milk and whey protein.',
      ingredients: [
        MealIngredient(name: 'Banana', amount: 2, unit: 'pcs'),
        MealIngredient(name: 'Peanut butter', amount: 40, unit: 'g'),
        MealIngredient(name: 'Rolled oats', amount: 60, unit: 'g'),
        MealIngredient(name: 'Whole milk', amount: 300, unit: 'ml'),
        MealIngredient(name: 'Whey protein', amount: 30, unit: 'g'),
      ],
    ),
  ];

  static final _maintainMeals = const [
    MealRecommendation(
      id: 'main1', title: 'Turkey & Veggie Wrap', category: 'Lunch', imageEmoji: '🫔',
      calories: 440, proteinGrams: 32, carbsGrams: 42, fatsGrams: 14,
      description: 'Balanced whole-wheat wrap with turkey, avocado, roasted peppers and hummus.',
      ingredients: [
        MealIngredient(name: 'Whole-wheat tortilla', amount: 1, unit: 'pcs'),
        MealIngredient(name: 'Turkey breast', amount: 150, unit: 'g'),
        MealIngredient(name: 'Avocado', amount: 0.5, unit: 'pcs'),
        MealIngredient(name: 'Roasted peppers', amount: 80, unit: 'g'),
        MealIngredient(name: 'Hummus', amount: 40, unit: 'g'),
        MealIngredient(name: 'Romaine lettuce', amount: 40, unit: 'g'),
      ],
    ),
    MealRecommendation(
      id: 'main2', title: 'Baked Cod & Sweet Potato', category: 'Dinner', imageEmoji: '🐟',
      calories: 480, proteinGrams: 38, carbsGrams: 46, fatsGrams: 14,
      description: 'Light baked cod with herb crust paired with sweet potato mash and steamed green beans.',
      ingredients: [
        MealIngredient(name: 'Cod fillet', amount: 220, unit: 'g'),
        MealIngredient(name: 'Sweet potato', amount: 200, unit: 'g'),
        MealIngredient(name: 'Green beans', amount: 120, unit: 'g'),
        MealIngredient(name: 'Breadcrumbs', amount: 20, unit: 'g'),
        MealIngredient(name: 'Olive oil', amount: 15, unit: 'ml'),
        MealIngredient(name: 'Lemon', amount: 1, unit: 'pcs'),
      ],
    ),
  ];
}