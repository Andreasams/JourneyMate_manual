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
import 'profile_top_business_block_model.dart';
export 'profile_top_business_block_model.dart';

class ProfileTopBusinessBlockWidget extends StatefulWidget {
  const ProfileTopBusinessBlockWidget({
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

  @override
  State<ProfileTopBusinessBlockWidget> createState() =>
      _ProfileTopBusinessBlockWidgetState();
}

class _ProfileTopBusinessBlockWidgetState
    extends State<ProfileTopBusinessBlockWidget> {
  late ProfileTopBusinessBlockModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfileTopBusinessBlockModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.statustext = await actions.determineStatusAndColor(
        (color) async {
          _model.statuscolor = color;
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
      height: 107.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0.0),
          bottomRight: Radius.circular(0.0),
          topLeft: Radius.circular(0.0),
          topRight: Radius.circular(0.0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5.0),
            child: Image.network(
              widget!.profilePicture!,
              width: 100.0,
              height: 100.0,
              fit: BoxFit.scaleDown,
            ),
          ),
          Container(
            width: 251.0,
            height: double.infinity,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryBackground,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      valueOrDefault<String>(
                        widget!.businessName,
                        'BusinessName',
                      ),
                      style: FlutterFlowTheme.of(context).titleLarge.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).titleLargeFamily,
                            fontSize: 20.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .titleLargeIsCustom,
                          ),
                    ),
                  ],
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
                                  color: _model.statuscolor,
                                  fontSize: 15.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodyMediumIsCustom,
                                ),
                          );
                        } else {
                          return Text(
                            FFLocalizations.of(context).getText(
                              'qc25om4m' /* Closed */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodyMediumFamily,
                                  color: FlutterFlowTheme.of(context).error,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodyMediumIsCustom,
                                ),
                          );
                        }
                      },
                    ),
                    Text(
                      FFLocalizations.of(context).getText(
                        '96y9mb2l' /* • */,
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyMediumFamily,
                            fontSize: 15.0,
                            letterSpacing: 0.0,
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
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyMediumFamily,
                            fontSize: 15.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w300,
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
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyMediumFamily,
                            fontSize: 15.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w300,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .bodyMediumIsCustom,
                          ),
                    ),
                    Text(
                      FFLocalizations.of(context).getText(
                        'ndthifkd' /* • */,
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyMediumFamily,
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
                            FFAppState().exchangeRate,
                            FFAppState().userCurrencyCode),
                        'Unavailable',
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyMediumFamily,
                            fontSize: 15.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w300,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .bodyMediumIsCustom,
                          ),
                    ),
                    if (FFAppState().locationStatus == true)
                      Text(
                        FFLocalizations.of(context).getText(
                          '4dnrmcoa' /* • */,
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              fontSize: 15.0,
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyMediumIsCustom,
                            ),
                      ),
                    if (FFAppState().locationStatus == true)
                      Text(
                        valueOrDefault<String>(
                          '${functions.returnDistance(widget!.userLocation!, widget!.latitude!, widget!.longitude!, FFLocalizations.of(context).languageCode).toString()}${FFLocalizations.of(context).getVariableText(
                            enText: ' mi.',
                            daText: '  km.',
                            deText: '  km.',
                            itText: '  km.',
                            svText: '  km.',
                            noText: '  km.',
                            frText: '  km.',
                          )}',
                          '0 km',
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              fontSize: 15.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w300,
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
                        functions.streetAndNeighbourhoodLength(
                            widget!.neighbourhoodName!, widget!.street!),
                        'København',
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyMediumFamily,
                            fontSize: 15.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w300,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .bodyMediumIsCustom,
                          ),
                    ),
                  ],
                ),
              ].divide(SizedBox(height: 3.0)),
            ),
          ),
        ].divide(SizedBox(width: 8.0)),
      ),
    );
  }
}
