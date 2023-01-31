import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as im;
import 'package:screenshot/screenshot.dart';

import '../models/print_responce.dart';
import 'androidPrint.dart';
import 'androidPrintWidgets.dart';
import 'androidPrintenum.dart';

class AndroidPrintExample {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _testPrintForAndroid() async {
    PrintResponse readyForPrint = await AndroidPrint().isReadyForPrint();
    if (readyForPrint.status == true) {
      AndroidPrint.bluetoothInstance.printCustom("AndroidPrint", 1, PAlign.center.val);
      AndroidPrint.bluetoothInstance.printCustom("================", 1, PAlign.center.val);
      await _testPrintScreenShortForAndroid();
      AndroidPrint.bluetoothInstance.printNewLine();
      AndroidPrint.bluetoothInstance.printCustom("----------------", 1, PAlign.center.val);
      AndroidPrint.bluetoothInstance.printCustom("Thank You", 1, PAlign.center.val);
      AndroidPrint.bluetoothInstance.printCustom("----------------", 1, PAlign.center.val);
      AndroidPrint.bluetoothInstance.printNewLine();
    } else {
      print(readyForPrint.message);
    }
  }

  Future _testPrintScreenShortForAndroid() async {
    List<Uint8List> imgList = [];
    Uint8List imageInt = await _screenshotController.captureFromWidget(_androidBillTemplate(), delay: Duration.zero);
    im.Image? receiptImg = im.decodePng(imageInt);

    for (var i = 0; i <= receiptImg!.height; i += 200) {
      im.Image cropedReceiptImg = im.copyCrop(receiptImg, 0, i, 470, 200);
      Uint8List bytes = im.encodePng(cropedReceiptImg) as Uint8List;
      imgList.add(bytes);
    }

    for (var element in imgList) {
      AndroidPrint.bluetoothInstance.printImageBytes(element);
    }
  }

  Widget _androidBillTemplate() {
    return Screenshot(
      controller: _screenshotController,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SizedBox(
          width: 144,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AndroidPrintWidgets.tableRow(items: ['Name', 'Rate', 'Qty', 'Status'], flex: [6, 2, 2, 3], isBold: true),
              const Divider(thickness: 2, color: Colors.black),
              AndroidPrintWidgets.tableRow(items: ['Alfaham Periperi Full with porotta', '240', '1', 'pending'], flex: [6, 2, 1, 3]),
              AndroidPrintWidgets.tableRow(items: ['Alfaham Periperi Full with porotta', '240', '1', 'pending'], flex: [6, 2, 1, 3]),
              AndroidPrintWidgets.tableRow(items: ['Alfaham Periperi Full with porotta', '240', '1', 'pending'], flex: [6, 2, 1, 3]),
              const Divider(thickness: 1, color: Colors.black),
              AndroidPrintWidgets.tableRow(items: ['Total : ', 'Rs: 1520    '], isBold: true),
            ],
          ),
        ),
      ),
    );
  }
}
