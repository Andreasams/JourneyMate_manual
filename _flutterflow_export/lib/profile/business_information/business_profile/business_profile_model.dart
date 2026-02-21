import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/profile/business_information/filter_description_sheet/filter_description_sheet_widget.dart';
import '/profile/business_information/modal_submit_erroneous_info/modal_submit_erroneous_info_widget.dart';
import '/profile/business_information/profile_top_business_block/profile_top_business_block_widget.dart';
import '/profile/contact_details/contact_detail/contact_detail_widget.dart';
import '/profile/gallery/image_gallery_overlay_swipable/image_gallery_overlay_swipable_widget.dart';
import '/profile/menu/category_description_sheet/category_description_sheet_widget.dart';
import '/profile/menu/item_bottom_sheet/item_bottom_sheet_widget.dart';
import '/profile/menu/package_bottom_sheet/package_bottom_sheet_widget.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'business_profile_widget.dart' show BusinessProfileWidget;
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class BusinessProfileModel extends FlutterFlowModel<BusinessProfileWidget> {
  ///  Local state fields for this page.

  bool hasSecondOpening = true;

  bool isOpen = true;

  int galleryIndex = 0;

  bool showFilters = false;

  bool pageLoadDone = false;

  int? numberOfFilterButtons;

  int numberOfCategoryRows = 2;

  double? businessFeatureButtonHeight;

  double? paymentOptionsWidgetHeight;

  int? numberOfPaymentOptions;

  dynamic visibleSelection;

  DateTime? pageStartTime;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (Menu items)] action in BusinessProfile widget.
  ApiCallResponse? apiResultMenuItems;
  // Stores action output result for [Backend Call - API (BusinessProfile)] action in BusinessProfile widget.
  ApiCallResponse? businessProfileAPI;
  // Stores action output result for [Backend Call - API (FilterDescriptions)] action in BusinessProfile widget.
  ApiCallResponse? filterDescriptions;
  // Model for ProfileTopBusinessBlock component.
  late ProfileTopBusinessBlockModel profileTopBusinessBlockModel;
  // State field(s) for HoursAndContact widget.
  late ExpandableController hoursAndContactExpandableController;

  // Model for ContactDetail component.
  late ContactDetailModel contactDetailModel;

  @override
  void initState(BuildContext context) {
    profileTopBusinessBlockModel =
        createModel(context, () => ProfileTopBusinessBlockModel());
    contactDetailModel = createModel(context, () => ContactDetailModel());
  }

  @override
  void dispose() {
    profileTopBusinessBlockModel.dispose();
    hoursAndContactExpandableController.dispose();
    contactDetailModel.dispose();
  }
}
