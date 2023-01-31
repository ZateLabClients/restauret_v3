import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rest_verision_3/alerts/printer_scan_alert/print_scan_alert_body.dart';
import '../../printer/printing_package/printer_config.dart';
import '../../widget/common_widget/common_text/big_text.dart';


void printerScanAlert({required BuildContext context,required POSPrinterType pOSPrinterType}) {
  try {
    showAnimatedDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:  RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.r))),
          insetPadding: const EdgeInsets.all(0),
          titlePadding: EdgeInsets.all(10.sp),
          contentPadding: EdgeInsets.all(10.sp),
          actionsAlignment: MainAxisAlignment.center,
          title: const Center(child: BigText(text: 'SCAN FOR MENU')),
          content: SingleChildScrollView(child: PrinterScanAlertBody(pOSPrinterType: pOSPrinterType,)),
        );
      },
      animationType: DialogTransitionType.scale,
      curve: Curves.fastOutSlowIn,
      duration: const Duration(milliseconds: 900),
    );
  } catch (e) {
    rethrow;
  }
}