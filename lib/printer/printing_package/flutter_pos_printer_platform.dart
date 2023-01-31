import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:rest_verision_3/printer/printing_package/printer_config.dart';
import '../../../constants/hive_constants/hive_costants.dart';
import '../../../error_handler/error_handler.dart';
import '../../../screens/login_screen/controller/startup_controller.dart';
import '../../../widget/common_widget/snack_bar.dart';
import 'models/bluetoothPrinter_model.dart';
import 'models/print_responce.dart';

class FlutterPosPrinterPlatform extends GetxController {
  bool showErr = Get.find<StartupController>().showErr;
  final ErrorHandler errHandler = Get.find<ErrorHandler>();

  static List<BluetoothPrinter> devices = <BluetoothPrinter>[];
  static BluetoothPrinter? selectedDeviceForBilling;
  static BluetoothPrinter? selectedDeviceForKot;

  FlutterSecureStorage storage = const FlutterSecureStorage();

  var printerManager = PrinterManager.instance;
  late PrinterType defaultPrinterType;

  StreamSubscription<PrinterDevice>? _subscriptionPrinterDevice;
  StreamSubscription<BTStatus>? _subscriptionBtStatus;

  //Not tested with low energy devices
  var isBle = false;

  //Not tested _reconnect = true
  var reconnect = false;

  // var _isConnected = false;
  BTStatus _currentStatus = BTStatus.none;
  List<int>? pendingTask;

  FlutterPosPrinterPlatform() {
    try {
      if (Platform.isWindows) {
        defaultPrinterType = PrinterType.usb;
      } else {
        defaultPrinterType = PrinterType.bluetooth;
      }

      _subscriptionBtStatus = PrinterManager.instance.stateBluetooth.listen((status) {
        _currentStatus = status;
        if (status == BTStatus.connected) {
          // _isConnected = true;
        }
        if (status == BTStatus.none) {
          // _isConnected = false;
        }
      });
    } catch (e) {
      errHandler.myResponseHandler(error: e.toString(), pageName: 'iosWinPrint', methodName: 'IosWinPrint()');
      return;
    }
  }

  @override
  void onInit() {
    initializeSecureStorage();
    super.onInit();
  }

  void scanDevices() async {
    try {
      //Clearing static variable in each scan
      devices = [];

      _subscriptionPrinterDevice = printerManager.discovery(type: defaultPrinterType, isBle: isBle).listen((device) {
        // print(device.name);
        // print(device.address);
        // print(device.operatingSystem);
        // print(device.productId);
        // print(device.vendorId);
        devices.add(BluetoothPrinter(
          deviceName: device.name,
          address: device.address,
          isBle: isBle,
          vendorId: device.vendorId,
          productId: device.productId,
          typePrinter: defaultPrinterType,
        ));

        update();
      });
    } catch (e) {
      errHandler.myResponseHandler(error: e.toString(), pageName: 'iosWinPrint', methodName: 'getDevices()');
    } finally {}
  }

  void _connectDevice({required BluetoothPrinter? device, required POSPrinterType pOSPrinterType}) async {
    //set as null for automatic selection
    // try {
    //   if (selectedDevice != null && device != null) {
    //     if ((device.address != selectedDevice!.address) || (device.typePrinter == PrinterType.usb && selectedDevice!.vendorId != device.vendorId)) {
    //       await PrinterManager.instance.disconnect(type: selectedDevice!.typePrinter);
    //     }
    //     Get.snackbar("Printer Selected", device.deviceName ?? "");
    //   }
    //   selectedDevice = device;
    // } catch (e) {
    //   errHandler.myResponseHandler(error: e.toString(), pageName: 'iosWinPrint', methodName: 'selectDevice()');
    // }
  }


  Future<void> _disconnect(BluetoothPrinter device) async {
    printerManager.disconnect(type: device.typePrinter);
  }


  Future<void> _connectBtPrinter({required BluetoothPrinter bluetoothPrinter}) async {
    //This fn only used in app start
    try {
      await printerManager.connect(
        type: bluetoothPrinter.typePrinter,
        model: BluetoothPrinterInput(
          name: bluetoothPrinter.deviceName,
          address: bluetoothPrinter.address!,
          isBle: bluetoothPrinter.isBle ?? false,
          autoConnect: reconnect,
        ),
      );
    } catch (e) {
      print('Unable to make pre-connection');
      errHandler.myResponseHandler(error: e.toString(), pageName: 'iosWinPrint', methodName: 'connectBtPrinter()');
      return;
    }
  }

