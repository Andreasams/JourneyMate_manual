import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dish_expanded_info_sheet_model.dart';
export 'dish_expanded_info_sheet_model.dart';

class DishExpandedInfoSheetWidget extends StatefulWidget {
  const DishExpandedInfoSheetWidget({
    super.key,
    required this.allInfo,
    bool? isBeverage,
    required this.dietaryTypeIds,
    required this.allergyIds,
    required this.businessName,
    required this.price,
    bool? hasVariations,
    this.variationPrice,
  })  : this.isBeverage = isBeverage ?? true,
        this.hasVariations = hasVariations ?? false;

  final dynamic allInfo;
  final bool isBeverage;
  final List<int>? dietaryTypeIds;
  final List<int>? allergyIds;
  final String? businessName;
  final String? price;
  final bool hasVariations;
  final String? variationPrice;

  @override
  State<DishExpandedInfoSheetWidget> createState() =>
      _DishExpandedInfoSheetWidgetState();
}

class _DishExpandedInfoSheetWidgetState
    extends State<DishExpandedInfoSheetWidget> {
  late DishExpandedInfoSheetModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DishExpandedInfoSheetModel());

    _model.expandableExpandableController =
        ExpandableController(initialExpanded: false)
          ..addListener(() => safeSetState(() {}));
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

    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      curve: Curves.linear,
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: functions.dishBottomSheetMinHeight(
            MediaQuery.sizeOf(context).height,
            widget!.dietaryTypeIds?.toList(),
            getJsonField(
              widget!.allInfo,
              r'''$.item_description''',
            ).toString(),
            getJsonField(
                      widget!.allInfo,
                      r'''$.item_image_url''',
                    ) !=
                    null
                ? true
                : false),
        maxHeight: _model.expandableExpandableController.expanded!
            ? functions.dishBottomSheetMaxHeight(
                getJsonField(
                  widget!.allInfo,
                  r'''$.item_description''',
                ).toString(),
                MediaQuery.sizeOf(context).height,
                getJsonField(
                          widget!.allInfo,
                          r'''$.item_image_url''',
                        ) !=
                        null
                    ? true
                    : false,
                widget!.dietaryTypeIds?.toList())
            : functions.dishBottomSheetMinHeight(
                MediaQuery.sizeOf(context).height,
                widget!.dietaryTypeIds?.toList(),
                getJsonField(
                  widget!.allInfo,
                  r'''$.item_description''',
                ).toString(),
                getJsonField(
                          widget!.allInfo,
                          r'''$.item_image_url''',
                        ) !=
                        null
                    ? true
                    : false),
      ),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0.0),
          bottomRight: Radius.circular(0.0),
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              if (getJsonField(
                    widget!.allInfo,
                    r'''$.item_image_url''',
                  ) !=
                  null)
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(0.0),
                    bottomRight: Radius.circular(0.0),
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                  child: Image.network(
                    getJsonField(
                      widget!.allInfo,
                      r'''$.item_image_url''',
                    ).toString(),
                    width: double.infinity,
                    height: 200.0,
                    fit: BoxFit.cover,
                    alignment: Alignment(0.0, 0.0),
                  ),
                ),
              Align(
                alignment: AlignmentDirectional(0.0, -1.0),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 12.0),
                  child: Container(
                    width: 80.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primaryText,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(-1.0, -1.0),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(12.0, 12.0, 0.0, 0.0),
                  child: Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.close_rounded,
                        color: FlutterFlowTheme.of(context).primaryText,
                        size: 30.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(12.0, 16.0, 12.0, 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getJsonField(
                          widget!.allInfo,
                          r'''$.item_name''',
                        ).toString(),
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyLargeFamily,
                              fontSize: 22.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyLargeIsCustom,
                            ),
                      ),
                      Text(
                        valueOrDefault<String>(
                          widget!.hasVariations == false
                              ? widget!.price
                              : widget!.variationPrice,
                          '155',
                        ),
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyLargeFamily,
                              color: FlutterFlowTheme.of(context).primary,
                              fontSize: 18.0,
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyLargeIsCustom,
                            ),
                      ),
                      if (getJsonField(
                            widget!.allInfo,
                            r'''$.item_description''',
                          ) !=
                          null)
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 2.0),
                          child: Text(
                            getJsonField(
                              widget!.allInfo,
                              r'''$.item_description''',
                            ).toString(),
                            textAlign: TextAlign.start,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodyMediumFamily,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  fontSize: 18.0,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodyMediumIsCustom,
                                ),
                          ),
                        ),
                      if (widget!.hasVariations)
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 8.0, 0.0, 2.0),
                          child: Text(
                            FFLocalizations.of(context).getText(
                              'nmk8r6o5' /* Vælg mellem: */,
                            ),
                            textAlign: TextAlign.start,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodyMediumFamily,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  fontSize: 18.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodyMediumIsCustom,
                                ),
                          ),
                        ),
                      if (widget!.hasVariations == true)
                        Builder(
                          builder: (context) {
                            final variaitons = functions
                                    .getVariationModifiers(widget!.allInfo!)
                                    ?.toList() ??
                                [];

                            return ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: variaitons.length,
                              itemBuilder: (context, variaitonsIndex) {
                                final variaitonsItem =
                                    variaitons[variaitonsIndex];
                                return Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      getJsonField(
                                        variaitonsItem,
                                        r'''$.name''',
                                      ).toString(),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMediumFamily,
                                            fontSize: 18.0,
                                            letterSpacing: 0.0,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodyMediumIsCustom,
                                          ),
                                    ),
                                    Text(
                                      FFLocalizations.of(context).getText(
                                        '24nk41wt' /* Hello World */,
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
                                  ],
                                );
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
                if (!widget!.isBeverage)
                  Divider(
                    thickness: 1.0,
                    indent: 16.0,
                    endIndent: 16.0,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                if (!widget!.isBeverage)
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 4.0),
                          child: Text(
                            FFLocalizations.of(context).getText(
                              'p2440u1x' /* Additional information */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyLarge
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodyLargeFamily,
                                  fontSize: 17.0,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodyLargeIsCustom,
                                ),
                          ),
                        ),
                        if (widget!.isBeverage == false)
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 2.0, 0.0, 0.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      FFLocalizations.of(context).getText(
                                        'ttf99xss' /* Dietary preferences and restri... */,
                                      ),
                                      textAlign: TextAlign.start,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyLarge
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyLargeFamily,
                                            fontSize: 15.0,
                                            letterSpacing: 0.0,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodyLargeIsCustom,
                                          ),
                                    ),
                                    Text(
                                      valueOrDefault<String>(
                                        functions
                                            .convertDietaryPreferencesToString(
                                                widget!.dietaryTypeIds
                                                    ?.toList(),
                                                FFLocalizations.of(context)
                                                    .languageCode,
                                                widget!.isBeverage,
                                                FFAppState().translationsCache),
                                        'convertDietaryPreferencesToString',
                                      ),
                                      textAlign: TextAlign.start,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMediumFamily,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            fontSize: 15.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w300,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodyMediumIsCustom,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 12.0, 0.0, 0.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      FFLocalizations.of(context).getText(
                                        'q77esk10' /* Allergens */,
                                      ),
                                      textAlign: TextAlign.start,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyLarge
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyLargeFamily,
                                            fontSize: 15.0,
                                            letterSpacing: 0.0,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodyLargeIsCustom,
                                          ),
                                    ),
                                    Text(
                                      valueOrDefault<String>(
                                        functions.convertAllergiesToString(
                                            widget!.allergyIds?.toList(),
                                            FFLocalizations.of(context)
                                                .languageCode,
                                            widget!.isBeverage,
                                            FFAppState().translationsCache),
                                        'convertAllergiesToString',
                                      ),
                                      textAlign: TextAlign.start,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMediumFamily,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            fontSize: 15.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w300,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodyMediumIsCustom,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 8.0, 0.0, 0.0),
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 400),
                                  curve: Curves.linear,
                                  height: 200.0,
                                  child: Container(
                                    width: double.infinity,
                                    height: 200.0,
                                    color: Color(0x00000000),
                                    child: ExpandableNotifier(
                                      controller:
                                          _model.expandableExpandableController,
                                      child: ExpandablePanel(
                                        header: Text(
                                          FFLocalizations.of(context)
                                              .getVariableText(
                                            enText: 'Information source',
                                            daText: 'Informationskilde',
                                            deText: 'Informationsquelle',
                                            itText: 'Fonte di informazione',
                                            svText: 'Informationskälla',
                                            noText: 'Informasjonskilde',
                                            frText: 'Source d\'information',
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMediumFamily,
                                                fontSize: 15.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.normal,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMediumIsCustom,
                                              ),
                                        ),
                                        collapsed: Container(),
                                        expanded: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${FFLocalizations.of(context).getVariableText(
                                                  enText:
                                                      'Ingredient, allergy and dietary information provided by ',
                                                  daText:
                                                      'Ingrediens- og diætoplysninger leveret af ',
                                                  deText:
                                                      'Informationen zu Inhaltsstoffen, Allergien und Ernährung bereitgestellt von',
                                                  itText:
                                                      'Informazioni su ingredienti, allergie e dieta fornite da',
                                                  svText:
                                                      'Ingrediens-, allergi- och kostinformation tillhandahållen av',
                                                  noText:
                                                      'Ingrediens-, allergi- og diettinformasjon levert av',
                                                  frText:
                                                      'Informations sur les ingrédients, les allergies et le régime alimentaire fournies par',
                                                )}${widget!.businessName}. ${FFLocalizations.of(context).getVariableText(
                                                  enText:
                                                      'Always verify with staff before ordering as ingredients may change and cross-contamination can occur.',
                                                  daText:
                                                      'Verificer altid med personalet før bestilling, da ingredienser kan ændre sig og krydskontaminering kan forekomme.',
                                                  deText:
                                                      'Verifizieren Sie vor der Bestellung immer mit den Mitarbeitern, da sich Inhaltsstoffe ändern können und Kreuzkontaminationen auftreten können.',
                                                  itText:
                                                      'Verificare sempre con il personale prima di ordinare poiché gli ingredienti possono cambiare e può verificarsi una contaminazione incrociata.',
                                                  svText:
                                                      'Verifiera alltid med personalen innan du beställer, eftersom ingredienser kan ändras och korskontaminering kan uppstå.',
                                                  noText:
                                                      'Verifiser alltid med personalet før du bestiller, da ingredienser kan endre seg og krysskontaminering kan oppstå.',
                                                  frText:
                                                      'Toujours vérifier auprès du personnel avant de commander, car les ingrédients peuvent changer et une contamination croisée peut se produire.',
                                                )}',
                                                textAlign: TextAlign.start,
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          fontSize: 15.0,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                FFLocalizations.of(context)
                                                    .getVariableText(
                                                  enText:
                                                      'JourneyMate does its best to verify this information but cannot be held responsible for its accuracy.',
                                                  daText:
                                                      'JourneyMate gør sit bedste for at verificere disse oplysninger, men kan ikke holdes ansvarlig for deres nøjagtighed.',
                                                  deText:
                                                      'JourneyMate bemüht sich, diese Informationen zu verifizieren, kann jedoch nicht für deren Richtigkeit haftbar gemacht werden.',
                                                  itText:
                                                      'JourneyMate fa del suo meglio per verificare queste informazioni, ma non può essere ritenuto responsabile della loro accuratezza.',
                                                  svText:
                                                      'JourneyMate gör sitt bästa för att verifiera den här informationen, men kan inte hållas ansvarig för dess riktighet.',
                                                  noText:
                                                      'JourneyMate gjør sitt beste for å verifisere denne informasjonen, men kan ikke holdes ansvarlig for nøyaktigheten.',
                                                  frText:
                                                      'JourneyMate fait de son mieux pour vérifier ces informations, mais ne peut être tenu responsable de leur exactitude.',
                                                ),
                                                textAlign: TextAlign.start,
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          fontSize: 15.0,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                              ),
                                            ),
                                          ].divide(SizedBox(height: 4.0)),
                                        ),
                                        theme: ExpandableThemeData(
                                          tapHeaderToExpand: true,
                                          tapBodyToExpand: false,
                                          tapBodyToCollapse: false,
                                          headerAlignment:
                                              ExpandablePanelHeaderAlignment
                                                  .center,
                                          hasIcon: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
              ].divide(SizedBox(
                  height: getJsonField(
                            widget!.allInfo,
                            r'''$.item_description''',
                          ) !=
                          null
                      ? 20.0
                      : 12.0)),
            ),
          ),
        ],
      ),
    );
  }
}
