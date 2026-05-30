import '../domain/store.dart';
import '../domain/store_meal_item.dart';

class StoreDatabase {
  static List<Store> forCity(String city) {
    final c = city.toLowerCase();

    if ({'athens', 'thessaloniki', 'patras', 'heraklion', 'larissa'}.contains(c)) {
      return _greekStores;
    }
    if ({'nicosia', 'limassol', 'larnaca', 'paphos'}.contains(c)) {
      return _cyprusStores;
    }
    if ({'london', 'manchester', 'birmingham', 'edinburgh', 'glasgow'}.contains(c)) {
      return _ukStores;
    }
    if ({'berlin', 'munich', 'hamburg', 'frankfurt', 'cologne'}.contains(c)) {
      return _germanStores;
    }
    if ({'paris', 'lyon', 'marseille', 'toulouse', 'nice'}.contains(c)) {
      return _frenchStores;
    }
    if ({'rome', 'milan', 'naples', 'turin', 'florence'}.contains(c)) {
      return _italianStores;
    }
    if ({'madrid', 'barcelona', 'valencia', 'seville', 'bilbao'}.contains(c)) {
      return _spanishStores;
    }
    return _genericStores;
  }

  static const _mcdonalds = Store(
    id: 'mcdonalds',
    name: "McDonald's",
    emoji: '🍟',
    type: 'Fast Food',
    menu: [
      StoreMealItem(id: 'mc1', name: 'Big Mac', category: 'Burgers', emoji: '🍔',
          calories: 550, proteinGrams: 25, carbsGrams: 46, fatsGrams: 30, servingGrams: 210),
      StoreMealItem(id: 'mc2', name: 'McChicken', category: 'Burgers', emoji: '🍔',
          calories: 400, proteinGrams: 22, carbsGrams: 40, fatsGrams: 17, servingGrams: 180),
      StoreMealItem(id: 'mc3', name: 'Filet-O-Fish', category: 'Burgers', emoji: '🐟',
          calories: 380, proteinGrams: 15, carbsGrams: 38, fatsGrams: 18, servingGrams: 160),
      StoreMealItem(id: 'mc4', name: 'Double Cheeseburger', category: 'Burgers', emoji: '🍔',
          calories: 450, proteinGrams: 26, carbsGrams: 34, fatsGrams: 24, servingGrams: 175),
      StoreMealItem(id: 'mc5', name: 'McNuggets 6 pc', category: 'Chicken', emoji: '🍗',
          calories: 280, proteinGrams: 15, carbsGrams: 17, fatsGrams: 17, servingGrams: 108),
      StoreMealItem(id: 'mc6', name: 'McNuggets 9 pc', category: 'Chicken', emoji: '🍗',
          calories: 420, proteinGrams: 23, carbsGrams: 25, fatsGrams: 26, servingGrams: 162),
      StoreMealItem(id: 'mc7', name: 'McWrap Grilled Chicken', category: 'Chicken', emoji: '🌯',
          calories: 430, proteinGrams: 38, carbsGrams: 42, fatsGrams: 11, servingGrams: 250),
      StoreMealItem(id: 'mc8', name: 'Caesar Salad', category: 'Salads', emoji: '🥗',
          calories: 190, proteinGrams: 16, carbsGrams: 9, fatsGrams: 9, servingGrams: 220),
      StoreMealItem(id: 'mc9', name: 'Medium Fries', category: 'Sides', emoji: '🍟',
          calories: 340, proteinGrams: 4, carbsGrams: 44, fatsGrams: 16, servingGrams: 117),
      StoreMealItem(id: 'mc10', name: 'Large Fries', category: 'Sides', emoji: '🍟',
          calories: 490, proteinGrams: 6, carbsGrams: 64, fatsGrams: 23, servingGrams: 170),
      StoreMealItem(id: 'mc11', name: 'McFlurry Oreo', category: 'Desserts', emoji: '🍦',
          calories: 390, proteinGrams: 11, carbsGrams: 62, fatsGrams: 12, servingGrams: 300),
      StoreMealItem(id: 'mc12', name: 'Medium Coke', category: 'Drinks', emoji: '🥤',
          calories: 210, proteinGrams: 0, carbsGrams: 57, fatsGrams: 0, servingGrams: 400),
      StoreMealItem(id: 'mc13', name: 'Orange Juice', category: 'Drinks', emoji: '🍊',
          calories: 140, proteinGrams: 2, carbsGrams: 33, fatsGrams: 0, servingGrams: 300),
    ],
  );

