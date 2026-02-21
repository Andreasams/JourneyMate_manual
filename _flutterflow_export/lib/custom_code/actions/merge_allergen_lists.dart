// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<List<int>> mergeAllergenLists(
  List<int> currentExcludedAllergens,
  List<int> newImpliedAllergens,
) async {
  /// Merges two allergen lists and removes duplicates.
  ///
  /// Args:
  ///   currentExcludedAllergens: Existing list of excluded allergen IDs
  ///   newImpliedAllergens: New allergen IDs to add from dietary selection
  ///
  /// Returns:
  ///   Combined list with duplicates removed

  final mergedSet = <int>{
    ...currentExcludedAllergens,
    ...newImpliedAllergens,
  };

  return mergedSet.toList();
}
