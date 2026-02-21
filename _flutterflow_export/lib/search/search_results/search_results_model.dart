import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/widgets/nav_bar/nav_bar_widget.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import 'search_results_widget.dart' show SearchResultsWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SearchResultsModel extends FlutterFlowModel<SearchResultsWidget> {
  ///  Local state fields for this page.

  bool openNowSelected = false;

  int? selectedTitleId;

  List<int> activeFilterIds = [];
  void addToActiveFilterIds(int item) => activeFilterIds.add(item);
  void removeFromActiveFilterIds(int item) => activeFilterIds.remove(item);
  void removeAtIndexFromActiveFilterIds(int index) =>
      activeFilterIds.removeAt(index);
  void insertAtIndexInActiveFilterIds(int index, int item) =>
      activeFilterIds.insert(index, item);
  void updateActiveFilterIdsAtIndex(int index, Function(int) updateFn) =>
      activeFilterIds[index] = updateFn(activeFilterIds[index]);

  bool title3selected = false;

  bool title2selected = false;

  bool title1selected = false;

  bool filterOverlayOpen = false;

  int? onLocationFiltersCount;

  int? onTypeFiltersCount;

  int? onPreferencesFiltersCount;

  bool filterMayLoad = false;

  bool searchBarIsFocused = false;

  bool buttonRowMayLoad = false;

  bool trainStationSelected = false;

  int? trainStationID;

  DateTime? pageStartTime;

  int? activeSelectedTitleId;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (Search)] action in Search_Results widget.
  ApiCallResponse? apiResultOnPageLoad;
  // State field(s) for SearchBar widget.
  FocusNode? searchBarFocusNode;
  TextEditingController? searchBarTextController;
  String? Function(BuildContext, String?)? searchBarTextControllerValidator;
  // Model for NavBar component.
  late NavBarModel navBarModel;

  @override
  void initState(BuildContext context) {
    navBarModel = createModel(context, () => NavBarModel());
  }

  @override
  void dispose() {
    searchBarFocusNode?.dispose();
    searchBarTextController?.dispose();

    navBarModel.dispose();
  }
}
