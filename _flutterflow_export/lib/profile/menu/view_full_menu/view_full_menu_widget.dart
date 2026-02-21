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
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'view_full_menu_model.dart';
export 'view_full_menu_model.dart';

class ViewFullMenuWidget extends StatefulWidget {
  const ViewFullMenuWidget({super.key});

  static String routeName = 'ViewFullMenu';
  static String routePath = 'viewFullMenu';

  @override
  State<ViewFullMenuWidget> createState() => _ViewFullMenuWidgetState();
}

class _ViewFullMenuWidgetState extends State<ViewFullMenuWidget> {
  late ViewFullMenuModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ViewFullMenuModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.pageStartTime = getCurrentTimestamp;
      safeSetState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    // On page dispose action.
    () async {
      await actions.trackAnalyticsEvent(
        'page_viewed',
        <String, String>{
          'pageName': 'viewFullMenu',
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
        title: 'ViewFullMenu',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            appBar: AppBar(
              backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
              automaticallyImplyLeading: false,
              leading: FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 30.0,
                borderWidth: 1.0,
                buttonSize: 60.0,
                icon: Icon(
                  Icons.arrow_back_ios_sharp,
                  color: FlutterFlowTheme.of(context).primaryText,
                  size: 30.0,
                ),
                onPressed: () async {
                  await actions.markUserEngaged();
                  context.safePop();
                },
              ),
              title: Text(
                getJsonField(
                  FFAppState().mostRecentlyViewedBusiness,
                  r'''$.businessInfo.business_name''',
                ).toString(),
                style: FlutterFlowTheme.of(context).titleLarge.override(
                      fontFamily: FlutterFlowTheme.of(context).titleLargeFamily,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.normal,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).titleLargeIsCustom,
                    ),
              ),
              actions: [],
              centerTitle: true,
              elevation: 0.0,
            ),
            body: SafeArea(
              top: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 4.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  FFLocalizations.of(context).getText(
                                    'foeokmwh' /* Menu */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .titleLarge
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleLargeFamily,
                                        fontSize: 20.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.normal,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleLargeIsCustom,
                                      ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      FFLocalizations.of(context).getText(
                                        'sgpknl00' /* Last brought up to date on  */,
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodySmallFamily,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w300,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodySmallIsCustom,
                                          ),
                                    ),
                                    Text(
                                      valueOrDefault<String>(
                                        functions.formatLocalizedDate(
                                            getJsonField(
                                              FFAppState()
                                                  .mostRecentlyViewedBusiness,
                                              r'''$.businessInfo.last_reviewed_at''',
                                            ).toString(),
                                            FFLocalizations.of(context)
                                                .languageCode),
                                        'missing date',
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodySmallFamily,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w300,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodySmallIsCustom,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (((FFAppState().selectedDietaryPreferenceId !=
                                          null) &&
                                      (FFAppState()
                                              .selectedDietaryPreferenceId >
                                          0)) ||
                                  (FFAppState()
                                      .selectedDietaryRestrictionId
                                      .isNotEmpty) ||
                                  (FFAppState().excludedAllergyIds.isNotEmpty))
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 4.0),
                                  child: Text(
                                    valueOrDefault<String>(
                                      functions.generateFilterSummary(
                                          FFAppState().visibleItemCount,
                                          FFAppState()
                                              .selectedDietaryPreferenceId,
                                          FFAppState()
                                              .excludedAllergyIds
                                              .toList(),
                                          FFLocalizations.of(context)
                                              .languageCode,
                                          FFAppState().translationsCache,
                                          FFAppState()
                                              .selectedDietaryRestrictionId
                                              .toList()),
                                      'Showing items',
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMediumFamily,
                                          letterSpacing: 0.0,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodyMediumIsCustom,
                                        ),
                                  ),
                                ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 6.0),
                                child: Builder(
                                  builder: (context) {
                                    if (_model.showFilters) {
                                      return InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          unawaited(
                                            () async {
                                              await actions.markUserEngaged();
                                            }(),
                                          );
                                          _model.showFilters = false;
                                          safeSetState(() {});
                                        },
                                        child: Text(
                                          FFLocalizations.of(context).getText(
                                            '1smig27j' /* Hide filters */,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyLarge
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyLargeFamily,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.normal,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .bodyLargeIsCustom,
                                              ),
                                        ),
                                      );
                                    } else {
                                      return InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          unawaited(
                                            () async {
                                              await actions.markUserEngaged();
                                            }(),
                                          );
                                          _model.showFilters = true;
                                          safeSetState(() {});
                                        },
                                        child: Text(
                                          FFLocalizations.of(context).getText(
                                            'bwvizajd' /* Show filters */,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyLarge
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyLargeFamily,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.normal,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .bodyLargeIsCustom,
                                              ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                              if (_model.showFilters)
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 6.0, 0.0, 12.0),
                                  child: Container(
                                    width: double.infinity,
                                    height: valueOrDefault<double>(
                                      FFAppState().isBoldTextEnabled
                                          ? 385.0
                                          : 350.0,
                                      340.0,
                                    ),
                                    child: custom_widgets.UnifiedFiltersWidget(
                                      width: double.infinity,
                                      height: valueOrDefault<double>(
                                        FFAppState().isBoldTextEnabled
                                            ? 385.0
                                            : 350.0,
                                        340.0,
                                      ),
                                      businessId: getJsonField(
                                        FFAppState().mostRecentlyViewedBusiness,
                                        r'''$.businessInfo.business_id''',
                                      ),
                                      onFiltersChanged: () async {
                                        safeSetState(() {});
                                      },
                                      onVisibleItemCountChanged: (count) async {
                                        FFAppState().visibleItemCount = count;
                                        safeSetState(() {});
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0,
                                valueOrDefault<double>(
                                  FFAppState().isBoldTextEnabled ? 12.0 : 8.0,
                                  0.0,
                                ),
                                0.0,
                                valueOrDefault<double>(
                                  FFAppState().isBoldTextEnabled ? 18.0 : 12.0,
                                  0.0,
                                )),
                            child: Container(
                              width: double.infinity,
                              height: _model.numberOfCategoryRows == 1
                                  ? 42.0
                                  : 72.0,
                              child: custom_widgets.MenuCategoriesRows(
                                width: double.infinity,
                                height: _model.numberOfCategoryRows == 1
                                    ? 42.0
                                    : 72.0,
                                businessID: getJsonField(
                                  FFAppState().mostRecentlyViewedBusiness,
                                  r'''$.businessInfo.business_id''',
                                ),
                                apiResult: getJsonField(
                                  FFAppState().mostRecentlyViewedBusiness,
                                  r'''$.menuCategories''',
                                ),
                                languageCode:
                                    FFLocalizations.of(context).languageCode,
                                visibleSelection: _model.visibleSelection,
                                translationsCache:
                                    FFAppState().translationsCache,
                                onCategoryChanged: (categoryID, menuID) async {
                                  FFAppState()
                                          .mostRecentlyViewedBusinessSelectedCategoryID =
                                      categoryID;
                                  FFAppState()
                                          .mostRecentlyViewedBusinessSelectedMenuID =
                                      menuID;
                                  safeSetState(() {});
                                },
                                onNumberOfRows: (numberOfRows) async {
                                  _model.numberOfCategoryRows = numberOfRows;
                                  safeSetState(() {});
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              child: custom_widgets.MenuDishesListView(
                                width: double.infinity,
                                height: double.infinity,
                                originalCurrencyCode: 'DKK',
                                isDynamicHeight: true,
                                onItemTap: (bottomSheetInformation,
                                    isBeverage,
                                    dietaryTypeIds,
                                    allergyIds,
                                    formattedPrice,
                                    hasVariations,
                                    formattedVariationPrice) async {
                                  await showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    context: context,
                                    builder: (context) {
                                      return GestureDetector(
                                        onTap: () {
                                          FocusScope.of(context).unfocus();
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                        },
                                        child: Padding(
                                          padding:
                                              MediaQuery.viewInsetsOf(context),
                                          child: ItemBottomSheetWidget(
                                            itemData: bottomSheetInformation,
                                            businessName: getJsonField(
                                              FFAppState()
                                                  .mostRecentlyViewedBusiness,
                                              r'''$.businessInfo.business_name''',
                                            ).toString(),
                                            hasVariations: hasVariations,
                                            formattedPrice: formattedPrice,
                                            formattedVariationPrice:
                                                formattedVariationPrice,
                                          ),
                                        ),
                                      );
                                    },
                                  ).then((value) => safeSetState(() {}));
                                },
                                onPackageTap: (packageData) async {
                                  await showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    enableDrag: false,
                                    context: context,
                                    builder: (context) {
                                      return GestureDetector(
                                        onTap: () {
                                          FocusScope.of(context).unfocus();
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                        },
                                        child: Padding(
                                          padding:
                                              MediaQuery.viewInsetsOf(context),
                                          child: PackageBottomSheetWidget(
                                            packageData: packageData,
                                            packageId: getJsonField(
                                              packageData,
                                              r'''$.package_id''',
                                            ),
                                            businessName: getJsonField(
                                              FFAppState()
                                                  .mostRecentlyViewedBusiness,
                                              r'''$.businessInfo.business_name''',
                                            ).toString(),
                                          ),
                                        ),
                                      );
                                    },
                                  ).then((value) => safeSetState(() {}));
                                },
                                onVisibleCategoryChanged:
                                    (selectionData) async {
                                  _model.visibleSelection = selectionData;
                                  safeSetState(() {});
                                },
                                onCategoryDescriptionTap: (categoryData) async {
                                  await showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    context: context,
                                    builder: (context) {
                                      return GestureDetector(
                                        onTap: () {
                                          FocusScope.of(context).unfocus();
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                        },
                                        child: Padding(
                                          padding:
                                              MediaQuery.viewInsetsOf(context),
                                          child: CategoryDescriptionSheetWidget(
                                            categoryInformation: categoryData,
                                          ),
                                        ),
                                      );
                                    },
                                  ).then((value) => safeSetState(() {}));
                                },
                              ),
                            ),
                          ),
                        ].addToStart(SizedBox(height: 4.0)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
