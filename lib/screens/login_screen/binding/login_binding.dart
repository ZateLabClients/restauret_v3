import 'package:get/get.dart';
import 'package:rest_verision_3/error_handler/error_handler.dart';
import 'package:rest_verision_3/repository/flutter_log_repository.dart';

import '../../../hive_database/controller/hive_hold_bill_controller.dart';
import '../../../local_storage/local_storage_controller.dart';
import '../../../printer/controller/print_controller.dart';
import '../../../printer/printing_package/flutter_pos_printer_platform.dart';
import '../../../repository/startup_repository.dart';
import '../../../services/service.dart';
import '../controller/startup_controller.dart';


class LoginBinding implements Bindings {
  @override
  void dependencies() {


    //? services
    Get.put<HttpService>(HttpService(), permanent: true);

    //? log repo
    Get.put<FlutterLogRepo>(FlutterLogRepo(), permanent: true);
    Get.put<ErrorHandler>(ErrorHandler(), permanent: true);

    //? local db controller
    Get.put<HiveHoldBillController>(HiveHoldBillController(),permanent: true);
    Get.put<MyLocalStorage>(MyLocalStorage(),permanent: true);

    //? application startup controller
    Get.put<StartupRepo>(StartupRepo(), permanent: true);
    Get.put<StartupController>(StartupController(), permanent: true);
  //? printer controller
    Get.put<FlutterPosPrinterPlatform>(FlutterPosPrinterPlatform(), permanent: true);
    Get.put<PrintCTRL>(PrintCTRL(), permanent: true);



  }
}
