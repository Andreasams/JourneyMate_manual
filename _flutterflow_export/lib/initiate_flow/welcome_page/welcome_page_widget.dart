import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'welcome_page_model.dart';
export 'welcome_page_model.dart';

class WelcomePageWidget extends StatefulWidget {
  const WelcomePageWidget({super.key});

  static String routeName = 'WelcomePage';
  static String routePath = 'welcomePage';

  @override
  State<WelcomePageWidget> createState() => _WelcomePageWidgetState();
}

class _WelcomePageWidgetState extends State<WelcomePageWidget> {
  late WelcomePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  LatLng? currentUserLocationValue;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WelcomePageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.pageStartTime = getCurrentTimestamp;
      _model.buttonsMayShow = false;
      await Future.wait([
        Future(() async {
          // get currency code
          _model.userCurrencyCode = await actions.getUserPreference(
            'user_currency_code',
          );
          _model.updateCurrencyWithExchangeRate =
              await actions.updateCurrencyWithExchangeRate(
            FFAppState().userCurrencyCode,
          );
          unawaited(
            () async {
              await actions.checkLocationPermission(
                'welcomepage',
              );
            }(),
          );
        }),
        Future(() async {
          // get language code
          _model.userLanguageCode = await actions.getUserPreference(
            'user_language_code',
          );
          if (_model.userLanguageCode == null ||
              _model.userLanguageCode == '') {
            unawaited(
              () async {
                await actions.saveUserPreference(
                  'user_language_code',
                  'en',
                );
              }(),
            );
            setAppLanguage(context, 'en');
          }
          _model.buttonsMayShow = true;
          safeSetState(() {});
        }),
      ]);
      await Future.wait([
        Future(() async {
          _model.getTranslationsWithUpdate =
              await actions.getTranslationsWithUpdate(
            FFLocalizations.of(context).languageCode,
          );
        }),
        Future(() async {
          unawaited(
            () async {
              _model.getFiltersWithUpdate = await actions.getFiltersWithUpdate(
                FFLocalizations.of(context).languageCode,
              );
            }(),
          );
        }),
      ]);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    // On page dispose action.
    () async {
      await actions.trackAnalyticsEvent(
        'page_viewed',
        <String, String?>{
          'pageName': 'homepage',
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
        title: 'WelcomePage',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: SafeArea(
              top: true,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(12.0, 90.0, 12.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          FFLocalizations.of(context).getText(
                            '6dww9uct' /* Welcome to JourneyMate */,
                          ),
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context)
                              .displayMedium
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .displayMediumFamily,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .displayMediumIsCustom,
                              ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            'assets/images/placefindr_mascot.png',
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ].divide(SizedBox(height: 40.0)),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            FFLocalizations.of(context).getText(
                              'z6e1v2g7' /* Go out, your way.  */,
                            ),
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context)
                                .titleLarge
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .titleLargeFamily,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .titleLargeIsCustom,
                                ),
                          ),
                          Text(
                            FFLocalizations.of(context).getText(
                              '0eehrkgn' /* Discover restaurants, cafés, a... */,
                            ),
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .titleSmallFamily,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .titleSmallIsCustom,
                                ),
                          ),
                        ].divide(SizedBox(height: 8.0)),
                      ),
                    ),
                    if (_model.buttonsMayShow)
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: FFButtonWidget(
                              onPressed: () async {
                                currentUserLocationValue =
                                    await getCurrentUserLocation(
                                        defaultLocation: LatLng(0.0, 0.0));
                                if (_model.userLanguageCode != null &&
                                    _model.userLanguageCode != '') {
                                  _model.homePageContinue =
                                      await SearchCall.call(
                                    cityId: FFAppState().CityID.toString(),
                                    userLocation:
                                        currentUserLocationValue?.toString(),
                                    searchInput: '',
                                    languageCode: FFLocalizations.of(context)
                                        .languageCode,
                                  );

                                  unawaited(
                                    () async {
                                      await actions.markUserEngaged();
                                    }(),
                                  );
                                  unawaited(
                                    () async {
                                      await actions
                                          .generateAndStoreFilterSessionId();
                                    }(),
                                  );
                                  if (FFAppState().locationStatus) {
                                    await Future.wait([
                                      Future(() async {
                                        FFAppState().searchResults = (_model
                                                .homePageContinue?.jsonBody ??
                                            '');
                                        FFAppState().searchResultsCount =
                                            getJsonField(
                                          (_model.homePageContinue?.jsonBody ??
                                              ''),
                                          r'''$.resultCount''',
                                        );
                                      }),
                                      Future(() async {
                                        unawaited(
                                          () async {
                                            await actions.trackAnalyticsEvent(
                                              'page_viewed',
                                              <String, String?>{
                                                'pageName': 'welcomepage',
                                                'durationSeconds': functions
                                                    .getSessionDurationSeconds(
                                                        _model.pageStartTime!)
                                                    .toString(),
                                              },
                                            );
                                          }(),
                                        );
                                      }),
                                    ]);

                                    context
                                        .goNamed(SearchResultsWidget.routeName);
                                  } else {
                                    await Future.wait([
                                      Future(() async {
                                        FFAppState().searchResults = (_model
                                                .homePageContinue?.jsonBody ??
                                            '');
                                        FFAppState().searchResultsCount =
                                            getJsonField(
                                          (_model.homePageContinue?.jsonBody ??
                                              ''),
                                          r'''$.resultCount''',
                                        );
                                      }),
                                      Future(() async {
                                        unawaited(
                                          () async {
                                            await actions.trackAnalyticsEvent(
                                              'page_viewed',
                                              <String, String?>{
                                                'pageName': 'welcomepage',
                                                'durationSeconds': functions
                                                    .getSessionDurationSeconds(
                                                        _model.pageStartTime!)
                                                    .toString(),
                                              },
                                            );
                                          }(),
                                        );
                                      }),
                                    ]);

                                    context
                                        .goNamed(SearchResultsWidget.routeName);
                                  }
                                } else {
                                  unawaited(
                                    () async {
                                      await actions.markUserEngaged();
                                    }(),
                                  );
                                  unawaited(
                                    () async {
                                      await actions.trackAnalyticsEvent(
                                        'page_viewed',
                                        <String, String?>{
                                          'pageName': 'welcomepage',
                                          'durationSeconds': functions
                                              .getSessionDurationSeconds(
                                                  _model.pageStartTime!)
                                              .toString(),
                                        },
                                      );
                                    }(),
                                  );

                                  context.goNamed(
                                      AppSettingsInitiateFlowWidget.routeName);
                                }

                                safeSetState(() {});
                              },
                              text: FFLocalizations.of(context).getText(
                                'd2mrwxr4' /* Continue */,
                              ),
                              options: FFButtonOptions(
                                width: 200.0,
                                height: 40.0,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .titleSmallFamily,
                                      color: Colors.white,
                                      letterSpacing: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .titleSmallIsCustom,
                                    ),
                                elevation: 0.0,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                          if (_model.userLanguageCode == null ||
                              _model.userLanguageCode == '')
                            Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: FFButtonWidget(
                                onPressed: () async {
                                  currentUserLocationValue =
                                      await getCurrentUserLocation(
                                          defaultLocation: LatLng(0.0, 0.0));
                                  await Future.wait([
                                    Future(() async {
                                      unawaited(
                                        () async {
                                          await actions.markUserEngaged();
                                        }(),
                                      );
                                      unawaited(
                                        () async {
                                          await actions.trackAnalyticsEvent(
                                            'page_viewed',
                                            <String, String?>{
                                              'pageName': 'welcomepage',
                                              'durationSeconds': functions
                                                  .getSessionDurationSeconds(
                                                      _model.pageStartTime!)
                                                  .toString(),
                                            },
                                          );
                                        }(),
                                      );
                                      // Set curreny code
                                      unawaited(
                                        () async {
                                          await actions.saveUserPreference(
                                            'user_currency_code',
                                            'DKK',
                                          );
                                        }(),
                                      );
                                      // Set language code
                                      unawaited(
                                        () async {
                                          await actions.saveUserPreference(
                                            'user_language_code',
                                            'da',
                                          );
                                        }(),
                                      );
                                      unawaited(
                                        () async {
                                          await actions
                                              .generateAndStoreFilterSessionId();
                                        }(),
                                      );
                                      setAppLanguage(context, 'da');
                                    }),
                                    Future(() async {
                                      await Future.wait([
                                        Future(() async {
                                          unawaited(
                                            () async {
                                              _model.translationsCache =
                                                  await actions
                                                      .getTranslationsWithUpdate(
                                                'da',
                                              );
                                            }(),
                                          );
                                        }),
                                        Future(() async {
                                          unawaited(
                                            () async {
                                              _model.getFilters = await actions
                                                  .getFiltersWithUpdate(
                                                'da',
                                              );
                                            }(),
                                          );
                                        }),
                                      ]);
                                      if (FFAppState().locationStatus == true) {
                                        _model.homePageContinueInDanish =
                                            await SearchCall.call(
                                          cityId:
                                              FFAppState().CityID.toString(),
                                          searchInput: '',
                                          userLocation: currentUserLocationValue
                                              ?.toString(),
                                          languageCode: 'da',
                                        );

                                        FFAppState().searchResults = (_model
                                                .homePageContinueInDanish
                                                ?.jsonBody ??
                                            '');
                                        FFAppState().searchResultsCount =
                                            getJsonField(
                                          (_model.homePageContinueInDanish
                                                  ?.jsonBody ??
                                              ''),
                                          r'''$.resultCount''',
                                        );
                                        safeSetState(() {});
                                      } else {
                                        await actions
                                            .requestLocationPermissionAndTrack(
                                          'welcomepage',
                                        );
                                        _model.homePageContinueInDanishNoLocation =
                                            await SearchCall.call(
                                          cityId:
                                              FFAppState().CityID.toString(),
                                          searchInput: '',
                                          userLocation: currentUserLocationValue
                                              ?.toString(),
                                          languageCode: 'da',
                                        );

                                        FFAppState().searchResults = (_model
                                                .homePageContinueInDanishNoLocation
                                                ?.jsonBody ??
                                            '');
                                        FFAppState().searchResultsCount =
                                            getJsonField(
                                          (_model.homePageContinueInDanishNoLocation
                                                  ?.jsonBody ??
                                              ''),
                                          r'''$.resultCount''',
                                        );
                                        safeSetState(() {});
                                      }
                                    }),
                                  ]);
                                  await Future.delayed(
                                    Duration(
                                      milliseconds: 100,
                                    ),
                                  );

                                  context
                                      .goNamed(SearchResultsWidget.routeName);

                                  safeSetState(() {});
                                },
                                text: FFLocalizations.of(context).getText(
                                  'cuy6esxb' /* Fortsæt på dansk */,
                                ),
                                options: FFButtonOptions(
                                  width: 200.0,
                                  height: 40.0,
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmallFamily,
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        letterSpacing: 0.0,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleSmallIsCustom,
                                      ),
                                  elevation: 0.0,
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).primary,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                        ].divide(SizedBox(height: 21.0)),
                      ),
                  ].divide(SizedBox(height: 40.0)),
                ),
              ),
            ),
          ),
        ));
  }
}
