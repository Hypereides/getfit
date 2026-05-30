import 'store_meal_item.dart';

class Store {
  final String id;
  final String name;
  final String emoji;
  final String type;
  final List<StoreMealItem> menu;

  const Store({
    required this.id,
    required this.name,
    required this.emoji,
    required this.type,
    required this.menu,
  });

  List<String> get categories =>
      menu.map((i) => i.category).toSet().toList();
}