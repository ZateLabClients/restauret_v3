import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
class BluetoothPrinter {
  int? id;
  String? deviceName;
  String? address;
  String? port;
  String? vendorId;
  String? productId;
  bool? isBle;

  PrinterType typePrinter;
  bool? state;

  BluetoothPrinter({
    this.deviceName,
    this.address,
    this.port,
    this.state,
    this.vendorId,
    this.productId,
    this.typePrinter = PrinterType.bluetooth,
    this.isBle = false,
  });

  Map<String, dynamic> toMap() {
    return {
      "deviceName": deviceName,
      "address": address,
      "port": port,
      "state": state,
      "vendorId": vendorId,
      "productId": productId,
      "typePrinter": typePrinter.index,
      "isBle": isBle,
    };
  }

  factory BluetoothPrinter.fromJson(Map<String, dynamic> parsedJson) {
    return BluetoothPrinter(
        deviceName: parsedJson['deviceName'],
        address: parsedJson['address'],
        port: parsedJson['port'],
        state: parsedJson['state'],
        vendorId: parsedJson['vendorId'],
        productId: parsedJson['productId'],
        typePrinter: PrinterType.values[parsedJson['typePrinter']??0],
        isBle: parsedJson['isBle'] as bool);
  }
}