  Future<PrintResponse> printEscPos(List<int> bytes, Generator generator, {POSPrinterType pOSPrinterType = POSPrinterType.billingPrinter}) async {
    try {
      final BluetoothPrinter? printerForPrint;
      if (pOSPrinterType == POSPrinterType.kotPrinter) {
        printerForPrint = selectedDeviceForKot;
      } else {
        printerForPrint = selectedDeviceForBilling;
      }

      if (printerForPrint == null) {
        //TODO alert user
        return PrintResponse(status: false, message: "No printer selected");
      }

      if(Platform.isAndroid){
        //Disconnection is needed in android to switch between two bluetooth printer.
        await _disconnect(printerForPrint);
      }
      // if(Platform.isIOS){
      // //  pre-connection to prevent force stop
      //   await _connectBtPrinter(bluetoothPrinter: printerForPrint);
      // }

      print('Now printing On : ${printerForPrint!.deviceName}');
      print('Printer type is : $pOSPrinterType');

      bool? isConnectedFlag;

      switch (printerForPrint.typePrinter) {
        case PrinterType.usb:
          bytes += generator.feed(2);
          bytes += generator.cut();
          isConnectedFlag = await printerManager.connect(
              type: printerForPrint.typePrinter,
              model: UsbPrinterInput(
                name: printerForPrint.deviceName,
                productId: printerForPrint.productId,
                vendorId: printerForPrint.vendorId,
              ));
          pendingTask = null;
          break;
        case PrinterType.bluetooth:
          bytes += generator.cut();
          isConnectedFlag = await printerManager.connect(
            type: printerForPrint.typePrinter,
            model: BluetoothPrinterInput(
              name: printerForPrint.deviceName,
              address: printerForPrint.address!,
              isBle: printerForPrint.isBle ?? false,
              autoConnect: reconnect,
            ),
          );
          pendingTask = null;
          if (Platform.isAndroid) pendingTask = bytes;
          break;
        default:
      }

      if (Platform.isAndroid && isConnectedFlag == false) {
        return PrintResponse(status: false, message: "Could not connect");
      }

      if (Platform.isIOS) {
        await Future.delayed(const Duration(milliseconds: 1500));
      }

      if (printerForPrint.typePrinter == PrinterType.bluetooth && Platform.isAndroid) {
        if (isConnectedFlag == true) {
          printerManager.send(type: printerForPrint.typePrinter, bytes: bytes);
          pendingTask = null;
          return PrintResponse(status: true, message: "print success");
        } else {
          return PrintResponse(status: false, message: "Bt not connected");
        }
      } else {
        printerManager.send(type: printerForPrint.typePrinter, bytes: bytes);
        return PrintResponse(status: true, message: "print success on IOS | Windows");
      }
    } catch (e) {
      errHandler.myResponseHandler(error: e.toString(), pageName: 'iosWinPrint', methodName: 'printEscPos()');
      return PrintResponse(status: false, message: e.toString());
    }
  }

  void _closeSubscription() {
    _subscriptionPrinterDevice?.cancel();
    _subscriptionBtStatus?.cancel();
  }

  //Save device
  Future savePrinterInSecureStorage(BluetoothPrinter device, POSPrinterType pOSPrinterType) async {
    print(device.deviceName);
    print(pOSPrinterType);
    try {
      if (pOSPrinterType == POSPrinterType.kotPrinter) {
        await storage.write(key: SAVE_KOT_PRINTER, value: jsonEncode(device.toMap()));
        selectedDeviceForKot = device;
      } else {
        await storage.write(key: SAVE_BILLING_PRINTER, value: jsonEncode(device.toMap()));
        selectedDeviceForBilling = device;
      }

      update();
    } catch (e) {
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(), pageName: 'general_settings_ctrl', methodName: 'setPrinterDeviceInHive()');
      return;
    }
  }

//get device
  getPrinterFromSecureStorage(POSPrinterType pOSPrinterType) async {
    try {
      if (pOSPrinterType == POSPrinterType.kotPrinter) {
        String? value = await storage.read(key: SAVE_KOT_PRINTER);
        if (value != null) {
          selectedDeviceForKot = BluetoothPrinter.fromJson(json.decode(value!));
        }
      } else {
        String? value = await storage.read(key: SAVE_BILLING_PRINTER);
        if (value != null) {
          selectedDeviceForBilling = BluetoothPrinter.fromJson(jsonDecode(value!));
        }
      }
      update();
    } catch (e) {
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(), pageName: 'general_settings_ctrl', methodName: 'getPrinterDeviceInHive()');
    }
  }

  initializeSecureStorage() {
    try {
      if (Platform.isAndroid) {
        AndroidOptions getAndroidOptions() => const AndroidOptions(
              encryptedSharedPreferences: true,
            );
        storage = FlutterSecureStorage(aOptions: getAndroidOptions());
      }
    } catch (e) {
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(), pageName: 'startup_controller', methodName: 'initializeSecureStorage()');
      return;
    }
  }
}
