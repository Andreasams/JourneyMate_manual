import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'category_description_sheet_model.dart';
export 'category_description_sheet_model.dart';

class CategoryDescriptionSheetWidget extends StatefulWidget {
  const CategoryDescriptionSheetWidget({
    super.key,
    required this.categoryInformation,
  });

  final dynamic categoryInformation;

  @override
  State<CategoryDescriptionSheetWidget> createState() =>
      _CategoryDescriptionSheetWidgetState();
}

class _CategoryDescriptionSheetWidgetState
    extends State<CategoryDescriptionSheetWidget> {
  late CategoryDescriptionSheetModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CategoryDescriptionSheetModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return custom_widgets.CategoryDescriptionSheet(
      width: double.infinity,
      height: MediaQuery.sizeOf(context).height * 0.45,
      categoryData: widget!.categoryInformation!,
      onClose: () async {
        Navigator.pop(context);
      },
    );
  }
}
