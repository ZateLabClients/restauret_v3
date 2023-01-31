import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../printer/controller/print_controller.dart';
import '../../printer/printing_package/flutter_pos_printer_platform.dart';
import '../../printer/printing_package/models/bluetoothPrinter_model.dart';
import '../../printer/printing_package/printer_config.dart';

class PrinterScanAlertBody extends StatelessWidget {
  final POSPrinterType pOSPrinterType;

  const PrinterScanAlertBody({Key? key, required this.pOSPrinterType}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    bool horizontal = 1.sh < 1.sw ? true : false;
    Get.find<FlutterPosPrinterPlatform>().getPrinterFromSecureStorage(pOSPrinterType);
    Get.find<FlutterPosPrinterPlatform>().scanDevices();

    return GetBuilder<FlutterPosPrinterPlatform>(builder: (ctrl) {

      final BluetoothPrinter? selectedDevice;

      if (pOSPrinterType == POSPrinterType.kotPrinter) {
        selectedDevice= FlutterPosPrinterPlatform.selectedDeviceForKot;
      } else {
        selectedDevice= FlutterPosPrinterPlatform.selectedDeviceForBilling;
      }

      List<BluetoothPrinter> devices = FlutterPosPrinterPlatform.devices;

      return SizedBox(
          width: horizontal ? 0.3.sw : 1.sw * 0.6,
          child:

          Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(devices.length, (index) {

              final Widget? trailing;
              if (selectedDevice != null && selectedDevice!.deviceName == (devices[index].deviceName ?? "")) {
                trailing = Icon(Icons.check);
              } else {
                trailing = null;
              }

              return ListTile(
                title: Text(devices[index].deviceName ?? ""),
                trailing: trailing,
                leading: Text("${index + 1}"),
                onTap: () {
                  // c.selectDevice(devices[index]);

                  ctrl.savePrinterInSecureStorage(devices[index], pOSPrinterType);
                },
              );
            }),
          )

      );
    });
  }
}
