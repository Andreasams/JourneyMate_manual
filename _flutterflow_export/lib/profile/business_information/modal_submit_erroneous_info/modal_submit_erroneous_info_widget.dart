import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'modal_submit_erroneous_info_model.dart';
export 'modal_submit_erroneous_info_model.dart';

class ModalSubmitErroneousInfoWidget extends StatefulWidget {
  const ModalSubmitErroneousInfoWidget({
    super.key,
    required this.businessName,
    required this.businessID,
  });

  final String? businessName;
  final int? businessID;

  @override
  State<ModalSubmitErroneousInfoWidget> createState() =>
      _ModalSubmitErroneousInfoWidgetState();
}

class _ModalSubmitErroneousInfoWidgetState
    extends State<ModalSubmitErroneousInfoWidget> {
  late ModalSubmitErroneousInfoModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ModalSubmitErroneousInfoModel());

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
      height: MediaQuery.sizeOf(context).height,
      child: custom_widgets.ErroneousInfoFormWidget(
        width: double.infinity,
        height: MediaQuery.sizeOf(context).height,
        currentLanguage: FFLocalizations.of(context).languageCode,
        translationsCache: FFAppState().translationsCache,
      ),
    );
  }
}