  static const _kfc = Store(
    id: 'kfc',
    name: 'KFC',
    emoji: '🍗',
    type: 'Fast Food',
    menu: [
      StoreMealItem(id: 'kfc1', name: 'Original Recipe Piece', category: 'Chicken', emoji: '🍗',
          calories: 320, proteinGrams: 22, carbsGrams: 11, fatsGrams: 22, servingGrams: 160),
      StoreMealItem(id: 'kfc2', name: 'Zinger Burger', category: 'Burgers', emoji: '🍔',
          calories: 490, proteinGrams: 28, carbsGrams: 49, fatsGrams: 21, servingGrams: 220),
      StoreMealItem(id: 'kfc3', name: 'Crispy Twister', category: 'Wraps', emoji: '🌯',
          calories: 540, proteinGrams: 26, carbsGrams: 55, fatsGrams: 22, servingGrams: 260),
      StoreMealItem(id: 'kfc4', name: 'Popcorn Chicken (Regular)', category: 'Chicken', emoji: '🍗',
          calories: 370, proteinGrams: 22, carbsGrams: 27, fatsGrams: 19, servingGrams: 140),
      StoreMealItem(id: 'kfc5', name: 'Hot Wings 5 pc', category: 'Chicken', emoji: '🌶️',
          calories: 380, proteinGrams: 24, carbsGrams: 18, fatsGrams: 24, servingGrams: 160),
      StoreMealItem(id: 'kfc6', name: 'Regular Fries', category: 'Sides', emoji: '🍟',
          calories: 290, proteinGrams: 4, carbsGrams: 38, fatsGrams: 14, servingGrams: 120),
      StoreMealItem(id: 'kfc7', name: 'Coleslaw', category: 'Sides', emoji: '🥗',
          calories: 170, proteinGrams: 1, carbsGrams: 17, fatsGrams: 11, servingGrams: 130),
      StoreMealItem(id: 'kfc8', name: 'Corn on the Cob', category: 'Sides', emoji: '🌽',
          calories: 150, proteinGrams: 5, carbsGrams: 26, fatsGrams: 5, servingGrams: 120),
      StoreMealItem(id: 'kfc9', name: 'Pepsi (Regular)', category: 'Drinks', emoji: '🥤',
          calories: 200, proteinGrams: 0, carbsGrams: 54, fatsGrams: 0, servingGrams: 400),
    ],
  );

  static const _subway = Store(
    id: 'subway',
    name: 'Subway',
    emoji: '🥖',
    type: 'Sandwiches',
    menu: [
      StoreMealItem(id: 'sub1', name: '6" Turkey Breast', category: 'Subs', emoji: '🥖',
          calories: 280, proteinGrams: 18, carbsGrams: 46, fatsGrams: 4, servingGrams: 230),
      StoreMealItem(id: 'sub2', name: '6" Chicken Teriyaki', category: 'Subs', emoji: '🥖',
          calories: 370, proteinGrams: 26, carbsGrams: 51, fatsGrams: 5, servingGrams: 260),
      StoreMealItem(id: 'sub3', name: '6" Steak & Cheese', category: 'Subs', emoji: '🥖',
          calories: 380, proteinGrams: 26, carbsGrams: 47, fatsGrams: 9, servingGrams: 255),
      StoreMealItem(id: 'sub4', name: '6" Veggie Delight', category: 'Subs', emoji: '🥗',
          calories: 230, proteinGrams: 9, carbsGrams: 44, fatsGrams: 3, servingGrams: 220),
      StoreMealItem(id: 'sub5', name: '6" Tuna', category: 'Subs', emoji: '🐟',
          calories: 480, proteinGrams: 22, carbsGrams: 45, fatsGrams: 21, servingGrams: 255),
      StoreMealItem(id: 'sub6', name: 'Footlong Turkey', category: 'Subs', emoji: '🥖',
          calories: 560, proteinGrams: 36, carbsGrams: 92, fatsGrams: 8, servingGrams: 460),
      StoreMealItem(id: 'sub7', name: 'Rotisserie Chicken Salad Bowl', category: 'Salads', emoji: '🥗',
          calories: 270, proteinGrams: 29, carbsGrams: 16, fatsGrams: 8, servingGrams: 350),
      StoreMealItem(id: 'sub8', name: 'Chocolate Chip Cookie', category: 'Desserts', emoji: '🍪',
          calories: 220, proteinGrams: 3, carbsGrams: 30, fatsGrams: 10, servingGrams: 45),
    ],
  );

