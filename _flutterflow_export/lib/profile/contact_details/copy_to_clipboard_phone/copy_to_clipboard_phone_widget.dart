import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/profile/contact_details/copy_to_clipboard_phone_success/copy_to_clipboard_phone_success_widget.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'copy_to_clipboard_phone_model.dart';
export 'copy_to_clipboard_phone_model.dart';

class CopyToClipboardPhoneWidget extends StatefulWidget {
  const CopyToClipboardPhoneWidget({
    super.key,
    required this.phoneNumber,
  });

  final String? phoneNumber;

  @override
  State<CopyToClipboardPhoneWidget> createState() =>
      _CopyToClipboardPhoneWidgetState();
}

class _CopyToClipboardPhoneWidgetState
    extends State<CopyToClipboardPhoneWidget> {
  late CopyToClipboardPhoneModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CopyToClipboardPhoneModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Padding(
        padding: EdgeInsetsDirectional.fromSTEB(20.0, 12.0, 20.0, 0.0),
        child: InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: widget!.phoneNumber!));
            Navigator.pop(context);
            await showDialog(
              context: context,
              builder: (dialogContext) {
                return Dialog(
                  elevation: 0,
                  insetPadding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                  alignment: AlignmentDirectional(0.0, 1.0)
                      .resolve(Directionality.of(context)),
                  child: CopyToClipboardPhoneSuccessWidget(),
                );
              },
            );

            await Future.delayed(
              Duration(
                milliseconds: 1500,
              ),
            );
            Navigator.pop(context);
          },
          child: Container(
            width: double.infinity,
            height: 60.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              boxShadow: [
                BoxShadow(
                  blurRadius: 5.0,
                  color: Color(0x3416202A),
                  offset: Offset(
                    0.0,
                    2.0,
                  ),
                )
              ],
              borderRadius: BorderRadius.circular(12.0),
              shape: BoxShape.rectangle,
            ),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 0.0, 0.0),
                      child: Text(
                        FFLocalizations.of(context).getVariableText(
                          enText: 'Tap here to copy the phone number',
                          daText: 'Tryk her for at kopiere telefonnummeret',
                          deText:
                              'Hier tippen, um die Telefonnummer zu kopieren',
                          itText: 'Tocca qui per copiare il numero di telefono',
                          svText: 'Tryck här för att kopiera telefonnumret',
                          noText: 'Trykk her for å kopiere telefonnummeret',
                          frText:
                              'Appuyez ici pour copier le numéro de téléphone',
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyMediumIsCustom,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
