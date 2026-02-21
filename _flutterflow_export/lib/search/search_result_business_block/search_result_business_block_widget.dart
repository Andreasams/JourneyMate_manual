import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'search_result_business_block_model.dart';
export 'search_result_business_block_model.dart';

class SearchResultBusinessBlockWidget extends StatefulWidget {
  const SearchResultBusinessBlockWidget({
    super.key,
    this.profilePicture,
    this.businessName,
    this.latitude,
    this.longitude,
    this.street,
    this.neighbourhoodName,
    this.businessID,
    this.businessType,
    required this.openingHours,
    required this.userLocation,
    required this.priceRangeMin,
    required this.priceRangeMax,
    required this.exchangeRate,
  });

  final String? profilePicture;
  final String? businessName;
  final double? latitude;
  final double? longitude;
  final String? street;
  final String? neighbourhoodName;
  final int? businessID;
  final String? businessType;
  final dynamic openingHours;
  final LatLng? userLocation;
  final int? priceRangeMin;
  final int? priceRangeMax;
  final double? exchangeRate;

  @override
  State<SearchResultBusinessBlockWidget> createState() =>
      _SearchResultBusinessBlockWidgetState();
}

class _SearchResultBusinessBlockWidgetState
    extends State<SearchResultBusinessBlockWidget> {
  late SearchResultBusinessBlockModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SearchResultBusinessBlockModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.statustext = await actions.determineStatusAndColor(
        (color) async {
          _model.color = color;
          safeSetState(() {});
        },
        widget!.openingHours!,
        getCurrentTimestamp,
        FFLocalizations.of(context).languageCode,
        FFAppState().translationsCache,
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: 84.0,
      ),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0.0),
          bottomRight: Radius.circular(0.0),
          topLeft: Radius.circular(0.0),
          topRight: Radius.circular(0.0),
        ),
      ),
      alignment: AlignmentDirectional(-1.0, -1.0),
      child: Align(
        alignment: AlignmentDirectional(-1.0, -1.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Align(
              alignment: AlignmentDirectional(0.0, 0.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: Image.network(
                  widget!.profilePicture!,
                  width: 84.0,
                  height: 84.0,
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: 251.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primaryBackground,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      valueOrDefault<String>(
                        widget!.businessName,
                        'BusinessName',
                      ),
                      style: FlutterFlowTheme.of(context).titleLarge.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).titleLargeFamily,
                            fontSize: 18.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.normal,
                            lineHeight: 0.0,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .titleLargeIsCustom,
                          ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Builder(
                          builder: (context) {
                            if (FFAppState().BusinessIsOpen) {
                              return Text(
                                valueOrDefault<String>(
                                  _model.statustext,
                                  'Open',
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyMediumFamily,
                                      color: _model.color,
                                      fontSize: 15.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.normal,
                                      lineHeight: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodyMediumIsCustom,
                                    ),
                              );
                            } else {
                              return Text(
                                FFLocalizations.of(context).getText(
                                  '103bep6k' /* Closed */,
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyMediumFamily,
                                      color: FlutterFlowTheme.of(context).error,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      lineHeight: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodyMediumIsCustom,
                                    ),
                              );
                            }
                          },
                        ),
                        Text(
                          FFLocalizations.of(context).getText(
                            'fdh4bmkm' /* • */,
                          ),
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodyMediumFamily,
                                fontSize: 15.0,
                                letterSpacing: 0.0,
                                lineHeight: 0.0,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .bodyMediumIsCustom,
                              ),
                        ),
                        Text(
                          valueOrDefault<String>(
                            functions.openClosesAt(
                                widget!.openingHours!,
                                getCurrentTimestamp,
                                FFLocalizations.of(context).languageCode,
                                FFAppState().translationsCache),
                            'e',
                          ),
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodyMediumFamily,
                                fontSize: 15.0,
                                letterSpacing: 0.0,
                                lineHeight: 0.0,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .bodyMediumIsCustom,
                              ),
                        ),
                      ].divide(SizedBox(width: 4.0)),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          valueOrDefault<String>(
                            widget!.businessType,
                            'Type',
                          ),
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodyMediumFamily,
                                fontSize: 15.0,
                                letterSpacing: 0.0,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .bodyMediumIsCustom,
                              ),
                        ),
                        Text(
                          FFLocalizations.of(context).getText(
                            '6f2losum' /* • */,
                          ),
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodyMediumFamily,
                                fontSize: 15.0,
                                letterSpacing: 0.0,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .bodyMediumIsCustom,
                              ),
                        ),
                        Text(
                          valueOrDefault<String>(
                            functions.convertAndFormatPriceRange(
                                widget!.priceRangeMin!.toDouble(),
                                widget!.priceRangeMax!.toDouble(),
                                'DKK',
                                widget!.exchangeRate!,
                                FFAppState().userCurrencyCode),
                            'Unavailable',
                          ),
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodyMediumFamily,
                                fontSize: 15.0,
                                letterSpacing: 0.0,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .bodyMediumIsCustom,
                              ),
                        ),
                        if (FFAppState().locationStatus == true)
                          Text(
                            FFLocalizations.of(context).getText(
                              'k1zbavsf' /* • */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodyMediumFamily,
                                  fontSize: 15.0,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodyMediumIsCustom,
                                ),
                          ),
                        if (FFAppState().locationStatus)
                          Text(
                            valueOrDefault<String>(
                              '${functions.returnDistance(widget!.userLocation!, widget!.latitude!, widget!.longitude!, FFLocalizations.of(context).languageCode).toString()}${FFLocalizations.of(context).getVariableText(
                                enText: ' mi.',
                                daText: ' km.',
                                deText: ' km.',
                                itText: ' km.',
                                svText: '  km.',
                                noText: ' km.',
                                frText: ' km.',
                              )}',
                              '0 km',
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodyMediumFamily,
                                  fontSize: 15.0,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodyMediumIsCustom,
                                ),
                          ),
                      ].divide(SizedBox(width: 4.0)),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          '${valueOrDefault<String>(
                            widget!.street,
                            'Street',
                          )}, ${valueOrDefault<String>(
                            widget!.neighbourhoodName,
                            'neighbourhood',
                          )}',
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodyMediumFamily,
                                fontSize: 15.0,
                                letterSpacing: 0.0,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .bodyMediumIsCustom,
                              ),
                        ),
                      ],
                    ),
                  ].divide(SizedBox(height: 2.0)),
                ),
              ),
            ),
          ].divide(SizedBox(width: 8.0)),
        ),
      ),
    );
  }
}