  static const _pizzaHut = Store(
    id: 'pizza_hut',
    name: 'Pizza Hut',
    emoji: '🍕',
    type: 'Pizza',
    menu: [
      StoreMealItem(id: 'ph1', name: 'Margherita (slice)', category: 'Pizzas', emoji: '🍕',
          calories: 230, proteinGrams: 10, carbsGrams: 28, fatsGrams: 8, servingGrams: 100),
      StoreMealItem(id: 'ph2', name: 'Pepperoni (slice)', category: 'Pizzas', emoji: '🍕',
          calories: 290, proteinGrams: 13, carbsGrams: 28, fatsGrams: 14, servingGrams: 110),
      StoreMealItem(id: 'ph3', name: 'BBQ Chicken (slice)', category: 'Pizzas', emoji: '🍕',
          calories: 260, proteinGrams: 15, carbsGrams: 30, fatsGrams: 9, servingGrams: 108),
      StoreMealItem(id: 'ph4', name: 'Veggie Supreme (slice)', category: 'Pizzas', emoji: '🍕',
          calories: 210, proteinGrams: 9, carbsGrams: 27, fatsGrams: 7, servingGrams: 100),
      StoreMealItem(id: 'ph5', name: 'Garlic Bread', category: 'Sides', emoji: '🥖',
          calories: 180, proteinGrams: 4, carbsGrams: 28, fatsGrams: 6, servingGrams: 80),
      StoreMealItem(id: 'ph6', name: 'Chicken Wings 6 pc', category: 'Sides', emoji: '🍗',
          calories: 420, proteinGrams: 30, carbsGrams: 8, fatsGrams: 30, servingGrams: 200),
      StoreMealItem(id: 'ph7', name: 'Caesar Salad', category: 'Salads', emoji: '🥗',
          calories: 200, proteinGrams: 12, carbsGrams: 10, fatsGrams: 13, servingGrams: 200),
    ],
  );

  static const _goodys = Store(
    id: 'goodys',
    name: "Goody's",
    emoji: '🍔',
    type: 'Fast Food',
    menu: [
      StoreMealItem(id: 'gd1', name: "Goody's Burger", category: 'Burgers', emoji: '🍔',
          calories: 530, proteinGrams: 28, carbsGrams: 44, fatsGrams: 26, servingGrams: 215),
      StoreMealItem(id: 'gd2', name: 'Chicken Crispy Burger', category: 'Burgers', emoji: '🍔',
          calories: 460, proteinGrams: 25, carbsGrams: 43, fatsGrams: 21, servingGrams: 200),
      StoreMealItem(id: 'gd3', name: 'Double Beef Burger', category: 'Burgers', emoji: '🍔',
          calories: 620, proteinGrams: 38, carbsGrams: 42, fatsGrams: 33, servingGrams: 250),
      StoreMealItem(id: 'gd4', name: 'Chicken Wrap', category: 'Wraps', emoji: '🌯',
          calories: 410, proteinGrams: 30, carbsGrams: 40, fatsGrams: 14, servingGrams: 230),
      StoreMealItem(id: 'gd5', name: 'Greek Salad', category: 'Salads', emoji: '🥗',
          calories: 190, proteinGrams: 6, carbsGrams: 12, fatsGrams: 14, servingGrams: 250),
      StoreMealItem(id: 'gd6', name: 'Regular Fries', category: 'Sides', emoji: '🍟',
          calories: 330, proteinGrams: 4, carbsGrams: 43, fatsGrams: 16, servingGrams: 120),
      StoreMealItem(id: 'gd7', name: 'Onion Rings', category: 'Sides', emoji: '🧅',
          calories: 290, proteinGrams: 4, carbsGrams: 38, fatsGrams: 14, servingGrams: 110),
      StoreMealItem(id: 'gd8', name: 'Frozen Lemonade', category: 'Drinks', emoji: '🍋',
          calories: 160, proteinGrams: 0, carbsGrams: 42, fatsGrams: 0, servingGrams: 350),
    ],
  );

