import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/primary_button.dart';
import '../../home/models/meal_model.dart';
import '../providers/custom_recipe_provider.dart';

class AddEditRecipeScreen extends StatefulWidget {
  const AddEditRecipeScreen({super.key, this.idMeal});

  final String? idMeal;

  @override
  State<AddEditRecipeScreen> createState() => _AddEditRecipeScreenState();
}

class _AddEditRecipeScreenState extends State<AddEditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _areaController;
  late final TextEditingController _instructionsController;
  late final TextEditingController _thumbnailController;

  final List<TextEditingController> _ingredientControllers = [];
  final List<TextEditingController> _measureControllers = [];

  bool _isSaving = false;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.idMeal != null;

    _nameController = TextEditingController();
    _categoryController = TextEditingController();
    _areaController = TextEditingController();
    _instructionsController = TextEditingController();
    _thumbnailController = TextEditingController();

    if (_isEdit) {
      // Load pre-existing recipe details from provider
      final provider = context.read<CustomRecipeProvider>();
      final recipe = provider.recipes.firstWhere(
        (r) => r.idMeal == widget.idMeal,
        orElse: () => MealModel(
          idMeal: widget.idMeal!,
          name: '',
          thumbnailUrl: '',
        ),
      );

      _nameController.text = recipe.name;
      _categoryController.text = recipe.category ?? '';
      _areaController.text = recipe.area ?? '';
      _instructionsController.text = recipe.instructions ?? '';
      _thumbnailController.text = recipe.thumbnailUrl;

      for (final ing in recipe.ingredients) {
        _ingredientControllers.add(TextEditingController(text: ing.name));
        _measureControllers.add(TextEditingController(text: ing.measure));
      }
    }

    // Always have at least one ingredient row
    if (_ingredientControllers.isEmpty) {
      _addIngredientRow();
    }
  }

  void _addIngredientRow() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
      _measureControllers.add(TextEditingController());
    });
  }

  void _removeIngredientRow(int index) {
    if (_ingredientControllers.length <= 1) return;
    setState(() {
      _ingredientControllers[index].dispose();
      _measureControllers[index].dispose();
      _ingredientControllers.removeAt(index);
      _measureControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _areaController.dispose();
    _instructionsController.dispose();
    _thumbnailController.dispose();

    for (final c in _ingredientControllers) {
      c.dispose();
    }
    for (final c in _measureControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    // Filter valid ingredients
    final ingredientsList = <MealIngredient>[];
    for (var i = 0; i < _ingredientControllers.length; i++) {
      final name = _ingredientControllers[i].text.trim();
      final measure = _measureControllers[i].text.trim();
      if (name.isNotEmpty) {
        ingredientsList.add(MealIngredient(name: name, measure: measure));
      }
    }

    if (ingredientsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ingredient with a name')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final id = _isEdit
        ? widget.idMeal!
        : 'custom_${DateTime.now().millisecondsSinceEpoch}';

    final thumbnailUrl = _thumbnailController.text.trim().isEmpty
        ? 'https://www.themealdb.com/images/media/meals/ustsqw1468250014.jpg' // clean default meal image
        : _thumbnailController.text.trim();

    final recipe = MealModel(
      idMeal: id,
      name: _nameController.text.trim(),
      thumbnailUrl: thumbnailUrl,
      category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
      area: _areaController.text.trim().isEmpty ? null : _areaController.text.trim(),
      instructions: _instructionsController.text.trim(),
      ingredients: ingredientsList,
    );

    final success = await context.read<CustomRecipeProvider>().saveRecipe(recipe);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save recipe, please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Recipe' : 'Add Recipe'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Recipe Name *',
                hintText: 'e.g. Garlic Butter Prawns',
              ),
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Please enter recipe name' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                hintText: 'e.g. Seafood, Dessert, Beef',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _areaController,
              decoration: const InputDecoration(
                labelText: 'Area/Cuisine',
                hintText: 'e.g. Italian, Vietnamese, French',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _thumbnailController,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                hintText: 'Paste an image URL (optional)',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _instructionsController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Instructions *',
                hintText: 'Enter cooking steps here...',
              ),
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Please enter instructions' : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Ingredients',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _ingredientControllers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _ingredientControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Ingredient ${index + 1}',
                            hintText: 'e.g. Prawns',
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _measureControllers[index],
                          decoration: const InputDecoration(
                            labelText: 'Measure',
                            hintText: 'e.g. 500g, 2 tbsp',
                          ),
                        ),
                      ),
                      if (_ingredientControllers.length > 1)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          color: Colors.red,
                          onPressed: () => _removeIngredientRow(index),
                        ),
                    ],
                  ),
                );
              },
            ),
            TextButton.icon(
              onPressed: _addIngredientRow,
              icon: const Icon(Icons.add),
              label: const Text('Add Ingredient'),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: _isEdit ? 'Save Changes' : 'Create Recipe',
              isLoading: _isSaving,
              onPressed: _handleSave,
            ),
          ],
        ),
      ),
    );
  }
}
