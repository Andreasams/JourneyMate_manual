import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'item_bottom_sheet_model.dart';
export 'item_bottom_sheet_model.dart';

class ItemBottomSheetWidget extends StatefulWidget {
  const ItemBottomSheetWidget({
    super.key,
    required this.itemData,
    this.formattedPrice,
    required this.businessName,
    this.formattedVariationPrice,
    required this.hasVariations,
  });

  final dynamic itemData;
  final String? formattedPrice;
  final String? businessName;
  final String? formattedVariationPrice;
  final bool? hasVariations;

  @override
  State<ItemBottomSheetWidget> createState() => _ItemBottomSheetWidgetState();
}

class _ItemBottomSheetWidgetState extends State<ItemBottomSheetWidget> {
  late ItemBottomSheetModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ItemBottomSheetModel());

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
      child: custom_widgets.ItemDetailSheet(
        width: double.infinity,
        height: MediaQuery.sizeOf(context).height * 0.90,
        chosenCurrency: FFAppState().userCurrencyCode,
        originalCurrencyCode: 'DKK',
        exchangeRate: FFAppState().exchangeRate,
        currentLanguage: FFLocalizations.of(context).languageCode,
        businessName: widget!.businessName!,
        formattedPrice: widget!.formattedPrice,
        hasVariations: widget!.hasVariations,
        formattedVariationPrice: widget!.formattedVariationPrice,
        translationsCache: FFAppState().translationsCache,
        itemData: widget!.itemData!,
      ),
    );
  }
}
