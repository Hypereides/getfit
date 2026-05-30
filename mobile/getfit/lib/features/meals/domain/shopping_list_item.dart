class ShoppingListItem {
  final String id;
  final String name;
  final double amount;
  final String unit;
  final bool isChecked;

  const ShoppingListItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.unit,
    this.isChecked = false,
  });

  ShoppingListItem copyWith({bool? isChecked, double? amount}) =>
      ShoppingListItem(
        id: id,
        name: name,
        amount: amount ?? this.amount,
        unit: unit,
        isChecked: isChecked ?? this.isChecked,
      );
}