import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'welcome_page_widget.dart' show WelcomePageWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class WelcomePageModel extends FlutterFlowModel<WelcomePageWidget> {
  ///  Local state fields for this page.

  DateTime? pageStartTime;

  bool buttonsMayShow = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - getUserPreference] action in WelcomePage widget.
  String? userCurrencyCode;
  // Stores action output result for [Custom Action - updateCurrencyWithExchangeRate] action in WelcomePage widget.
  bool? updateCurrencyWithExchangeRate;
  // Stores action output result for [Custom Action - getUserPreference] action in WelcomePage widget.
  String? userLanguageCode;
  // Stores action output result for [Custom Action - getTranslationsWithUpdate] action in WelcomePage widget.
  bool? getTranslationsWithUpdate;
  // Stores action output result for [Custom Action - getFiltersWithUpdate] action in WelcomePage widget.
  bool? getFiltersWithUpdate;
  // Stores action output result for [Backend Call - API (Search)] action in ContinueBtn widget.
  ApiCallResponse? homePageContinue;
  // Stores action output result for [Custom Action - getTranslationsWithUpdate] action in ContinueBtnDa widget.
  bool? translationsCache;
  // Stores action output result for [Custom Action - getFiltersWithUpdate] action in ContinueBtnDa widget.
  bool? getFilters;
  // Stores action output result for [Backend Call - API (Search)] action in ContinueBtnDa widget.
  ApiCallResponse? homePageContinueInDanish;
  // Stores action output result for [Backend Call - API (Search)] action in ContinueBtnDa widget.
  ApiCallResponse? homePageContinueInDanishNoLocation;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
