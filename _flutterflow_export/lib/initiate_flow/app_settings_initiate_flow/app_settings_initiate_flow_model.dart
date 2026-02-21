import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'app_settings_initiate_flow_widget.dart'
    show AppSettingsInitiateFlowWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AppSettingsInitiateFlowModel
    extends FlutterFlowModel<AppSettingsInitiateFlowWidget> {
  ///  Local state fields for this page.

  bool? languageChosen = false;

  DateTime? pageStartTime;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - checkLocationPermission] action in AppSettingsInitiateFlow widget.
  bool? permissionStatus;
  // Stores action output result for [Backend Call - API (Search)] action in Button widget.
  ApiCallResponse? apiResultsSearchFromInitiateFlow;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
