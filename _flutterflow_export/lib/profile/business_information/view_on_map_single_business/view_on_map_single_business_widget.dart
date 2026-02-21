import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';
import 'view_on_map_single_business_model.dart';
export 'view_on_map_single_business_model.dart';

class ViewOnMapSingleBusinessWidget extends StatefulWidget {
  const ViewOnMapSingleBusinessWidget({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  final double? latitude;
  final double? longitude;

  static String routeName = 'ViewOnMapSingleBusiness';
  static String routePath = 'viewOnMapSingleBusiness';

  @override
  State<ViewOnMapSingleBusinessWidget> createState() =>
      _ViewOnMapSingleBusinessWidgetState();
}

class _ViewOnMapSingleBusinessWidgetState
    extends State<ViewOnMapSingleBusinessWidget> {
  late ViewOnMapSingleBusinessModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ViewOnMapSingleBusinessModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Title(
        title: 'ViewOnMapSingleBusiness',
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
            body: SafeArea(
              top: true,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Builder(builder: (context) {
                          final _googleMapMarker = functions.latLongcombine(
                              widget!.latitude!, widget!.longitude!);
                          return FlutterFlowGoogleMap(
                            controller: _model.googleMapsController,
                            onCameraIdle: (latLng) =>
                                _model.googleMapsCenter = latLng,
                            initialLocation: _model.googleMapsCenter ??=
                                functions.latLongcombine(
                                    widget!.latitude!, widget!.longitude!),
                            markers: [
                              FlutterFlowMarker(
                                _googleMapMarker.serialize(),
                                _googleMapMarker,
                              ),
                            ],
                            markerColor: GoogleMarkerColor.orange,
                            mapType: MapType.normal,
                            style: GoogleMapStyle.standard,
                            initialZoom: 14.0,
                            allowInteraction: true,
                            allowZoom: true,
                            showZoomControls: true,
                            showLocation: true,
                            showCompass: false,
                            showMapToolbar: true,
                            showTraffic: false,
                            centerMapOnMarkerTap: true,
                          );
                        }),
                        PointerInterceptor(
                          intercepting: isWeb,
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                20.0, 40.0, 0.0, 0.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context.safePop();
                              },
                              child: Icon(
                                Icons.arrow_circle_left,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 40.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
