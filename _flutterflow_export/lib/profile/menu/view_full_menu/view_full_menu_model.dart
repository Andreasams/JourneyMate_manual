import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/profile/menu/category_description_sheet/category_description_sheet_widget.dart';
import '/profile/menu/item_bottom_sheet/item_bottom_sheet_widget.dart';
import '/profile/menu/package_bottom_sheet/package_bottom_sheet_widget.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import 'view_full_menu_widget.dart' show ViewFullMenuWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ViewFullMenuModel extends FlutterFlowModel<ViewFullMenuWidget> {
  ///  Local state fields for this page.

  bool showFilters = false;

  int? selectedDietaryPreference;

  List<int> selectedAllergies = [];
  void addToSelectedAllergies(int item) => selectedAllergies.add(item);
  void removeFromSelectedAllergies(int item) => selectedAllergies.remove(item);
  void removeAtIndexFromSelectedAllergies(int index) =>
      selectedAllergies.removeAt(index);
  void insertAtIndexInSelectedAllergies(int index, int item) =>
      selectedAllergies.insert(index, item);
  void updateSelectedAllergiesAtIndex(int index, Function(int) updateFn) =>
      selectedAllergies[index] = updateFn(selectedAllergies[index]);

  int numberOfCategoryRows = 2;

  dynamic visibleSelection;

  DateTime? pageStartTime;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
