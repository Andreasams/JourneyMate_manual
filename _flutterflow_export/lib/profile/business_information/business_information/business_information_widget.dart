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
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'business_information_model.dart';
export 'business_information_model.dart';

class BusinessInformationWidget extends StatefulWidget {
  const BusinessInformationWidget({
    super.key,
    required this.filterDescriptions,
  });

  final dynamic filterDescriptions;

  static String routeName = 'BusinessInformation';
  static String routePath = 'businessInformation';

  @override
  State<BusinessInformationWidget> createState() =>
      _BusinessInformationWidgetState();
}

class _BusinessInformationWidgetState extends State<BusinessInformationWidget> {
  late BusinessInformationModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool hoursAndContactListenerRegistered = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BusinessInformationModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.pageStartTime = getCurrentTimestamp;
      safeSetState(() {});
      _model.currentStatus = await actions.determineStatusAndColor(
        (color) async {
          _model.statuscolor = color;
          safeSetState(() {});
        },
        FFAppState().openingHours,
        getCurrentTimestamp,
        FFLocalizations.of(context).languageCode,
        FFAppState().translationsCache,
      );
      _model.filters = await actions.getFiltersWithUpdate(
        FFLocalizations.of(context).languageCode,
      );
    });

    _model.hoursAndContactExpandableController =
        ExpandableController(initialExpanded: false)
          ..addListener(() => safeSetState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    // On page dispose action.
    () async {
      await actions.trackAnalyticsEvent(
        'page_viewed',
        <String, String>{
          'pageName': 'businessInformation',
          'durationSeconds': functions
              .getSessionDurationSeconds(_model.pageStartTime!)
              .toString(),
        },
      );
    }();

    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Title(
        title: ':businessName',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            resizeToAvoidBottomInset: false,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(60.0),
              child: AppBar(
                backgroundColor: Colors.white,
                automaticallyImplyLeading: false,
                leading: Align(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: FlutterFlowIconButton(
                    borderColor: Colors.transparent,
                    borderRadius: 30.0,
                    borderWidth: 1.0,
                    buttonSize: 60.0,
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: FlutterFlowTheme.of(context).primaryText,
                      size: 30.0,
                    ),
                    onPressed: () async {
                      await actions.markUserEngaged();
                      context.safePop();
                    },
                  ),
                ),
                title: Text(
                  getJsonField(
                    FFAppState().mostRecentlyViewedBusiness,
                    r'''$.businessInfo.business_name''',
                  ).toString(),
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).titleLargeFamily,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.normal,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).titleLargeIsCustom,
                      ),
                ),
                actions: [],
                centerTitle: true,
              ),
            ),
            body: SafeArea(
              top: true,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                      child: Container(
                        height: 200.0,
                        decoration: BoxDecoration(),
                        child: Builder(builder: (context) {
                          final _googleMapMarker = functions.latLongcombine(
                              getJsonField(
                                FFAppState().mostRecentlyViewedBusiness,
                                r'''$.businessInfo.latitude''',
                              ),
                              getJsonField(
                                FFAppState().mostRecentlyViewedBusiness,
                                r'''$.businessInfo.longitude''',
                              ));
                          return FlutterFlowGoogleMap(
                            controller: _model.googleMapsController,
                            onCameraIdle: (latLng) => safeSetState(
                                () => _model.googleMapsCenter = latLng),
                            initialLocation: _model.googleMapsCenter ??=
                                functions.latLongcombine(
                                    getJsonField(
                                      FFAppState().mostRecentlyViewedBusiness,
                                      r'''$.businessInfo.latitude''',
                                    ),
                                    getJsonField(
                                      FFAppState().mostRecentlyViewedBusiness,
                                      r'''$.businessInfo.longitude''',
                                    )),
                            markers: [
                              FlutterFlowMarker(
                                _googleMapMarker.serialize(),
                                _googleMapMarker,
                                () async {
                                  unawaited(
                                    () async {
                                      await actions.markUserEngaged();
                                    }(),
                                  );
                                },
                              ),
                            ],
                            markerColor: GoogleMarkerColor.red,
                            mapType: MapType.normal,
                            style: GoogleMapStyle.standard,
                            initialZoom: 12.0,
                            allowInteraction: true,
                            allowZoom: true,
                            showZoomControls: false,
                            showLocation: true,
                            showCompass: false,
                            showMapToolbar: false,
                            showTraffic: false,
                            centerMapOnMarkerTap: true,
                          );
                        }),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          12.0, 212.0, 12.0, 2.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(-1.0, 0.0),
                            child: Text(
                              getJsonField(
                                FFAppState().mostRecentlyViewedBusiness,
                                r'''$.businessInfo.business_name''',
                              ).toString(),
                              style: FlutterFlowTheme.of(context)
                                  .headlineSmall
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .headlineSmallFamily,
                                    fontSize: 20.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .headlineSmallIsCustom,
                                  ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Icon(
                                  Icons.circle_rounded,
                                  color: _model.statuscolor,
                                  size: 12.0,
                                ),
                              ),
                              Text(
                                valueOrDefault<String>(
                                  functions.daysDayOpeningHour(
                                      getCurrentTimestamp,
                                      FFAppState().openingHours,
                                      FFLocalizations.of(context).languageCode,
                                      FFAppState().translationsCache),
                                  'e',
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyMediumFamily,
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w300,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodyMediumIsCustom,
                                    ),
                              ),
                            ].divide(SizedBox(width: 4.0)),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 274.0, 0.0, 0.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  12.0, 0.0, 12.0, 0.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (getJsonField(
                                        FFAppState().mostRecentlyViewedBusiness,
                                        r'''$.businessInfo.description''',
                                      ) !=
                                      null)
                                    Align(
                                      alignment:
                                          AlignmentDirectional(-1.0, 0.0),
                                      child: Text(
                                        getJsonField(
                                          FFAppState()
                                              .mostRecentlyViewedBusiness,
                                          r'''$.businessInfo.description''',
                                        ).toString(),
                                        textAlign: TextAlign.start,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              fontSize: 16.0,
                                              letterSpacing: 0.0,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                      ),
                                    ),
                                  Container(
                                    child: Builder(builder: (_) {
                                      if (!hoursAndContactListenerRegistered) {
                                        hoursAndContactListenerRegistered =
                                            true;
                                        _model
                                            .hoursAndContactExpandableController
                                            .addListener(
                                          () async {
                                            unawaited(
                                              () async {
                                                await actions.markUserEngaged();
                                              }(),
                                            );
                                          },
                                        );
                                      }
                                      return Container(
                                        width: double.infinity,
                                        color: Color(0x00000000),
                                        child: ExpandableNotifier(
                                          controller: _model
                                              .hoursAndContactExpandableController,
                                          child: ExpandablePanel(
                                            header: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 0.0, 0.0, 6.0),
                                              child: Text(
                                                FFLocalizations.of(context)
                                                    .getText(
                                                  'c9r4q0c8' /* Hours & contact */,
                                                ),
                                                textAlign: TextAlign.start,
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .titleLarge
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleLargeFamily,
                                                          fontSize: 18.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .titleLargeIsCustom,
                                                        ),
                                              ),
                                            ),
                                            collapsed: Container(),
                                            expanded: Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(),
                                              child: wrapWithModel(
                                                model:
                                                    _model.contactDetailModel,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: ContactDetailWidget(
                                                  street: getJsonField(
                                                    FFAppState()
                                                        .mostRecentlyViewedBusiness,
                                                    r'''$.businessInfo.street''',
                                                  ).toString(),
                                                  businessName: getJsonField(
                                                    FFAppState()
                                                        .mostRecentlyViewedBusiness,
                                                    r'''$.businessInfo.business_name''',
                                                  ).toString(),
                                                  businessID: getJsonField(
                                                    FFAppState()
                                                        .mostRecentlyViewedBusiness,
                                                    r'''$.businessInfo.business_id''',
                                                  ),
                                                  openingHours:
                                                      FFAppState().openingHours,
                                                  cityName: getJsonField(
                                                    FFAppState()
                                                        .mostRecentlyViewedBusiness,
                                                    r'''$.businessInfo.city_name''',
                                                  ).toString(),
                                                  postalCity: getJsonField(
                                                    FFAppState()
                                                        .mostRecentlyViewedBusiness,
                                                    r'''$.businessInfo.postal_city''',
                                                  ).toString(),
                                                  postalCode: getJsonField(
                                                    FFAppState()
                                                        .mostRecentlyViewedBusiness,
                                                    r'''$.businessInfo.postal_code''',
                                                  ).toString(),
                                                  latitude: getJsonField(
                                                    FFAppState()
                                                        .mostRecentlyViewedBusiness,
                                                    r'''$.businessInfo.latitude''',
                                                  ),
                                                  longitude: getJsonField(
                                                    FFAppState()
                                                        .mostRecentlyViewedBusiness,
                                                    r'''$.businessInfo.longitude''',
                                                  ),
                                                  phoneGeneral: getJsonField(
                                                    FFAppState()
                                                        .mostRecentlyViewedBusiness,
                                                    r'''$.businessInfo.general_phone''',
                                                  ).toString(),
                                                  urlWebsite: getJsonField(
                                                    FFAppState()
                                                        .mostRecentlyViewedBusiness,
                                                    r'''$.businessInfo.website_url''',
                                                  ).toString(),
                                                  urlGoogleMaps: getJsonField(
                                                    FFAppState()
                                                        .mostRecentlyViewedBusiness,
                                                    r'''$.businessInfo.google_maps_url''',
                                                  ).toString(),
                                                  urlInstagram: getJsonField(
                                                    FFAppState()
                                                        .mostRecentlyViewedBusiness,
                                                    r'''$.businessInfo.instagram_url''',
                                                  ).toString(),
                                                  urlReservation: getJsonField(
                                                    FFAppState()
                                                        .mostRecentlyViewedBusiness,
                                                    r'''$.businessInfo.reservation_url''',
                                                  ).toString(),
                                                  emailGeneral: getJsonField(
                                                    FFAppState()
                                                        .mostRecentlyViewedBusiness,
                                                    r'''$.businessInfo.general_email''',
                                                  ).toString(),
                                                  emailReservation:
                                                      getJsonField(
                                                    FFAppState()
                                                        .mostRecentlyViewedBusiness,
                                                    r'''$.businessInfo.reservation_url''',
                                                  ).toString(),
                                                  urlFacebook: getJsonField(
                                                    FFAppState()
                                                        .mostRecentlyViewedBusiness,
                                                    r'''$.businessInfo.facebook_url''',
                                                  ).toString(),
                                                ),
                                              ),
                                            ),
                                            theme: ExpandableThemeData(
                                              tapHeaderToExpand: true,
                                              tapBodyToExpand: false,
                                              tapBodyToCollapse: false,
                                              headerAlignment:
                                                  ExpandablePanelHeaderAlignment
                                                      .top,
                                              hasIcon: true,
                                              expandIcon:
                                                  Icons.keyboard_arrow_down,
                                              collapseIcon:
                                                  Icons.keyboard_arrow_up,
                                              iconSize: 24.0,
                                              iconColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              iconPadding: EdgeInsets.fromLTRB(
                                                  0.0, 3.0, 170.0, 0.0),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Align(
                                        alignment:
                                            AlignmentDirectional(-1.0, 0.0),
                                        child: Text(
                                          FFLocalizations.of(context).getText(
                                            '7pk0thnp' /* Features, services & amenities */,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .titleLarge
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .titleLargeFamily,
                                                fontSize: 18.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.normal,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .titleLargeIsCustom,
                                              ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height:
                                            _model.businessFeatureButtonHeight,
                                        child: custom_widgets
                                            .BusinessFeatureButtons(
                                          width: double.infinity,
                                          height: _model
                                              .businessFeatureButtonHeight,
                                          filters: FFAppState()
                                              .filtersForUserLanguage,
                                          filtersUsedForSearch:
                                              FFAppState().filtersUsedForSearch,
                                          filtersOfThisBusiness: FFAppState()
                                              .filtersOfSelectedBusiness,
                                          filterDescriptions:
                                              widget!.filterDescriptions!,
                                          containerWidth:
                                              MediaQuery.sizeOf(context).width,
                                          onInitialCount: (count) async {
                                            _model.numberOfFilterButtons =
                                                count;
                                            safeSetState(() {});
                                          },
                                          onFilterTap: (filterId, filterName,
                                              filterDescription) async {
                                            await showModalBottomSheet(
                                              isScrollControlled: true,
                                              backgroundColor:
                                                  Colors.transparent,
                                              useSafeArea: true,
                                              context: context,
                                              builder: (context) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                    FocusManager
                                                        .instance.primaryFocus
                                                        ?.unfocus();
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        MediaQuery.viewInsetsOf(
                                                            context),
                                                    child:
                                                        FilterDescriptionSheetWidget(
                                                      filterName: filterName,
                                                      filterDescription:
                                                          filterDescription!,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ).then(
                                                (value) => safeSetState(() {}));
                                          },
                                          onHeightCalculated: (height) async {
                                            _model.businessFeatureButtonHeight =
                                                height;
                                            safeSetState(() {});
                                          },
                                        ),
                                      ),
                                    ].divide(SizedBox(height: 4.0)),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 0.0, 12.0),
                                        child: Text(
                                          FFLocalizations.of(context).getText(
                                            'zlgcyzrw' /* Payment options */,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .titleLarge
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .titleLargeFamily,
                                                fontSize: 18.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.normal,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .titleLargeIsCustom,
                                              ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height:
                                            _model.paymentOptionsWidgetHeight,
                                        child:
                                            custom_widgets.PaymentOptionsWidget(
                                          width: double.infinity,
                                          height:
                                              _model.paymentOptionsWidgetHeight,
                                          containerWidth:
                                              MediaQuery.sizeOf(context).width,
                                          filters: FFAppState()
                                              .filtersForUserLanguage,
                                          filtersUsedForSearch:
                                              FFAppState().filtersUsedForSearch,
                                          filtersOfThisBusiness: FFAppState()
                                              .filtersOfSelectedBusiness,
                                          onInitialCount: (count) async {
                                            _model.numberOfPymentButtons =
                                                count;
                                            safeSetState(() {});
                                          },
                                          onHeightCalculated: (height) async {
                                            _model.paymentOptionsWidgetHeight =
                                                height;
                                            safeSetState(() {});
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ]
                                    .divide(SizedBox(height: 20.0))
                                    .addToEnd(SizedBox(height: 20.0)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