  static const _everest = Store(
    id: 'everest',
    name: 'Everest',
    emoji: '🥪',
    type: 'Café & Sandwiches',
    menu: [
      StoreMealItem(id: 'ev1', name: 'Club Toast', category: 'Toasts', emoji: '🥪',
          calories: 430, proteinGrams: 24, carbsGrams: 40, fatsGrams: 18, servingGrams: 200),
      StoreMealItem(id: 'ev2', name: 'Tost Tyri-Zampon', category: 'Toasts', emoji: '🥪',
          calories: 390, proteinGrams: 20, carbsGrams: 38, fatsGrams: 16, servingGrams: 180),
      StoreMealItem(id: 'ev3', name: 'Chicken Wrap', category: 'Wraps', emoji: '🌯',
          calories: 370, proteinGrams: 28, carbsGrams: 38, fatsGrams: 11, servingGrams: 220),
      StoreMealItem(id: 'ev4', name: 'Spanakopita', category: 'Pastries', emoji: '🥧',
          calories: 290, proteinGrams: 8, carbsGrams: 30, fatsGrams: 15, servingGrams: 130),
      StoreMealItem(id: 'ev5', name: 'Tiropita', category: 'Pastries', emoji: '🥧',
          calories: 310, proteinGrams: 10, carbsGrams: 28, fatsGrams: 17, servingGrams: 130),
      StoreMealItem(id: 'ev6', name: 'Bougatsa', category: 'Pastries', emoji: '🥐',
          calories: 340, proteinGrams: 9, carbsGrams: 44, fatsGrams: 14, servingGrams: 150),
      StoreMealItem(id: 'ev7', name: 'Frappe (medium)', category: 'Drinks', emoji: '☕',
          calories: 90, proteinGrams: 2, carbsGrams: 12, fatsGrams: 3, servingGrams: 250),
      StoreMealItem(id: 'ev8', name: 'Fresh Orange Juice', category: 'Drinks', emoji: '🍊',
          calories: 120, proteinGrams: 2, carbsGrams: 28, fatsGrams: 0, servingGrams: 300),
    ],
  );

  static const _pizzaFan = Store(
    id: 'pizza_fan',
    name: 'Pizza Fan',
    emoji: '🍕',
    type: 'Pizza',
    menu: [
      StoreMealItem(id: 'pf1', name: 'Margarita (slice)', category: 'Pizzas', emoji: '🍕',
          calories: 220, proteinGrams: 9, carbsGrams: 27, fatsGrams: 7, servingGrams: 95),
      StoreMealItem(id: 'pf2', name: 'Greek Special (slice)', category: 'Pizzas', emoji: '🍕',
          calories: 250, proteinGrams: 11, carbsGrams: 27, fatsGrams: 11, servingGrams: 105),
      StoreMealItem(id: 'pf3', name: 'Chicken BBQ (slice)', category: 'Pizzas', emoji: '🍕',
          calories: 265, proteinGrams: 14, carbsGrams: 29, fatsGrams: 10, servingGrams: 108),
      StoreMealItem(id: 'pf4', name: 'Spicy Pepperoni (slice)', category: 'Pizzas', emoji: '🌶️',
          calories: 285, proteinGrams: 13, carbsGrams: 27, fatsGrams: 14, servingGrams: 110),
      StoreMealItem(id: 'pf5', name: 'Garlic Bread with Cheese', category: 'Sides', emoji: '🥖',
          calories: 200, proteinGrams: 6, carbsGrams: 26, fatsGrams: 9, servingGrams: 90),
      StoreMealItem(id: 'pf6', name: 'Chicken Wings 6 pc', category: 'Sides', emoji: '🍗',
          calories: 400, proteinGrams: 28, carbsGrams: 6, fatsGrams: 30, servingGrams: 190),
    ],
  );

