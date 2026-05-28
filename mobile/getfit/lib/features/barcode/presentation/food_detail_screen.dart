import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/food_product.dart';
import '../state/food_log_controller.dart';

class FoodDetailScreen extends StatefulWidget {
  const FoodDetailScreen({super.key, required this.product});

  final FoodProduct product;

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _qtyCtrl;

  @override
  void initState() {
    super.initState();
    _qtyCtrl = TextEditingController(
      text: widget.product.typicalServingG.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  double get _quantity =>
      double.tryParse(_qtyCtrl.text.trim()) ??
      widget.product.typicalServingG;

  void _confirm() {
    if (!_formKey.currentState!.validate()) return;

    context.read<FoodLogController>().logFood(
          product: widget.product,
          quantityG: _quantity,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2E7D32),
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              '${widget.product.name} added to today\'s log.',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );

    Navigator.of(context).popUntil((route) => route.isFirst || route.settings.name == '/home');
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        suffix: Text(
          widget.product.servingUnit,
          style: TextStyle(
              color: Colors.grey[600], fontWeight: FontWeight.w600),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Food Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.fastfood_rounded,
                          color: Color(0xFF2E7D32),
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p.brand,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Barcode: ${p.barcode}',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey[600]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Nutrition per 100 g / ml',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _NutrientChip(
                        label: 'Calories',
                        value: '${p.caloriesPer100g.toStringAsFixed(0)} kcal',
                        color: Colors.orange,
                      ),
                      _NutrientChip(
                        label: 'Protein',
                        value: '${p.proteinPer100g.toStringAsFixed(1)} g',
                        color: const Color(0xFF2E7D32),
                      ),
                      _NutrientChip(
                        label: 'Carbs',
                        value: '${p.carbsPer100g.toStringAsFixed(1)} g',
                        color: Colors.blue,
                      ),
                      _NutrientChip(
                        label: 'Fat',
                        value: '${p.fatsPer100g.toStringAsFixed(1)} g',
                        color: Colors.purple,
                      ),
                      if (p.fiberPer100g > 0)
                        _NutrientChip(
                          label: 'Fibre',
                          value: '${p.fiberPer100g.toStringAsFixed(1)} g',
                          color: Colors.brown,
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How much did you have?',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Typical serving: ${p.typicalServingG.toStringAsFixed(0)} ${p.servingUnit}',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _qtyCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: _dec(
                        'Quantity (${p.servingUnit})',
                        Icons.scale_rounded,
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Quantity is required';
                        }
                        final val = double.tryParse(v.trim());
                        if (val == null) return 'Enter a valid number';
                        if (val <= 0) return 'Quantity must be greater than 0';
                        if (val > 5000) return 'Quantity seems too high';
                        return null;
                      },
                    ),

                    const SizedBox(height: 28),
                    const Text(
                      'For this quantity',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54),
                    ),
                    const SizedBox(height: 12),
                    _LiveMacroBar(product: p, quantity: _quantity),

                    const SizedBox(height: 28),

                    // Confirm
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _confirm,
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text(
                          'Log This Meal',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveMacroBar extends StatelessWidget {
  const _LiveMacroBar({required this.product, required this.quantity});

  final FoodProduct product;
  final double quantity;

  @override
  Widget build(BuildContext context) {
    final kcal = product.caloriesFor(quantity);
    final prot = product.proteinFor(quantity);
    final carb = product.carbsFor(quantity);
    final fat  = product.fatFor(quantity);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MacroCell(
              label: 'Calories',
              value: '${kcal.toStringAsFixed(0)} kcal',
              color: Colors.orange),
          _MacroCell(
              label: 'Protein',
              value: '${prot.toStringAsFixed(1)} g',
              color: const Color(0xFF2E7D32)),
          _MacroCell(
              label: 'Carbs',
              value: '${carb.toStringAsFixed(1)} g',
              color: Colors.blue),
          _MacroCell(
              label: 'Fat',
              value: '${fat.toStringAsFixed(1)} g',
              color: Colors.purple),
        ],
      ),
    );
  }
}

class _MacroCell extends StatelessWidget {
  const _MacroCell(
      {required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 3),
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }
}

class _NutrientChip extends StatelessWidget {
  const _NutrientChip(
      {required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color)),
        ],
      ),
    );
  }
}