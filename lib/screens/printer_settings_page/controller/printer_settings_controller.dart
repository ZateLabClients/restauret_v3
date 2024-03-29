import 'package:get/get.dart';
import 'package:rest_verision_3/constants/hive_constants/hive_costants.dart';

import '../../../error_handler/error_handler.dart';
import '../../../local_storage/local_storage_controller.dart';
import '../../../widget/common_widget/snack_bar.dart';
import '../../login_screen/controller/startup_controller.dart';

class PrinterSettingsController extends GetxController {
  final MyLocalStorage _myLocalStorage = Get.find<MyLocalStorage>();
  bool showErr  = Get.find<StartupController>().showErr;
  final ErrorHandler errHandler = Get.find<ErrorHandler>();

  //? to set toggle btn as per saved data
  bool setShowDeliveryAddressInBillToggle = true;

  //? to set toggle btn as per saved data
  bool setAllowCreditBookToWaiterToggle = false;

  //? to set toggle btn as per saved data
  bool setAllowPurchaseBookToWaiterToggle = false;

  //? to set toggle btn as per saved data
  bool setShowErrorToggle = false;

  //? to set toggle btn to enable and disable advancedTableManagement
  bool advancedTableManagement = false;

  @override
  void onInit() async {
    await readShowDeliveryAddressInBillFromHive();
    await readAllowCreditBookToWaiterFromHive();
    await readAllowPurchaseBookToWaiterFromHive();
    await readShowError();
    await readAdvancedTableManagement();
    super.onInit();
  }


  //? to set show or hide address in bill in hive
  Future setShowDeliveryAddressInBillInHive(bool showOrHide) async {
    try {
      await _myLocalStorage.setData(HIVE_SHOW_ADDRESS_IN_BILL, showOrHide);
      setShowDeliveryAddressInBillToggle = showOrHide;
      update();
    } catch (e) {
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(),pageName: 'general_settings_ctrl',methodName: 'setShowDeliveryAddressInBillInHive()');
      return;
    }
  }

  //? to set show or hide address in bill in hive
  Future<bool> readShowDeliveryAddressInBillFromHive() async {
    try {
      bool result = await _myLocalStorage.readData(HIVE_SHOW_ADDRESS_IN_BILL) ?? true;
      setShowDeliveryAddressInBillToggle = result;
      update();
      return result;
    } catch (e) {
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(),pageName: 'general_settings_ctrl',methodName: 'readShowDeliveryAddressInBillFromHive()');
      return true;
    }
  }

  //? to set allow or restrict open  creditBook in hive
  Future setAllowCreditBookToWaiter(bool allowCreditBook) async {
    try {
      await _myLocalStorage.setData(ALLOW_CREDIT_BOOK_TO_WAITER, allowCreditBook);
      setAllowCreditBookToWaiterToggle = allowCreditBook;
      //? to update globe variable
      Get.find<StartupController>().readAllowCreditBookToWaiterFromHive();
      update();
    } catch (e) {
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(),pageName: 'general_settings_ctrl',methodName: 'setAllowCreditBookToWaiter()');
      return;
    }
  }

  Future<bool> readAllowCreditBookToWaiterFromHive() async {
    try {
      bool result = await _myLocalStorage.readData(ALLOW_CREDIT_BOOK_TO_WAITER) ?? false;
      setAllowCreditBookToWaiterToggle = result;
      update();
      return result;
    } catch (e) {
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(),pageName: 'general_settings_ctrl',methodName: 'readAllowCreditBookToWaiterFromHive()');
      return false;
    }
  }

  //? to set allow or restrict open  purchaseBook in hive
  Future setAllowPurchaseBookToWaiter(bool allowPurchaseBook) async {
    try {
      await _myLocalStorage.setData(ALLOW_CREDIT_BOOK_TO_WAITER, allowPurchaseBook);
      setAllowPurchaseBookToWaiterToggle = allowPurchaseBook;
      //? to update globe variable
      Get.find<StartupController>().readAllowPurchaseBookToWaiterFromHive();
      update();
    } catch (e) {
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(),pageName: 'general_settings_ctrl',methodName: 'setAllowPurchaseBookToWaiter()');
      return;
    }
  }

  Future<bool> readAllowPurchaseBookToWaiterFromHive() async {
    try {
      bool result = await _myLocalStorage.readData(ALLOW_PURCHASE_BOOK_TO_WAITER) ?? false;
      setAllowPurchaseBookToWaiterToggle = result;
      update();
      return result;
    } catch (e) {
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(),pageName: 'general_settings_ctrl',methodName: 'setShowDeliveryAddressInBillInHive()');
      return false;
    }
  }


  //? to set show error in hive
  Future setShowError(bool showError) async {
    try {
      await _myLocalStorage.setData(SHOW_ERROR, showError);
      setShowErrorToggle = showError;
      Get.find<StartupController>().readShowErrorFromHive();
      update();
    } catch (e) {
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(),pageName: 'general_settings_ctrl',methodName: 'setShowError()');
      return;
    }
  }

  Future<bool> readShowError() async {
    try {
      bool result = await _myLocalStorage.readData(SHOW_ERROR) ?? false;
      setShowErrorToggle = result;
      update();
      return result;
    } catch (e) {
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(),pageName: 'general_settings_ctrl',methodName: 'readShowError()');
      return false;
    }
  }

  //? to set advancedTableManagement mode in hive
  Future setAdvancedTableManagement(bool tableManagement) async {
    try {
      await _myLocalStorage.setData(ADVANCED_TABLE_MANAGEMENT, tableManagement);
      advancedTableManagement = tableManagement;
      //? to update global variable
      Get.find<StartupController>().readAdvancedTableManagementFromHive();
      update();
    } catch (e) {
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(),pageName: 'general_settings_ctrl',methodName: 'setAdvancedTableManagement()');
      return;
    }
  }

  Future<bool> readAdvancedTableManagement() async {
    try {
      bool result = await _myLocalStorage.readData(ADVANCED_TABLE_MANAGEMENT) ?? false;
      advancedTableManagement = result;
      update();
      return result;
    } catch (e) {
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(),pageName: 'general_settings_ctrl',methodName: 'setAdvancedTableManagement()');
      return false;
    }
  }

}