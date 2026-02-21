import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/profile/business_information/filter_description_sheet/filter_description_sheet_widget.dart';
import '/profile/contact_details/contact_detail/contact_detail_widget.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import 'business_information_widget.dart' show BusinessInformationWidget;
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BusinessInformationModel
    extends FlutterFlowModel<BusinessInformationWidget> {
  ///  Local state fields for this page.

  int? numberOfFilterButtons;

  Color? statuscolor;

  double? businessFeatureButtonHeight;

  int? numberOfPymentButtons;

  double? paymentOptionsWidgetHeight;

  DateTime? pageStartTime;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - determineStatusAndColor] action in BusinessInformation widget.
  String? currentStatus;
  // Stores action output result for [Custom Action - getFiltersWithUpdate] action in BusinessInformation widget.
  bool? filters;
  // State field(s) for GoogleMap widget.
  LatLng? googleMapsCenter;
  final googleMapsController = Completer<GoogleMapController>();
  // State field(s) for HoursAndContact widget.
  late ExpandableController hoursAndContactExpandableController;

  // Model for ContactDetail component.
  late ContactDetailModel contactDetailModel;

  @override
  void initState(BuildContext context) {
    contactDetailModel = createModel(context, () => ContactDetailModel());
  }

  @override
  void dispose() {
    hoursAndContactExpandableController.dispose();
    contactDetailModel.dispose();
  }
}
