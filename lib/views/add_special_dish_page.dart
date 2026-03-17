import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_tetholiday/data/database/app_database.dart';
import 'package:project_tetholiday/models/recipe_ingredient.dart';
import 'package:project_tetholiday/views/market_list_page.dart';

/// Màn thêm món ăn đặc biệt: tên, dịp, công thức, nguyên liệu.
class AddSpecialDishPage extends StatefulWidget {
  const AddSpecialDishPage({super.key});

  @override
  State<AddSpecialDishPage> createState() => _AddSpecialDishPageState();
}

class _AddSpecialDishPageState extends State<AddSpecialDishPage> {
  static const Color _primary = Color(0xFFEE5B2B);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _timeController = TextEditingController();
  final _levelController = TextEditingController();
  final _instructionsController = TextEditingController();
  Occasion _occasion = Occasion.tet;

  final List<_IngredientRow> _ingredients = [];
  bool _saving = false;

  static const String _placeholderImage =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCuxTgLYeSfEsDiP7ptl27H7LQgOC6egM7M1oT5z5HdjdBbQZSh6hz6IyUBhsOCd6OkvUu8QYGBoXFqjX-HurSWUNZORcd1FG6N-N147ZLcEYkoP5dA2tgzHWcpA5f_a6Epzu0L2790MAZk7yO99UKVdJbB91KS5S2oDiRwhx0bz7h-Uy4-DTpuqrzTs1I-3HjjcJv9EU5ZHD-5iqlRjaziH71tyo7hmSe77yKmHvqTqxNHk-haWkdmxuYSG2XKs3sdGYDUjIbahd-G';

  @override
  void dispose() {
    _nameController.dispose();
    _timeController.dispose();
    _levelController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm ít nhất một nguyên liệu')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final id = await AppDatabase.instance.insertRecipe(
        title: _nameController.text.trim(),
        imageUrl: _placeholderImage,
        time: _timeController.text.trim().isEmpty ? null : _timeController.text.trim(),
        level: _levelController.text.trim().isEmpty ? null : _levelController.text.trim(),
        occasion: _occasion,
        instructions: _instructionsController.text.trim().isEmpty ? null : _instructionsController.text.trim(),
        ingredients: _ingredients
            .map((e) => (
                  name: e.nameController.text.trim(),
                  quantity: e.quantityController.text.trim(),
                  category: e.category,
                  note: e.noteController.text.trim().isEmpty ? null : e.noteController.text.trim(),
                ))
            .toList(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thêm món')));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => MarketListPage(recipeId: id),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add(_IngredientRow(
        nameController: TextEditingController(),
        quantityController: TextEditingController(),
        noteController: TextEditingController(),
        category: MarketCategory.other,
      ));
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients[index].nameController.dispose();
      _ingredients[index].quantityController.dispose();
      _ingredients[index].noteController.dispose();
      _ingredients.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thêm món đặc biệt',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text('Lưu', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: _primary)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên món ăn *',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập tên món' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Occasion>(
              initialValue: _occasion,
              decoration: const InputDecoration(
                labelText: 'Dành cho dịp',
                border: OutlineInputBorder(),
              ),
              items: Occasion.values
                  .map((o) => DropdownMenuItem(value: o, child: Text(o.label)))
                  .toList(),
              onChanged: (v) => setState(() => _occasion = v ?? Occasion.tet),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _timeController,
                    decoration: const InputDecoration(
                      labelText: 'Thời gian (vd: 45p)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _levelController,
                    decoration: const InputDecoration(
                      labelText: 'Độ khó (vd: Dễ)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: 'Công thức (các bước nấu)',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nguyên liệu *',
                  style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _addIngredient,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Thêm'),
                ),
              ],
            ),
            ...List.generate(_ingredients.length, (i) {
              final ing = _ingredients[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: ing.nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Tên nguyên liệu',
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () => _removeIngredient(i),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: ing.quantityController,
                                decoration: const InputDecoration(
                                  labelText: 'Số lượng',
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<MarketCategory>(
                                initialValue: ing.category,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                                items: MarketCategory.values
                                    .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                                    .toList(),
                                onChanged: (v) => setState(() => ing.category = v ?? MarketCategory.other),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: ing.noteController,
                          decoration: const InputDecoration(
                            labelText: 'Ghi chú (tùy chọn)',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            if (_ingredients.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Bấm "Thêm" để thêm nguyên liệu',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _IngredientRow {
  _IngredientRow({
    required this.nameController,
    required this.quantityController,
    required this.noteController,
    required this.category,
  });

  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController noteController;
  MarketCategory category;
}
