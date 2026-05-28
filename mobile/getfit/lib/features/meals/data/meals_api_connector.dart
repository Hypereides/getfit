import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../../core/models/ingredient.dart';
import '../domain/meal.dart';

const String BASE_URL = 'https://api.spoonacular.com';

class MealsApiConnector {
  Future<List<Meal>> getMealsWithConstraints({
    int? minCalories,
    int? maxCalories,
  }) async {
    final url =
        BASE_URL +
        '/recipes/findByNutrients' +
        (minCalories != null
            ? '?minCalories=${minCalories}'
            : '?minCalories=0') +
        (maxCalories != null ? '&maxCalories=${maxCalories}' : '') +
        '&excludeIngredients=true' +
        '&fillIngredients=true' +
        '&number=5' +
        '&apiKey=bbfb2f7a968c4c448a41b02eb12d19e2';

    debugPrint('Calling: $url');

    final uri = Uri.parse(url);

    var decoded = jsonDecode(exampleFindByNutrientsResponse);

    // Comment out those two to use the example (save API credits)
    final response = await http.get(uri);
    decoded = jsonDecode(response.body);

    final List<Meal> meals = [];

    for (final item in decoded) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);

      meals.add(
        Meal(
          id: map['id']?.toString() ?? '',
          title: map['title']?.toString() ?? '',
          imageUrl: map['image'] ?? '',
          calories: parseNumber(map['calories']),
          proteinGrams: parseNumber(map['protein']),
          carbsGrams: parseNumber(map['carbs']),
          fatsGrams: parseNumber(map['fat']),
        ),
      );
    }

    return meals;
  }

  Future<Meal> getMealDetails({required String mealId}) async {
    final url =
        BASE_URL +
        '/recipes/${mealId}/information' +
        '?includeNutrition=false'
            '&apiKey=bbfb2f7a968c4c448a41b02eb12d19e2';

    debugPrint('Calling: $url');

    final uri = Uri.parse(url);

    var decoded = jsonDecode(removeHtml(exampleInformationResponse));

    // Comment out those two to use the example (save API credits)
    final response = await http.get(uri);
    decoded = jsonDecode(removeHtml(response.body));

    final map = Map<String, dynamic>.from(decoded);

    final ingredients =
        (map['extendedIngredients'] as List<dynamic>? ?? <dynamic>[])
            .map(
              (e) => Ingredient(
                id: e['id']?.toString() ?? '',
                image: e['image'] as String? ?? '',
                consistency: e['consistency'] as String? ?? '',
                name: e['name'] as String? ?? '',
                original: e['original'] as String? ?? '',
                amount: e['amount'] is num ? (e['amount'] as num).toInt() : 0,
                unit: e['unit'] as String? ?? '',
              ),
            )
            .toList();

    return Meal(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      imageUrl: map['image'] ?? '',
      summary: map['summary'] ?? '',
      instructions: map['instructions'] ?? '',
      ingredients: ingredients,
    );
  }
}

int parseNumber(dynamic value) {
  if (value == null) return 0;
  final cleaned = value.toString().replaceAll(RegExp(r'[^0-9]'), '');
  return int.tryParse(cleaned) ?? 0;
}

String removeHtml(String s) {
  return s.replaceAll(RegExp(r'<[^>]*>'), '');
}

final String exampleFindByNutrientsResponse = '''
  [
    {
      "id": 636360,
      "title": "Brussels Sprout Carbonara with Fettuccini",
      "image": "https://img.spoonacular.com/recipes/636360-312x231.jpg",
      "imageType": "jpg",
      "calories": 549,
      "protein": "38g",
      "fat": "17g",
      "carbs": "0g"
    },
    {
      "id": 636392,
      "title": "Buckwheat Crepes",
      "image": "https://img.spoonacular.com/recipes/636392-312x231.jpg",
      "imageType": "jpg",
      "calories": 374,
      "protein": "13g",
      "fat": "14g",
      "carbs": "0g"
    },
    {
      "id": 641974,
      "title": "Easy Gift Lasagna",
      "image": "https://img.spoonacular.com/recipes/641974-312x231.jpg",
      "imageType": "jpg",
      "calories": 307,
      "protein": "17g",
      "fat": "18g",
      "carbs": "0g"
    },
    {
      "id": 643514,
      "title": "Fresh Herb Omelette",
      "image": "https://img.spoonacular.com/recipes/643514-312x231.jpg",
      "imageType": "jpg",
      "calories": 317,
      "protein": "17g",
      "fat": "26g",
      "carbs": "0g"
    },
    {
      "id": 715397,
      "title": "Cheesy Chicken and Rice Casserole",
      "image": "https://img.spoonacular.com/recipes/715397-312x231.jpg",
      "imageType": "jpg",
      "calories": 464,
      "protein": "31g",
      "fat": "28g",
      "carbs": "0g"
    }
  ]
  ''';

