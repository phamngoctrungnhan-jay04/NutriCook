import 'package:cloud_firestore/cloud_firestore.dart';

import '../../home/models/meal_model.dart';

class CustomRecipeRepository {
  CustomRecipeRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _customRecipesCollection(String uid) =>
      _firestore.collection('users').doc(uid).collection('custom_recipes');

  Stream<List<MealModel>> watchCustomRecipes(String uid) {
    return _customRecipesCollection(uid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MealModel.fromJson(doc.data()))
              .toList(),
        );
  }

  Future<MealModel?> getCustomRecipe(String uid, String idMeal) async {
    final doc = await _customRecipesCollection(uid).doc(idMeal).get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return MealModel.fromJson(data);
  }

  Future<void> saveCustomRecipe(String uid, MealModel recipe) async {
    final docRef = _customRecipesCollection(uid).doc(recipe.idMeal);
    final data = recipe.toFirestoreMap();
    await docRef.set(data);
  }

  Future<void> deleteCustomRecipe(String uid, String idMeal) async {
    await _customRecipesCollection(uid).doc(idMeal).delete();
  }
}
