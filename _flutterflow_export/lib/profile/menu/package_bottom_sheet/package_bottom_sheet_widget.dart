import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package_bottom_sheet_model.dart';
export 'package_bottom_sheet_model.dart';

class PackageBottomSheetWidget extends StatefulWidget {
  const PackageBottomSheetWidget({
    super.key,
    required this.packageData,
    required this.packageId,
    required this.businessName,
  });

  final dynamic packageData;
  final int? packageId;
  final String? businessName;

  @override
  State<PackageBottomSheetWidget> createState() =>
      _PackageBottomSheetWidgetState();
}

class _PackageBottomSheetWidgetState extends State<PackageBottomSheetWidget> {
  late PackageBottomSheetModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PackageBottomSheetModel());

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
      height: MediaQuery.sizeOf(context).height * 0.90,
      child: custom_widgets.PackageNavigationSheet(
        width: double.infinity,
        height: MediaQuery.sizeOf(context).height * 0.90,
        packageId: widget!.packageId!,
        chosenCurrency: FFAppState().userCurrencyCode,
        originalCurrencyCode: 'DKK',
        exchangeRate: FFAppState().exchangeRate,
        normalizedMenuData: widget!.packageData!,
        currentLanguage: FFLocalizations.of(context).languageCode,
        businessName: widget!.businessName!,
        translationsCache: FFAppState().translationsCache,
      ),
    );
  }
}