  static const _nandos = Store(
    id: 'nandos',
    name: "Nando's",
    emoji: '🔥',
    type: 'Chicken',
    menu: [
      StoreMealItem(id: 'nan1', name: '1/4 Chicken (Breast)', category: 'Chicken', emoji: '🍗',
          calories: 325, proteinGrams: 38, carbsGrams: 1, fatsGrams: 18, servingGrams: 170),
      StoreMealItem(id: 'nan2', name: '1/2 Chicken', category: 'Chicken', emoji: '🍗',
          calories: 640, proteinGrams: 74, carbsGrams: 2, fatsGrams: 36, servingGrams: 340),
      StoreMealItem(id: 'nan3', name: 'Chicken Pitta', category: 'Wraps', emoji: '🌯',
          calories: 430, proteinGrams: 34, carbsGrams: 42, fatsGrams: 13, servingGrams: 240),
      StoreMealItem(id: 'nan4', name: 'Butterfly Chicken Burger', category: 'Burgers', emoji: '🍔',
          calories: 480, proteinGrams: 38, carbsGrams: 43, fatsGrams: 15, servingGrams: 230),
      StoreMealItem(id: 'nan5', name: 'Peri-Peri Chips', category: 'Sides', emoji: '🍟',
          calories: 360, proteinGrams: 5, carbsGrams: 46, fatsGrams: 18, servingGrams: 150),
      StoreMealItem(id: 'nan6', name: 'Corn on the Cob', category: 'Sides', emoji: '🌽',
          calories: 130, proteinGrams: 4, carbsGrams: 22, fatsGrams: 4, servingGrams: 110),
      StoreMealItem(id: 'nan7', name: 'Coleslaw', category: 'Sides', emoji: '🥗',
          calories: 180, proteinGrams: 2, carbsGrams: 18, fatsGrams: 11, servingGrams: 130),
    ],
  );

  static const _burgerKing = Store(
    id: 'burger_king',
    name: 'Burger King',
    emoji: '👑',
    type: 'Fast Food',
    menu: [
      StoreMealItem(id: 'bk1', name: 'Whopper', category: 'Burgers', emoji: '🍔',
          calories: 660, proteinGrams: 28, carbsGrams: 49, fatsGrams: 40, servingGrams: 280),
      StoreMealItem(id: 'bk2', name: 'Whopper Jr.', category: 'Burgers', emoji: '🍔',
          calories: 380, proteinGrams: 17, carbsGrams: 32, fatsGrams: 22, servingGrams: 165),
      StoreMealItem(id: 'bk3', name: 'Crispy Chicken Sandwich', category: 'Chicken', emoji: '🍗',
          calories: 490, proteinGrams: 25, carbsGrams: 50, fatsGrams: 22, servingGrams: 230),
      StoreMealItem(id: 'bk4', name: 'Chicken Nuggets 8 pc', category: 'Chicken', emoji: '🍗',
          calories: 360, proteinGrams: 20, carbsGrams: 24, fatsGrams: 20, servingGrams: 144),
      StoreMealItem(id: 'bk5', name: 'Medium Onion Rings', category: 'Sides', emoji: '🧅',
          calories: 320, proteinGrams: 4, carbsGrams: 40, fatsGrams: 16, servingGrams: 120),
      StoreMealItem(id: 'bk6', name: 'Medium Fries', category: 'Sides', emoji: '🍟',
          calories: 380, proteinGrams: 4, carbsGrams: 50, fatsGrams: 18, servingGrams: 130),
    ],
  );

  static const _quick = Store(
    id: 'quick',
    name: 'Quick',
    emoji: '🍔',
    type: 'Fast Food',
    menu: [
      StoreMealItem(id: 'qk1', name: 'Giant Burger', category: 'Burgers', emoji: '🍔',
          calories: 590, proteinGrams: 30, carbsGrams: 46, fatsGrams: 32, servingGrams: 240),
      StoreMealItem(id: 'qk2', name: 'Bacon Double Cheese', category: 'Burgers', emoji: '🍔',
          calories: 620, proteinGrams: 36, carbsGrams: 42, fatsGrams: 36, servingGrams: 250),
      StoreMealItem(id: 'qk3', name: 'Crispy Chicken', category: 'Chicken', emoji: '🍗',
          calories: 450, proteinGrams: 24, carbsGrams: 48, fatsGrams: 19, servingGrams: 210),
      StoreMealItem(id: 'qk4', name: 'Frites Moyennes', category: 'Sides', emoji: '🍟',
          calories: 340, proteinGrams: 4, carbsGrams: 45, fatsGrams: 16, servingGrams: 120),
      StoreMealItem(id: 'qk5', name: 'Salade Verte', category: 'Salads', emoji: '🥗',
          calories: 110, proteinGrams: 3, carbsGrams: 8, fatsGrams: 7, servingGrams: 180),
    ],
  );

