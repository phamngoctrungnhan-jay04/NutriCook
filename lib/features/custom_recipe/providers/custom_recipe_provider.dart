import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../home/models/meal_model.dart';
import '../repositories/custom_recipe_repository.dart';

enum CustomRecipeStatus { idle, loading, success, error }

class CustomRecipeProvider extends ChangeNotifier {
  CustomRecipeProvider({
    required CustomRecipeRepository customRecipeRepository,
    FirebaseAuth? firebaseAuth,
  })  : _repository = customRecipeRepository,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance {
    _authSubscription = _firebaseAuth.authStateChanges().listen((user) {
      if (user != null) {
        _subscribeToRecipes(user.uid);
      } else {
        _reset();
      }
    });
  }

  final CustomRecipeRepository _repository;
  final FirebaseAuth _firebaseAuth;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<List<MealModel>>? _recipesSubscription;

  CustomRecipeStatus _status = CustomRecipeStatus.idle;
  List<MealModel> _recipes = const [];
  String? _errorMessage;

  CustomRecipeStatus get status => _status;
  List<MealModel> get recipes => _recipes;
  String? get errorMessage => _errorMessage;

  bool _isDisposed = false;

  String? get _uid => _firebaseAuth.currentUser?.uid;

  void _subscribeToRecipes(String uid) {
    _recipesSubscription?.cancel();
    Future.microtask(() {
      _status = CustomRecipeStatus.loading;
      notifyListeners();
    });

    _recipesSubscription = _repository.watchCustomRecipes(uid).listen(
      (recipes) {
        _recipes = recipes;
        _status = CustomRecipeStatus.success;
        _errorMessage = null;
        Future.microtask(() {
          notifyListeners();
        });
      },
      onError: (Object error) {
        _status = CustomRecipeStatus.error;
        _errorMessage = 'Failed to load custom recipes.';
        Future.microtask(() {
          notifyListeners();
        });
      },
    );
  }

  Future<bool> saveRecipe(MealModel recipe) async {
    final uid = _uid;
    if (uid == null) return false;
    try {
      await _repository.saveCustomRecipe(uid, recipe);
      return true;
    } catch (e) {
      debugPrint('[CustomRecipeProvider] Failed to save recipe: $e');
      return false;
    }
  }

  Future<bool> deleteRecipe(String idMeal) async {
    final uid = _uid;
    if (uid == null) return false;
    try {
      await _repository.deleteCustomRecipe(uid, idMeal);
      return true;
    } catch (e) {
      debugPrint('[CustomRecipeProvider] Failed to delete recipe: $e');
      return false;
    }
  }

  void _reset() {
    _recipesSubscription?.cancel();
    _recipesSubscription = null;
    _recipes = const [];
    Future.microtask(() {
      _status = CustomRecipeStatus.idle;
      _errorMessage = null;
      notifyListeners();
    });
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _authSubscription?.cancel();
    _recipesSubscription?.cancel();
    super.dispose();
  }
}
