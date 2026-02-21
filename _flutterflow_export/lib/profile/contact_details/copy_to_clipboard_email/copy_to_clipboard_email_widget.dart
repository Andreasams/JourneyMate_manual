import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/profile/contact_details/copy_to_clipboard_email_success/copy_to_clipboard_email_success_widget.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'copy_to_clipboard_email_model.dart';
export 'copy_to_clipboard_email_model.dart';

class CopyToClipboardEmailWidget extends StatefulWidget {
  const CopyToClipboardEmailWidget({
    super.key,
    required this.email,
  });

  final String? email;

  @override
  State<CopyToClipboardEmailWidget> createState() =>
      _CopyToClipboardEmailWidgetState();
}

class _CopyToClipboardEmailWidgetState
    extends State<CopyToClipboardEmailWidget> {
  late CopyToClipboardEmailModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CopyToClipboardEmailModel());

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
            await Clipboard.setData(ClipboardData(text: widget!.email!));
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
                  child: CopyToClipboardEmailSuccessWidget(),
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
                          enText: 'Tap here to copy the email',
                          daText: 'Tryk her for at kopiere emailen',
                          deText:
                              'Hier tippen, um die E-Mail-Adresse zu kopieren',
                          itText: 'Tocca qui per copiare l\'indirizzo e-mail',
                          svText: 'Tryck här för att kopiera e-postadressen',
                          noText: 'Trykk her for å kopiere e-postadressen',
                          frText: 'Appuyez ici pour copier l\'adresse e-mail',
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
