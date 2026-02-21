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
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'search_results_model.dart';
export 'search_results_model.dart';

class SearchResultsWidget extends StatefulWidget {
  const SearchResultsWidget({super.key});

  static String routeName = 'Search_Results';
  static String routePath = 'searchResults';

  @override
  State<SearchResultsWidget> createState() => _SearchResultsWidgetState();
}

class _SearchResultsWidgetState extends State<SearchResultsWidget> {
  late SearchResultsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  LatLng? currentUserLocationValue;
  late StreamSubscription<bool> _keyboardVisibilitySubscription;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SearchResultsModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      currentUserLocationValue =
          await getCurrentUserLocation(defaultLocation: LatLng(0.0, 0.0));
      await actions.checkLocationPermission(
        'searchPage',
      );
      if (!FFAppState().locationStatus) {
        await actions.requestLocationPermission(
          'searchPage',
        );
      }
      _model.pageStartTime = getCurrentTimestamp;
      if (FFAppState().searchResults != null) {
        _model.filterMayLoad = true;
        _model.buttonRowMayLoad = true;
        safeSetState(() {});
      } else {
        _model.apiResultOnPageLoad = await SearchCall.call(
          cityId: FFAppState().CityID.toString(),
          searchInput: '',
          userLocation: currentUserLocationValue?.toString(),
          languageCode: FFLocalizations.of(context).languageCode,
        );

        await Future.wait([
          Future(() async {
            FFAppState().searchResults =
                (_model.apiResultOnPageLoad?.jsonBody ?? '');
            safeSetState(() {});
          }),
          Future(() async {
            _model.filterMayLoad = true;
            _model.buttonRowMayLoad = true;
            safeSetState(() {});
          }),
        ]);
      }
    });

    getCurrentUserLocation(defaultLocation: LatLng(0.0, 0.0), cached: true)
        .then((loc) => safeSetState(() => currentUserLocationValue = loc));
    if (!isWeb) {
      _keyboardVisibilitySubscription =
          KeyboardVisibilityController().onChange.listen((bool visible) {
        safeSetState(() {
          _isKeyboardVisible = visible;
        });
      });
    }

    _model.searchBarTextController ??= TextEditingController();
    _model.searchBarFocusNode ??= FocusNode();
    _model.searchBarFocusNode!.addListener(
      () async {
        unawaited(
          () async {
            await actions.markUserEngaged();
          }(),
        );
        _model.filterOverlayOpen = false;
        _model.searchBarIsFocused = !_model.searchBarIsFocused;
        safeSetState(() {});
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    // On page dispose action.
    () async {
      await actions.trackAnalyticsEvent(
        'page_viewed',
        <String, String>{
          'pageName': 'search_results',
          'durationSeconds': functions
              .getSessionDurationSeconds(_model.pageStartTime!)
              .toString(),
        },
      );
    }();

    _model.dispose();

    if (!isWeb) {
      _keyboardVisibilitySubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    if (currentUserLocationValue == null) {
      return Container(
        color: FlutterFlowTheme.of(context).primaryBackground,
        child: Center(
          child: SizedBox(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                FlutterFlowTheme.of(context).tertiary,
              ),
            ),
          ),
        ),
      );
    }

    return Title(
        title: 'Search results',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: PopScope(
            canPop: false,
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
              body: SafeArea(
                top: true,
                child: Stack(
                  children: [
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(12.0, 8.0, 12.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 12.0),
                                child: SafeArea(
                                  child: Container(
                                    decoration: BoxDecoration(),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkWell(
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
                                            await showDialog(
                                              context: context,
                                              builder: (alertDialogContext) {
                                                return AlertDialog(
                                                  title: Text(
                                                      FFLocalizations.of(
                                                              context)
                                                          .getVariableText(
                                                    enText:
                                                        'More cities to come',
                                                    daText: 'Flere byer på vej',
                                                    deText:
                                                        'Weitere Städte folgen',
                                                    itText:
                                                        'Altre città in arrivo',
                                                    svText:
                                                        'Fler städer kommer snart',
                                                    noText: 'Flere byer kommer',
                                                    frText:
                                                        'D\'autres villes à venir',
                                                  )),
                                                  content: Text(
                                                      FFLocalizations.of(
                                                              context)
                                                          .getVariableText(
                                                    enText:
                                                        'JourneyMate is currently only available in Copenhagen, but we plan on adding more cities in the future.',
                                                    daText:
                                                        'JourneyMate er i øjeblikket kun tilgængelig i København, men vi planlægger at tilføje flere byer i fremtiden.',
                                                    deText:
                                                        'JourneyMate ist derzeit nur in Kopenhagen verfügbar, aber wir planen, in Zukunft weitere Städte hinzuzufügen.',
                                                    itText:
                                                        'JourneyMate è attualmente disponibile solo a Copenaghen, ma in futuro prevediamo di aggiungere altre città.',
                                                    svText:
                                                        'JourneyMate är för närvarande endast tillgängligt i Köpenhamn, men vi planerar att lägga till fler städer i framtiden.',
                                                    noText:
                                                        'JourneyMate er for tiden kun tilgjengelig i København, men vi planlegger å legge til flere byer i fremtiden.',
                                                    frText:
                                                        'JourneyMate n\'est actuellement disponible qu\'à Copenhague, mais nous prévoyons d\'ajouter d\'autres villes à l\'avenir.',
                                                  )),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              alertDialogContext),
                                                      child: Text('Ok'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Text(
                                            FFLocalizations.of(context).getText(
                                              '05aeogb1' /* Copenhagen */,
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyLarge
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyLargeFamily,
                                                  fontSize: 18.0,
                                                  letterSpacing: 0.0,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .bodyLargeIsCustom,
                                                ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment:
                                                AlignmentDirectional(1.0, 0.0),
                                            child: Container(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  0.6,
                                              child: TextFormField(
                                                controller: _model
                                                    .searchBarTextController,
                                                focusNode:
                                                    _model.searchBarFocusNode,
                                                onChanged: (_) =>
                                                    EasyDebounce.debounce(
                                                  '_model.searchBarTextController',
                                                  Duration(milliseconds: 200),
                                                  () async {
                                                    unawaited(
                                                      () async {
                                                        await actions
                                                            .markUserEngaged();
                                                      }(),
                                                    );
                                                    await actions
                                                        .performSearchBarUpdateState(
                                                      _model
                                                          .searchBarTextController
                                                          .text,
                                                      'text_change',
                                                      FFLocalizations.of(
                                                              context)
                                                          .languageCode,
                                                    );
                                                  },
                                                ),
                                                onFieldSubmitted: (_) async {
                                                  unawaited(
                                                    () async {
                                                      await actions
                                                          .markUserEngaged();
                                                    }(),
                                                  );
                                                  await actions
                                                      .performSearchBarUpdateState(
                                                    _model
                                                        .searchBarTextController
                                                        .text,
                                                    'submit',
                                                    FFLocalizations.of(context)
                                                        .languageCode,
                                                  );
                                                },
                                                autofocus: false,
                                                textInputAction:
                                                    TextInputAction.search,
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  alignLabelWithHint: false,
                                                  hintText: FFLocalizations.of(
                                                          context)
                                                      .getText(
                                                    'xn0d16r3' /* Search */,
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      width: 2.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color(0xFFF67944),
                                                      width: 2.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0),
                                                  ),
                                                  errorBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .error,
                                                      width: 2.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0),
                                                  ),
                                                  focusedErrorBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .error,
                                                      width: 2.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0),
                                                  ),
                                                  contentPadding:
                                                      EdgeInsetsDirectional
                                                          .fromSTEB(12.0, 0.0,
                                                              0.0, 0.0),
                                                  prefixIcon: Icon(
                                                    Icons.search,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                    size: 20.0,
                                                  ),
                                                  suffixIcon: _model
                                                          .searchBarTextController!
                                                          .text
                                                          .isNotEmpty
                                                      ? InkWell(
                                                          onTap: () async {
                                                            _model
                                                                .searchBarTextController
                                                                ?.clear();
                                                            unawaited(
                                                              () async {
                                                                await actions
                                                                    .markUserEngaged();
                                                              }(),
                                                            );
                                                            await actions
                                                                .performSearchBarUpdateState(
                                                              _model
                                                                  .searchBarTextController
                                                                  .text,
                                                              'text_change',
                                                              FFLocalizations.of(
                                                                      context)
                                                                  .languageCode,
                                                            );
                                                            safeSetState(() {});
                                                          },
                                                          child: Icon(
                                                            Icons.clear,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryText,
                                                            size: 20.0,
                                                          ),
                                                        )
                                                      : null,
                                                ),
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      fontFamily:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumFamily,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondaryText,
                                                      fontSize: 16.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      useGoogleFonts:
                                                          !FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumIsCustom,
                                                    ),
                                                validator: _model
                                                    .searchBarTextControllerValidator
                                                    .asValidator(context),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ].divide(SizedBox(width: 8.0)),
                                    ),
                                  ),
                                ),
                              ),
                              SafeArea(
                                child: Container(
                                  decoration: BoxDecoration(),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Builder(
                                        builder: (context) {
                                          if (_model.filterOverlayOpen) {
                                            return Text(
                                              FFLocalizations.of(context)
                                                  .getVariableText(
                                                enText: 'Filters',
                                                daText: 'Filtre',
                                                deText: 'Filter',
                                                itText: 'Filtri',
                                                svText: 'Filter',
                                                noText: 'Filtre',
                                                frText: 'Filtres',
                                              ),
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .titleLarge
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleLargeFamily,
                                                        letterSpacing: 0.0,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
                                                                .titleLargeIsCustom,
                                                      ),
                                            );
                                          } else {
                                            return Text(
                                              () {
                                                if ((FFAppState()
                                                        .filtersUsedForSearch
                                                        .isNotEmpty) &&
                                                    (FFAppState()
                                                            .searchResultsCount >
                                                        0)) {
                                                  return FFLocalizations.of(
                                                          context)
                                                      .getVariableText(
                                                    enText:
                                                        'Search results (${FFAppState().searchResultsCount.toString()})',
                                                    daText:
                                                        'Søgeresultater (${FFAppState().searchResultsCount.toString()})',
                                                    deText:
                                                        'Suchergebnisse (${FFAppState().searchResultsCount.toString()})',
                                                    itText:
                                                        'Risultati della ricerca (${FFAppState().searchResultsCount.toString()})',
                                                    svText:
                                                        'Sökresultat (${FFAppState().searchResultsCount.toString()})',
                                                    noText:
                                                        'Søkeresultater (${FFAppState().searchResultsCount.toString()})',
                                                    frText:
                                                        'Résultats de recherche (${FFAppState().searchResultsCount.toString()})',
                                                  );
                                                } else if (!(_model
                                                        .activeFilterIds
                                                        .isNotEmpty) &&
                                                    (FFAppState()
                                                            .searchResultsCount ==
                                                        0)) {
                                                  return FFLocalizations.of(
                                                          context)
                                                      .getVariableText(
                                                    enText: 'No search results',
                                                    daText:
                                                        'Ingen søgeresultater',
                                                    deText:
                                                        'Keine Suchergebnisse',
                                                    itText:
                                                        'Nessun risultato di ricerca',
                                                    svText: 'Inga sökresultat',
                                                    noText:
                                                        'Ingen søkeresultater',
                                                    frText:
                                                        'Aucun résultat de recherche',
                                                  );
                                                } else {
                                                  return FFLocalizations.of(
                                                          context)
                                                      .getVariableText(
                                                    enText: 'Places near you',
                                                    daText: 'Steder nær dig',
                                                    deText:
                                                        'Orte in deiner Nähe',
                                                    itText: 'Vicino a te',
                                                    svText: 'Platser nära dig',
                                                    noText: 'Steder nær deg',
                                                    frText:
                                                        'Lieux près de chez vous',
                                                  );
                                                }
                                              }(),
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .titleLarge
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleLargeFamily,
                                                        letterSpacing: 0.0,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
                                                                .titleLargeIsCustom,
                                                      ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(height: 8.0)),
                          ),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              child: Stack(
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      SafeArea(
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 0.0, 0.0, 8.0),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 48.0,
                                                  child: custom_widgets
                                                      .FilterTitlesRow(
                                                    width: double.infinity,
                                                    height: 48.0,
                                                    languageCode:
                                                        FFLocalizations.of(
                                                                context)
                                                            .languageCode,
                                                    filterData: FFAppState()
                                                        .filtersForUserLanguage,
                                                    translationsCache:
                                                        FFAppState()
                                                            .translationsCache,
                                                    onTitleClick:
                                                        (titleId) async {
                                                      _model.searchBarIsFocused =
                                                          false;
                                                      safeSetState(() {});
                                                    },
                                                  ),
                                                ),
                                              ),

                                              // Conditional visibility is app state "filtersUsedForThisSearch".
                                              if (FFAppState()
                                                  .filtersUsedForSearch
                                                  .isNotEmpty)
                                                Container(
                                                  width: double.infinity,
                                                  height: 32.0,
                                                  child: custom_widgets
                                                      .SelectedFiltersBtns(
                                                    width: double.infinity,
                                                    height: 32.0,
                                                    filters: FFAppState()
                                                        .filtersForUserLanguage,
                                                    selectedFilterIds:
                                                        FFAppState()
                                                            .filtersUsedForSearch,
                                                    languageCode:
                                                        FFLocalizations.of(
                                                                context)
                                                            .languageCode,
                                                    buttonRowMayLoad: true,
                                                    translationsCache:
                                                        FFAppState()
                                                            .translationsCache,
                                                    removeFilter:
                                                        (idOfFilterToRemove) async {
                                                      FFAppState()
                                                          .removeFromFiltersUsedForSearch(
                                                              idOfFilterToRemove);
                                                      safeSetState(() {});
                                                    },
                                                    onLocationFiltersCount:
                                                        (count) async {
                                                      _model.onLocationFiltersCount =
                                                          _model.onLocationFiltersCount! +
                                                              count;
                                                      safeSetState(() {});
                                                    },
                                                    onTypeFiltersCount:
                                                        (count) async {
                                                      _model.onTypeFiltersCount =
                                                          _model.onTypeFiltersCount! +
                                                              count;
                                                      safeSetState(() {});
                                                    },
                                                    onPreferencesFiltersCount:
                                                        (count) async {
                                                      _model.onPreferencesFiltersCount =
                                                          _model.onPreferencesFiltersCount! +
                                                              count;
                                                      safeSetState(() {});
                                                    },
                                                    onClearAll: () async {
                                                      await Future.wait([
                                                        Future(() async {
                                                          _model.onLocationFiltersCount =
                                                              null;
                                                          _model.onTypeFiltersCount =
                                                              null;
                                                          _model.onPreferencesFiltersCount =
                                                              null;
                                                          safeSetState(() {});
                                                        }),
                                                        Future(() async {
                                                          FFAppState()
                                                              .filtersUsedForSearch = [];
                                                          FFAppState()
                                                              .searchResultsCount = 0;
                                                          safeSetState(() {});
                                                        }),
                                                      ]);
                                                    },
                                                    onSearchCompleted:
                                                        (activeFilterIds,
                                                            resultCount) async {
                                                      _model.activeFilterIds =
                                                          activeFilterIds
                                                              .toList()
                                                              .cast<int>();
                                                      safeSetState(() {});
                                                      FFAppState()
                                                              .searchResultsCount =
                                                          resultCount;
                                                      safeSetState(() {});
                                                    },
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: 560.0,
                                        child: custom_widgets
                                            .SearchResultsListView(
                                          width: double.infinity,
                                          height: 560.0,
                                          userLocation:
                                              currentUserLocationValue!,
                                        ),
                                      ),
                                    ]
                                        .divide(SizedBox(height: 6.0))
                                        .addToEnd(SizedBox(height: 36.0)),
                                  ),
                                  if (FFAppState().filterOverlayOpen == true)
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 48.0, 0.0, 0.0),
                                      child: Container(
                                        width: double.infinity,
                                        height:
                                            MediaQuery.sizeOf(context).height *
                                                5.5,
                                        child:
                                            custom_widgets.FilterOverlayWidget(
                                          width: double.infinity,
                                          height: MediaQuery.sizeOf(context)
                                                  .height *
                                              5.5,
                                          selectedTitleID: FFAppState()
                                              .activeSelectedTitleId,
                                          filterData: FFAppState()
                                              .filtersForUserLanguage,
                                          activeFilterIds:
                                              _model.activeFilterIds,
                                          selectedFilterIds:
                                              FFAppState().filtersUsedForSearch,
                                          searchTerm: _model
                                              .searchBarTextController.text,
                                          mayLoad: _model.filterMayLoad,
                                          resultCount:
                                              FFAppState().searchResultsCount,
                                          languageCode:
                                              FFLocalizations.of(context)
                                                  .languageCode,
                                          translationsCache:
                                              FFAppState().translationsCache,
                                          onSearchCompleted: (activeFilterIds,
                                              resultCount) async {
                                            _model.activeFilterIds =
                                                activeFilterIds
                                                    .toList()
                                                    .cast<int>();
                                            safeSetState(() {});
                                            FFAppState().searchResultsCount =
                                                resultCount;
                                            safeSetState(() {});
                                          },
                                          onCloseOverlay:
                                              (selectedFilterIds) async {
                                            _model.filterOverlayOpen = false;
                                            safeSetState(() {});
                                          },
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ].divide(SizedBox(height: 8.0)),
                      ),
                    ),
                    if ((FFAppState().filterOverlayOpen == false) &&
                        (_model.searchBarIsFocused == false) &&
                        !(isWeb
                            ? MediaQuery.viewInsetsOf(context).bottom > 0
                            : _isKeyboardVisible))
                      wrapWithModel(
                        model: _model.navBarModel,
                        updateCallback: () => safeSetState(() {}),
                        child: NavBarWidget(
                          pageIsSearchResults: true,
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