  static const _oldWildWest = Store(
    id: 'old_wild_west',
    name: 'Old Wild West',
    emoji: '🤠',
    type: 'BBQ & Burgers',
    menu: [
      StoreMealItem(id: 'oww1', name: 'Classic Bacon Cheeseburger', category: 'Burgers', emoji: '🍔',
          calories: 580, proteinGrams: 32, carbsGrams: 44, fatsGrams: 30, servingGrams: 240),
      StoreMealItem(id: 'oww2', name: 'BBQ Ribs (half rack)', category: 'BBQ', emoji: '🍖',
          calories: 720, proteinGrams: 48, carbsGrams: 18, fatsGrams: 52, servingGrams: 380),
      StoreMealItem(id: 'oww3', name: 'Country Chicken', category: 'Chicken', emoji: '🍗',
          calories: 480, proteinGrams: 36, carbsGrams: 28, fatsGrams: 24, servingGrams: 260),
      StoreMealItem(id: 'oww4', name: 'Loaded Nachos', category: 'Sides', emoji: '🧀',
          calories: 540, proteinGrams: 14, carbsGrams: 52, fatsGrams: 30, servingGrams: 280),
      StoreMealItem(id: 'oww5', name: 'Caesar Salad', category: 'Salads', emoji: '🥗',
          calories: 280, proteinGrams: 18, carbsGrams: 14, fatsGrams: 18, servingGrams: 280),
    ],
  );

  static const _telepizza = Store(
    id: 'telepizza',
    name: 'Telepizza',
    emoji: '🍕',
    type: 'Pizza',
    menu: [
      StoreMealItem(id: 'tp1', name: 'Margarita (slice)', category: 'Pizzas', emoji: '🍕',
          calories: 215, proteinGrams: 9, carbsGrams: 26, fatsGrams: 7, servingGrams: 95),
      StoreMealItem(id: 'tp2', name: 'Barbacoa Chicken (slice)', category: 'Pizzas', emoji: '🍕',
          calories: 255, proteinGrams: 13, carbsGrams: 28, fatsGrams: 10, servingGrams: 108),
      StoreMealItem(id: 'tp3', name: 'Cuatro Quesos (slice)', category: 'Pizzas', emoji: '🧀',
          calories: 280, proteinGrams: 14, carbsGrams: 26, fatsGrams: 13, servingGrams: 108),
      StoreMealItem(id: 'tp4', name: 'Pan de Ajo', category: 'Sides', emoji: '🥖',
          calories: 190, proteinGrams: 5, carbsGrams: 27, fatsGrams: 7, servingGrams: 85),
      StoreMealItem(id: 'tp5', name: 'Alitas de Pollo', category: 'Sides', emoji: '🍗',
          calories: 380, proteinGrams: 26, carbsGrams: 8, fatsGrams: 28, servingGrams: 180),
    ],
  );


  static const _greekStores = [_mcdonalds, _kfc, _goodys, _everest, _pizzaFan];
  static const _cyprusStores = [_mcdonalds, _kfc, _pizzaHut, _nandos, _subway];
  static const _ukStores = [_mcdonalds, _kfc, _nandos, _subway, _pizzaHut, _burgerKing];
  static const _germanStores = [_mcdonalds, _kfc, _subway, _burgerKing, _pizzaHut];
  static const _frenchStores = [_mcdonalds, _kfc, _quick, _subway, _pizzaHut];
  static const _italianStores = [_mcdonalds, _kfc, _oldWildWest, _subway, _pizzaHut];
  static const _spanishStores = [_mcdonalds, _kfc, _telepizza, _subway, _burgerKing];
  static const _genericStores = [_mcdonalds, _kfc, _subway, _pizzaHut, _burgerKing];
}