final String exampleInformationResponse = '''
  {
    "id": 715397,
    "image": "https://img.spoonacular.com/recipes/715397-556x370.jpg",
    "imageType": "jpg",
    "title": "Cheesy Chicken and Rice Casserole",
    "readyInMinutes": 60,
    "servings": 6,
    "sourceUrl": "https://www.pinkwhen.com/cheesy-chicken-and-rice-casserole-bake/",
    "vegetarian": false,
    "vegan": false,
    "glutenFree": true,
    "dairyFree": false,
    "veryHealthy": false,
    "cheap": false,
    "veryPopular": true,
    "sustainable": false,
    "lowFodmap": false,
    "weightWatcherSmartPoints": 15,
    "gaps": "no",
    "preparationMinutes": 30,
    "cookingMinutes": 30,
    "aggregateLikes": 1416,
    "healthScore": 7,
    "creditsText": "pinkwhen.com",
    "license": null,
    "sourceName": "pinkwhen.com",
    "pricePerServing": 228.48,
    "extendedIngredients": [
      {
        "id": 5064,
        "aisle": "Meat",
        "image": "cooked-chicken-breast.png",
        "consistency": "SOLID",
        "name": "grilled chicken breasts",
        "nameClean": "grilled chicken breasts",
        "original": "2 grilled chicken breasts",
        "originalName": "grilled chicken breasts",
        "amount": 2,
        "unit": "",
        "meta": [],
        "measures": {
          "us": {
            "amount": 2,
            "unitShort": "",
            "unitLong": ""
          },
          "metric": {
            "amount": 2,
            "unitShort": "",
            "unitLong": ""
          }
        }
      },
      {
        "id": 10220445,
        "aisle": "Pasta and Rice",
        "image": "uncooked-white-rice.png",
        "consistency": "SOLID",
        "name": "rice",
        "nameClean": "rice",
        "original": "2 cups rice (cooked)",
        "originalName": "rice (cooked)",
        "amount": 2,
        "unit": "cups",
        "meta": [
          "cooked",
          "()"
        ],
        "measures": {
          "us": {
            "amount": 2,
            "unitShort": "cups",
            "unitLong": "cups"
          },
          "metric": {
            "amount": 316,
            "unitShort": "g",
            "unitLong": "grams"
          }
        }
      },
      {
        "id": 1017,
        "aisle": "Cheese",
        "image": "cream-cheese.jpg",
        "consistency": "SOLID",
        "name": "cream cheese",
        "nameClean": "cream cheese",
        "original": "1 8oz package cream cheese",
        "originalName": "package cream cheese",
        "amount": 8,
        "unit": "oz",
        "meta": [],
        "measures": {
          "us": {
            "amount": 8,
            "unitShort": "oz",
            "unitLong": "ounces"
          },
          "metric": {
            "amount": 226.796,
            "unitShort": "g",
            "unitLong": "grams"
          }
        }
      },
      {
        "id": 6147,
        "aisle": "Canned and Jarred",
        "image": "cream-of-mushroom-soup.png",
        "consistency": "LIQUID",
        "name": "cream of mushroom soup",
        "nameClean": "cream of mushroom soup",
        "original": "1 10oz. can cream of mushroom soup",
        "originalName": "cream of mushroom soup",
        "amount": 10,
        "unit": "oz",
        "meta": [
          "canned"
        ],
        "measures": {
          "us": {
            "amount": 10,
            "unitShort": "oz",
            "unitLong": "ounces"
          },
          "metric": {
            "amount": 283.495,
            "unitShort": "g",
            "unitLong": "grams"
          }
        }
      },
      {
        "id": 11333,
        "aisle": "Produce",
        "image": "green-pepper.jpg",
        "consistency": "SOLID",
        "name": "bell pepper",
        "nameClean": "bell pepper",
        "original": "1 medium green pepper",
        "originalName": "green pepper",
        "amount": 1,
        "unit": "medium",
        "meta": [
          "green"
        ],
        "measures": {
          "us": {
            "amount": 1,
            "unitShort": "medium",
            "unitLong": "medium"
          },
          "metric": {
            "amount": 1,
            "unitShort": "medium",
            "unitLong": "medium"
          }
        }
      },
      {
        "id": 1001025,
        "aisle": "Cheese",
        "image": "shredded-cheese-white.jpg",
        "consistency": "SOLID",
        "name": "monterrey jack cheese",
        "nameClean": "monterrey jack cheese",
        "original": "1½ cup shredded Monterrey Jack cheese",
        "originalName": "shredded Monterrey Jack cheese",
        "amount": 1.5,
        "unit": "cup",
        "meta": [
          "shredded"
        ],
        "measures": {
          "us": {
            "amount": 1.5,
            "unitShort": "cups",
            "unitLong": "cups"
          },
          "metric": {
            "amount": 169.5,
            "unitShort": "g",
            "unitLong": "grams"
          }
        }
      },
      {
        "id": 10011282,
        "aisle": "Produce",
        "image": "red-onion.png",
        "consistency": "SOLID",
        "name": "onion",
        "nameClean": "onion",
        "original": "½ red onion",
        "originalName": "red onion",
        "amount": 0.5,
        "unit": "",
        "meta": [
          "red"
        ],
        "measures": {
          "us": {
            "amount": 0.5,
            "unitShort": "",
            "unitLong": ""
          },
          "metric": {
            "amount": 0.5,
            "unitShort": "",
            "unitLong": ""
          }
        }
      },
      {
        "id": 1102047,
        "aisle": "Spices and Seasonings",
        "image": "salt-and-pepper.jpg",
        "consistency": "SOLID",
        "name": "salt and pepper",
        "nameClean": "salt and pepper",
        "original": "Salt and pepper to taste",
        "originalName": "Salt and pepper to taste",
        "amount": 6,
        "unit": "servings",
        "meta": [
          "to taste"
        ],
        "measures": {
          "us": {
            "amount": 6,
            "unitShort": "servings",
            "unitLong": "servings"
          },
          "metric": {
            "amount": 6,
            "unitShort": "servings",
            "unitLong": "servings"
          }
        }
      },
      {
        "id": 4673,
        "aisle": "Milk, Eggs, Other Dairy",
        "image": "light-buttery-spread.png",
        "consistency": "SOLID",
        "name": "country crock buttery spread",
        "nameClean": "country crock buttery spread",
        "original": "2 Tbsp Country crock buttery spread",
        "originalName": "Country crock buttery spread",
        "amount": 2,
        "unit": "Tbsp",
        "meta": [],
        "measures": {
          "us": {
            "amount": 2,
            "unitShort": "Tbsps",
            "unitLong": "Tbsps"
          },
          "metric": {
            "amount": 2,
            "unitShort": "Tbsps",
            "unitLong": "Tbsps"
          }
        }
      }
    ],
    "summary": "Cheesy Chicken and Rice Casserole might be just the main course you are searching for. This recipe makes 6 servings with <b>464 calories</b>, <b>31g of protein</b>, and <b>28g of fat</b> each. For <b>\$2.28 per serving</b>, this recipe <b>covers 17%</b> of your daily requirements of vitamins and minerals. From preparation to the plate, this recipe takes about <b>1 hour</b>. <b>Autumn</b> will be even more special with this recipe. 1416 people were impressed by this recipe. Head to the store and pick up cream of mushroom soup, salt and pepper, onion, and a few other things to make it today. It is brought to you by Pink When. It is a good option if you're following a <b>gluten free</b> diet. Taking all factors into account, this recipe <b>earns a spoonacular score of 67%</b>, which is solid. Similar recipes include <a href=\"https://spoonacular.com/recipes/cheesy-chicken-and-rice-casserole-1313515\">Cheesy Chicken and Rice Casserole</a>, <a href=\"https://spoonacular.com/recipes/cheesy-chicken-and-rice-casserole-1272147\">Cheesy Chicken and Rice Casserole</a>, and <a href=\"https://spoonacular.com/recipes/cheesy-chicken-and-rice-casserole-1516829\">Cheesy Chicken and Rice Casserole</a>.",
    "cuisines": [],
    "dishTypes": [
      "side dish",
      "lunch",
      "main course",
      "main dish",
      "dinner"
    ],
    "diets": [
      "gluten free"
    ],
    "occasions": [
      "fall",
      "winter"
    ],
    "instructions": "<p>Heat your oven to 350.Take your 2 grilled chicken breasts and allow them to slightly cool. Shred chicken breasts and place to the side in a mixing bowl.Finely chop your pepper and onion and saut in 2 Tbsp Country Crock for 5 minutes until soft.Add cream cheese into the onion and pepper and mix well.Pour into the large bowl with chicken. Mix in rice, hot sauce, cream of mushroom soup,  cup Monterrey Jack cheese, and salt and pepper. Mix well.Pour mixture in a 9 x 13 dish, and cover with remaining cheese and add salt and pepper to taste. Bake for 30 minutes. Allow to cool for 5 minutes before serving.</p>",
    "analyzedInstructions": [
      {
        "name": "",
        "steps": [
          {
            "number": 1,
            "step": "Heat your oven to 350.Take your 2 grilled chicken breasts and allow them to slightly cool. Shred chicken breasts and place to the side in a mixing bowl.Finely chop your pepper and onion and saut in 2 Tbsp Country Crock for 5 minutes until soft.",
            "ingredients": [
              {
                "id": 5064,
                "name": "cooked chicken breast",
                "localizedName": "cooked chicken breast",
                "image": "cooked-chicken-breast.png"
              },
              {
                "id": 5062,
                "name": "chicken breast",
                "localizedName": "chicken breast",
                "image": "chicken-breasts.png"
              },
              {
                "id": 1002030,
                "name": "pepper",
                "localizedName": "pepper",
                "image": "pepper.jpg"
              },
              {
                "id": 11282,
                "name": "onion",
                "localizedName": "onion",
                "image": "brown-onion.png"
              }
            ],
            "equipment": [
              {
                "id": 405907,
                "name": "mixing bowl",
                "localizedName": "mixing bowl",
                "image": "https://spoonacular.com/cdn/equipment_100x100/mixing-bowl.jpg"
              },
              {
                "id": 404784,
                "name": "oven",
                "localizedName": "oven",
                "image": "https://spoonacular.com/cdn/equipment_100x100/oven.jpg"
              }
            ],
            "length": {
              "number": 5,
              "unit": "minutes"
            }
          },
          {
            "number": 2,
            "step": "Add cream cheese into the onion and pepper and mix well.",
            "ingredients": [
              {
                "id": 1017,
                "name": "cream cheese",
                "localizedName": "cream cheese",
                "image": "cream-cheese.jpg"
              },
              {
                "id": 1002030,
                "name": "pepper",
                "localizedName": "pepper",
                "image": "pepper.jpg"
              },
              {
                "id": 11282,
                "name": "onion",
                "localizedName": "onion",
                "image": "brown-onion.png"
              }
            ],
            "equipment": []
          },
          {
            "number": 3,
            "step": "Pour into the large bowl with chicken.",
            "ingredients": [
              {
                "id": 0,
                "name": "chicken",
                "localizedName": "chicken",
                "image": "https://spoonacular.com/cdn/ingredients_100x100/whole-chicken.jpg"
              }
            ],
            "equipment": [
              {
                "id": 404783,
                "name": "bowl",
                "localizedName": "bowl",
                "image": "https://spoonacular.com/cdn/equipment_100x100/bowl.jpg"
              }
            ]
          },
          {
            "number": 4,
            "step": "Mix in rice, hot sauce, cream of mushroom soup,  cup Monterrey Jack cheese, and salt and pepper.",
            "ingredients": [
              {
                "id": 6147,
                "name": "cream of mushroom soup",
                "localizedName": "cream of mushroom soup",
                "image": "cream-of-mushroom-soup.png"
              },
              {
                "id": 1102047,
                "name": "salt and pepper",
                "localizedName": "salt and pepper",
                "image": "salt-and-pepper.jpg"
              },
              {
                "id": 1001025,
                "name": "monterey jack cheese",
                "localizedName": "monterey jack cheese",
                "image": "shredded-cheese-white.jpg"
              },
              {
                "id": 6168,
                "name": "hot sauce",
                "localizedName": "hot sauce",
                "image": "hot-sauce-or-tabasco.png"
              },
              {
                "id": 20444,
                "name": "rice",
                "localizedName": "rice",
                "image": "uncooked-white-rice.png"
              }
            ],
            "equipment": []
          },
          {
            "number": 5,
            "step": "Mix well.",
            "ingredients": [],
            "equipment": []
          },
          {
            "number": 6,
            "step": "Pour mixture in a 9 x 13 dish, and cover with remaining cheese and add salt and pepper to taste.",
            "ingredients": [
              {
                "id": 1102047,
                "name": "salt and pepper",
                "localizedName": "salt and pepper",
                "image": "salt-and-pepper.jpg"
              },
              {
                "id": 1041009,
                "name": "cheese",
                "localizedName": "cheese",
                "image": "cheddar-cheese.png"
              }
            ],
            "equipment": []
          },
          {
            "number": 7,
            "step": "Bake for 30 minutes. Allow to cool for 5 minutes before serving.",
            "ingredients": [],
            "equipment": [
              {
                "id": 404784,
                "name": "oven",
                "localizedName": "oven",
                "image": "https://spoonacular.com/cdn/equipment_100x100/oven.jpg"
              }
            ],
            "length": {
              "number": 35,
              "unit": "minutes"
            }
          }
        ]
      }
    ],
    "language": "en",
    "spoonacularScore": 64.9417724609375,
    "spoonacularSourceUrl": "https://spoonacular.com/cheesy-chicken-and-rice-casserole-715397"
  }
  ''';
