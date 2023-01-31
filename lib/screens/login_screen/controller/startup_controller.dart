import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rest_verision_3/models/notice_and_update/notice_and_update.dart';
import 'package:rest_verision_3/models/notice_and_update/notice_and_update_response.dart';
import 'package:rest_verision_3/models/shop_response/shop.dart';
import 'package:rest_verision_3/models/shop_response/shop_response.dart';
import 'package:rest_verision_3/repository/flutter_log_repository.dart';
import 'package:rest_verision_3/routes/route_helper.dart';
import 'package:rest_verision_3/widget/common_widget/snack_bar.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../../../alerts/update_notice_alert/update_notice_alert.dart';
import '../../../constants/hive_constants/hive_costants.dart';
import '../../../constants/strings/my_strings.dart';
import '../../../error_handler/error_handler.dart';
import '../../../local_storage/local_storage_controller.dart';
import '../../../models/my_response.dart';
import '../../../printer/printing_package/flutter_pos_printer_platform.dart';
import '../../../printer/printing_package/printer_config.dart';
import '../../../repository/startup_repository.dart';
import '../../../services/service.dart';
import '../../settings_page_screen/controller/settings_controller.dart';

class StartupController extends GetxController {
  final MyLocalStorage _myLocalStorage = Get.find<MyLocalStorage>();
  final StartupRepo _startupRepo = Get.find<StartupRepo>();
  final ErrorHandler errHandler = Get.find<ErrorHandler>();

  final RoundedLoadingButtonController btnControllerLogin = RoundedLoadingButtonController();
  final RoundedLoadingButtonController btnControllerPasswordPrompt = RoundedLoadingButtonController();
  final RoundedLoadingButtonController btnControllerChangePasswordPrompt = RoundedLoadingButtonController();

  //?showError or not in toast
  bool showErr = false;

  //? secure storage for saving token
  FlutterSecureStorage storage = const FlutterSecureStorage();

  //?application mode number its assigned from shared preferences
  int _appModeNumber = 1;

  int get appModeNumber => _appModeNumber;

  //? application type for Rs 300 and Rs 380
  //? 1 full feature app
  //? 2 no waiter and kitchen mode
  int applicationPlan = 2;

  int SHOPE_ID = -1;
  String shopName = 'Restaurant';
  int shopNumber = 0000;
  String shopAddr = 'error';
  String subcId = '0000';
  String subcIdStatus = 'Deactivate';
  DateTime expiryDate = DateTime.now();
  String logoImg = 'https://mobizate.com/uploadsOnlineApp/logo_hotel.png';

  //?  to hide login page while starting app normally
  //? els a small second login screen is showing
  bool showLogin = false;

  //? text-editing controllers
  late TextEditingController subIdTD;
  late TextEditingController passTd;
  late TextEditingController newPassTd;

  //? to get store get ShowDeliveryAddressInBill boll status
  bool setShowDeliveryAddressInBillToggle = true;

  //? to set toggle btn as per saved data
  bool setAllowCreditBookToWaiterToggle = false;

  //? to set toggle btn as per saved data
  bool setAllowPurchaseBookToWaiterToggle = false;

  //? advanced table management mode
  bool advancedTableManagementToggle = true;

  @override
  void onInit() async {
    subIdTD = TextEditingController();
    passTd = TextEditingController();
    newPassTd = TextEditingController();
    await initializeSecureStorage();
    await checkLoginAndAppMode();
    await readShowDeliveryAddressInBillFromHive();
    await readAllowCreditBookToWaiterFromHive();
    await readAllowPurchaseBookToWaiterFromHive();
    await readShowErrorFromHive();
    await readAdvancedTableManagementFromHive();
    checkNoticeAndUpdate();
    checkSubscriptionStatusToLogout();
    _initBtPrinter();
    super.onInit();
  }

  _initBtPrinter() async {
    try {
      Get.find<FlutterPosPrinterPlatform>().getPrinterFromSecureStorage(POSPrinterType.billingPrinter);
      Get.find<FlutterPosPrinterPlatform>().getPrinterFromSecureStorage(POSPrinterType.kotPrinter);
      //Connect Bt printer
      // IosWinPrint iOSWinPrintInstance = IosWinPrint();
      // await iOSWinPrintInstance.getDevices();
      //
      // BluetoothPrinter? bluetoothPrinter = iOSWinPrintInstance.getSelectedDevice();
      // if (bluetoothPrinter != null) {
      //   await iOSWinPrintInstance.connectBtPrinter(bluetoothPrinter: bluetoothPrinter);
      // } else {
      //   if (kDebugMode) {
      //     print('No device selected');
      //   }
      // }
    } catch (e) {
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(), pageName: 'startup_controller', methodName: '_initBtPrinter()');
      return;
    }
  }

  loginToApp() async {
    try {
      Shop shop = await getShop(subIdTD.text);

      if (shop.fdShopId != -1) {
        if (shop.subcIdStatus == 'Active') {
          await setShopInHive(shop);
          btnControllerLogin.success();
          Future.delayed(const Duration(milliseconds: 500), () {
            //? setting app mode 1
            resetAppModeNumberInHive();
            Get.offAllNamed(RouteHelper.getHome());
          });
        } else {
          AppSnackBar.errorSnackBar('Expired', 'Your subscription has expired');
        }
      } else {
        btnControllerLogin.error();
        AppSnackBar.errorSnackBar('Error', 'Cannot login to app !!');
      }
    } catch (e) {
      btnControllerLogin.error();
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(), pageName: 'startup_controller', methodName: 'loginToApp()');
      return;
    } finally {
      Future.delayed(const Duration(seconds: 1), () {
        btnControllerLogin.reset();
      });
    }
  }

  //? get the full shop details when user press submit ntn when login
  Future<Shop> getShop(String subscId) async {
    try {
      MyResponse response = await _startupRepo.getShopDetails(subscId);

      if (response.statusCode == 1) {
        ShopResponse parsedResponse = response.data;
        if (parsedResponse.data == null) {
          return EMPTY_SHOP;
        } else {
          Shop shop = parsedResponse.data ?? EMPTY_SHOP;
          //? updating token inside service for next request
          Get.find<HttpService>().updatingToken(shop.token);
          return shop;
        }
      } else {
        return EMPTY_SHOP;
      }
    } catch (e) {
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(), pageName: 'startup_controller', methodName: 'getShop()');
      return EMPTY_SHOP;
    }
  }

  //? to check  mode of app in every launching
  Future<int> readAppModeInHive() async {
    try {
      int appModeNumberGet = await _myLocalStorage.readData(HIVE_APP_MODE_NUMBER) ?? 1;
      _appModeNumber = appModeNumberGet;
      if (kDebugMode) {
        print('application mode $_appModeNumber');
      }
      update();
      return appModeNumberGet;
    } catch (e) {
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(), pageName: 'startup_controller', methodName: 'readAppModeInHive()');
      return 1;
    }
  }

  //? to set shop details in local db when user login first time
  Future setShopInHive(Shop shop) async {
    try {
      int fdShopId_ = shop.fdShopId ?? -1;
      String shopName_ = shop.shopName ?? 'Restaurant';
      int shopNumber_ = shop.shopNumber ?? 0000;
      String shopAddr_ = shop.shopAddr ?? 'error';
      int applicationPlan_ = shop.applicationPlan ?? 2;
      String subcId_ = shop.subcId ?? '0000';
      String subcIdStatus_ = shop.subcIdStatus ?? 'Deactivate';
      DateTime expiryDate_ = shop.expiryDate ?? DateTime.now();
      String logoImg_ = shop.logoImg ?? 'https://mobizate.com/uploadsOnlineApp/logo_hotel.png';

      Map<String, dynamic> shopToHive = {
        'fdShopId': fdShopId_,
        'shopName': shopName_,
        'shopNumber': shopNumber_,
        'shopAddr': shopAddr_,
        'applicationPlan': applicationPlan_,
        'subcId': subcId_,
        'subcIdStatus': subcIdStatus_,
        'expiryDate': expiryDate_,
        'logoImg': logoImg_,
      };
      await _myLocalStorage.setData(HIVE_SHOP_DETAILS, shopToHive);
      //? store token in secure storage
      await storage.write(key: 'token', value: shop.token ?? 'error');

      //? after saving retrieving details to variable to future use
      Map<dynamic, dynamic>? shopDetails = await _myLocalStorage.readData(HIVE_SHOP_DETAILS);
      if (shopDetails != null) {
        SHOPE_ID = shopDetails['fdShopId'] ?? -1;
        shopName = shopDetails['shopName'] ?? 'Restaurant';
        shopNumber = shopDetails['shopNumber'] ?? 0000;
        shopAddr = shopDetails['shopAddr'] ?? 'error';
        applicationPlan = shopDetails['applicationPlan'] ?? 2;
        subcId = shopDetails['subcId'] ?? '0000';
        subcIdStatus = shopDetails['subcIdStatus'] ?? 'Deactivate';
        expiryDate = shopDetails['expiryDate'] ?? DateTime.now();
        logoImg = shopDetails['logoImg'] ?? 'https://mobizate.com/uploadsOnlineApp/logo_hotel.png';
      }
      if (kDebugMode) {
        print('Shop name $shopName');
      }
      update();
    } catch (e) {
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(), pageName: 'startup_controller', methodName: 'setShopInHive()');
      return;
    }
  }

  //? to check user is longed in or not
  Future readShopDetailsFromHive() async {
    try {
      Map<dynamic, dynamic>? shopDetails = await _myLocalStorage.readData(HIVE_SHOP_DETAILS);

      if (shopDetails != null) {
        SHOPE_ID = shopDetails['fdShopId'] ?? -1;
        shopName = shopDetails['shopName'] ?? 'error';
        shopNumber = shopDetails['shopNumber'] ?? 0000;
        shopAddr = shopDetails['shopAddr'] ?? 'error';
        applicationPlan = shopDetails['applicationPlan'] ?? 2;
        subcId = shopDetails['subcId'] ?? 0000;
        expiryDate = shopDetails['expiryDate'] ?? DateTime.now();
        logoImg = shopDetails['logoImg'] ?? 'https://mobizate.com/uploadsOnlineApp/logo_hotel.png';
        if (kDebugMode) {
          print('shop log in  in as name $shopName - id $shopName - subId $SHOPE_ID - expiate $expiryDate');
        }
        //? updating shop id toErrorHandlerRepo (flutter log repo)
        Get.find<FlutterLogRepo>().updateShopIdWhenAppIsLoaded(SHOPE_ID);

        //? user is already log in then check witch mode od user
        if (SHOPE_ID != -1) {
          //? check app mode and redirect
          if (_appModeNumber == 2) {
            Get.offAllNamed(RouteHelper.getKitchenModeMainScreen());
          } else {
            Get.offAllNamed(RouteHelper.getHome());
          }
        }
      }
      //? user not log in yet
      else {
        if (kDebugMode) {
          print('not login');
        }
        showLogin = true;
      }

      update();
    } catch (e) {
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(), pageName: 'startup_controller', methodName: 'readShopDetailsFromHive()');
      return;
    }
  }

  showPlanExpiryAlert(expiryDate) async {
    try {
      final difference = expiryDate.difference(DateTime.now()).inDays;
      final DateFormat formatter = DateFormat('yyyy-MM-dd');

      if (SHOPE_ID != -1) {
        if (difference > 0 && difference < 5) {
          showNoticeUpdateAlert(
            message: 'Your plan will expired on \n ${formatter.format(expiryDate)}',
            context: Get.context!,
            type: 'notice',
            dismissible: true,
          );
        } else if (difference < 0) {
          showNoticeUpdateAlert(
            message: 'Your plan is expired \n contact your agent to recharge',
            context: Get.context!,
            type: 'notice',
            dismissible: true,
          );
        }
      }
    } catch (e) {
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(), pageName: 'startup_controller', methodName: 'showPlanExpiryAlert()');
      return;
    }
  }

  //? reset appMode in to cashier or  setting app mode 1
  resetAppModeNumberInHive() {
    try {
      _myLocalStorage.setData(HIVE_APP_MODE_NUMBER, 1);
    } catch (e) {
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(), pageName: 'startup_controller', methodName: 'resetAppModeNumberInHive()');
      return;
    }
  }

  //? this will only call app launching because controller is permanent
  checkLoginAndAppMode() async {
    await readAppModeInHive();
    await readShopDetailsFromHive();
  }

  //? this will call when logout from app then it make showLogin = true
  //?  else it will false (controller is permanent , so it will not destroy)
  showLoginScreen() {
    showLogin = true;
    update();
  }

  Future<bool> checkPassword() async {
    try {
      if (passTd.text.trim() != '') {
        MyResponse response = await _startupRepo.getShopDetails(subcId);
        if (response.statusCode == 1) {
          ShopResponse parsedResponse = response.data;
          if (parsedResponse.data == null) {
            AppSnackBar.errorSnackBar('Error', 'Something went wrong !!');
            return false;
          } else {
            Shop shop = parsedResponse.data ?? EMPTY_SHOP;
            if (shop.password == passTd.text) {
              btnControllerPasswordPrompt.success();
              return true;
            } else {
              AppSnackBar.errorSnackBar('Error', 'wrong password !!');
              btnControllerPasswordPrompt.error();
              return false;
            }
          }
        } else {
          AppSnackBar.errorSnackBar('Error', 'Something went wrong !!');
          btnControllerPasswordPrompt.error();
          return false;
        }
      } else {
        AppSnackBar.errorSnackBar('Error', 'pleas fill the field !!');
        return false;
      }
    } catch (e) {
      btnControllerPasswordPrompt.error();
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(), pageName: 'startup_controller', methodName: 'checkPassword()');
      return false;
    } finally {
      passTd.text = '';
      Future.delayed(const Duration(seconds: 1), () {
        btnControllerPasswordPrompt.reset();
      });
      update();
    }
  }

  changePassword({
    required BuildContext context,
    required String subcId,
    required int fdShopId,
    required String password,
    required String newPassword,
  }) async {
    try {
      if (passTd.text.trim() != '') {
        MyResponse response = await _startupRepo.changePassword(subcId, fdShopId, password, newPassword);
        if (response.statusCode == 1) {
          AppSnackBar.successSnackBar('Success', 'Updated successfully');
          btnControllerPasswordPrompt.success();
          Navigator.pop(context);
        } else {
          AppSnackBar.errorSnackBar('Error', 'Something went wrong !!');
          btnControllerPasswordPrompt.error();
        }
      } else {
        AppSnackBar.errorSnackBar('Error', 'pleas fill the field !!');
      }
    } catch (e) {
      btnControllerPasswordPrompt.error();
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(), pageName: 'startup_controller', methodName: 'changePassword()');
      return;
    } finally {
      passTd.text = '';
      newPassTd.text = '';
      Future.delayed(const Duration(seconds: 1), () {
        btnControllerPasswordPrompt.reset();
      });
      update();
    }
  }

  //? to get store get ShowDeliveryAddressInBill boll status as global
  Future<bool> readShowDeliveryAddressInBillFromHive() async {
    try {
      bool result = await _myLocalStorage.readData(HIVE_SHOW_ADDRESS_IN_BILL) ?? true;
      setShowDeliveryAddressInBillToggle = result;
      update();
      return result;
    } catch (e) {
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(), pageName: 'startup_controller', methodName: 'readShowDeliveryAddressInBillFromHive()');
      return true;
    }
  }

  //? to get store get PurchaseBookToWaiter boll status as global
  Future<bool> readAllowPurchaseBookToWaiterFromHive() async {
    try {
      bool result = await _myLocalStorage.readData(ALLOW_PURCHASE_BOOK_TO_WAITER) ?? false;
      setAllowPurchaseBookToWaiterToggle = result;
      update();
      return result;
    } catch (e) {
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(), pageName: 'startup_controller', methodName: 'readAllowPurchaseBookToWaiterFromHive()');
      return false;
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
      errHandler.myResponseHandler(error: e.toString(), pageName: 'startup_controller', methodName: 'readAllowCreditBookToWaiterFromHive()');
      return false;
    }
  }

  Future<bool> readShowErrorFromHive() async {
    try {
      bool result = await _myLocalStorage.readData(SHOW_ERROR) ?? false;
      showErr = result;
      update();
      return result;
    } catch (e) {
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(), pageName: 'startup_controller', methodName: 'readShowErrorFromHive()');
      return false;
    }
  }

  Future<bool> readAdvancedTableManagementFromHive() async {
    try {
      bool result = await _myLocalStorage.readData(ADVANCED_TABLE_MANAGEMENT) ?? false;
      advancedTableManagementToggle = result;
      update();
      return result;
    } catch (e) {
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(), pageName: 'startup_controller', methodName: 'readAdvancedTableManagementFromHive()');
      return false;
    }
  }

  //? get the full shop details when user press submit ntn when login
  Future<NoticeAndUpdate> getNotice() async {
    try {
      MyResponse response = await _startupRepo.getNoticeAndUpdate();

      if (response.statusCode == 1) {
        NoticeAndUpdateResponse parsedResponse = response.data;
        if (parsedResponse.data == null) {
          return EMPTY_NOTICE_UPDATE;
        } else {
          NoticeAndUpdate noticeAndUpdate = parsedResponse.data ?? EMPTY_NOTICE_UPDATE;
          return noticeAndUpdate;
        }
      } else {
        return EMPTY_NOTICE_UPDATE;
      }
    } catch (e) {
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(), pageName: 'startup_controller', methodName: 'getNotice()');
      return EMPTY_NOTICE_UPDATE;
    }
  }

  setNoticeInHive(NoticeAndUpdate noticeAndUpdate, String versionCode, DateTime lastShowingTime) async {
    try {
      Map<String, dynamic> noticeToHive = {
        'noticeUpdateId': noticeAndUpdate.noticeUpdateId,
        'nextShowingDate': noticeAndUpdate.nextShowingDate,
        'lastGetUpdateVersion': versionCode,
        'timeLastShowing': lastShowingTime,
      };
      await _myLocalStorage.setData(HIVE_NOTICE_UPDATE_DETAILS, noticeToHive);
    } catch (e) {
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(), pageName: 'startup_controller', methodName: 'setNoticeInHive()');
      return;
    }
  }

  Future<Map> readNoticeFromHive() async {
    try {
      Map<dynamic, dynamic> noticeDetails = await _myLocalStorage.readData(HIVE_NOTICE_UPDATE_DETAILS) ?? {'noticeUpdateId': -1, 'nextShowingDate': 365};
      return noticeDetails;
    } catch (e) {
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(), pageName: 'startup_controller', methodName: 'readNoticeFromHive()');
      return {'noticeUpdateId': -1, 'nextShowingDate': 365};
    }
  }

  checkNoticeAndUpdate() async {
    try {
      NoticeAndUpdate newNotice = await getNotice();
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String version = packageInfo.version;
      getExtendedVersionNumber(version);

      Map<dynamic, dynamic> noticeFromHive = await readNoticeFromHive();
      //? checking successfully received data from server
      if (newNotice.noticeUpdateId != null && newNotice.noticeUpdateId != -1) {
        //? checking its notice or update
        if (newNotice.type == 'notice') {
          //? checking notice id is grater , then only it showing
          if (newNotice.noticeUpdateId! > (noticeFromHive['noticeUpdateId'])) {
            setNoticeInHive(newNotice, '0.0.0', DateTime.now());
            showNoticeUpdateAlert(
              message: newNotice.message ?? 'Something went wrong',
              context: Get.context!,
              type: newNotice.type ?? 'notice',
              dismissible: newNotice.dismissable ?? true,
            );
          }
        }
        //? checking if its update
        if (newNotice.type == 'update') {
          //? checking inside platform device platform is containing
          if (newNotice.platform!.contains(Platform.operatingSystem)) {
            String versionCodeGet = Platform.isIOS
                ? ((newNotice.version?[0]) ?? '0.0.0')
                : Platform.isAndroid
                    ? ((newNotice.version?[1]) ?? '0.0.0')
                    : ((newNotice.version?[2]) ?? '0.0.0');

            if (kDebugMode) {
              print('versionCodeGet $versionCodeGet');
            }

            //? checking app version is grater  then current user is not updated new version
            if (getExtendedVersionNumber(versionCodeGet) > getExtendedVersionNumber(version)) {
              //? checking pop up already showing before
              if (noticeFromHive['lastGetUpdateVersion'] == versionCodeGet) {
                //? daysBeforeShowing is used to prevent continues popup in next day , its showing only after second day in array
                int daysBeforeShowing = DateTime.now().difference(newNotice.createdAt ?? DateTime.now()).inDays;
                //? lastShowingTime is used to prevent continues popup in same day
                DateTime lastShowingTime = noticeFromHive['timeLastShowing'] ?? DateTime.now();
                int differenceOfTimeLastShowing = DateTime.now().difference(lastShowingTime).inMinutes;
                if (kDebugMode) {
                  print('daysBeforeShowing $daysBeforeShowing');
                  print('differenceOfTimeLastShowing $differenceOfTimeLastShowing');
                }
                //? loop out array of days , then showing if that day exceeded
                for (var element in newNotice.nextShowingDate!) {
                  if (element == daysBeforeShowing) {
                    //? next popup showing only after two hour
                    if (differenceOfTimeLastShowing > (newNotice.timeInterval ?? 120)) {
                      setNoticeInHive(newNotice, versionCodeGet, DateTime.now());
                      showNoticeUpdateAlert(
                        message: newNotice.message ?? 'Something went wrong',
                        context: Get.context!,
                        type: newNotice.type ?? 'notice',
                        dismissible: newNotice.dismissable ?? true,
                      );
                    }
                  }
                }
              } else {
                setNoticeInHive(newNotice, versionCodeGet, DateTime.now());
                showNoticeUpdateAlert(
                  message: newNotice.message ?? 'Something went wrong',
                  context: Get.context!,
                  type: newNotice.type ?? 'notice',
                  dismissible: newNotice.dismissable ?? true,
                );
              }
            }
          }
        }
      }
    } catch (e) {
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(), pageName: 'startup_controller', methodName: 'checkNoticeAndUpdate()');
      return;
    }
  }

  //? to convert verision string to number
  int getExtendedVersionNumber(String version) {
    try {
      List versionCells = version.split('.');
      versionCells = versionCells.map((i) => int.parse(i)).toList();
      return versionCells[0] * 100000 + versionCells[1] * 1000 + versionCells[2];
    } catch (e) {
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(), pageName: 'startup_controller', methodName: 'getExtendedVersionNumber()');
      return 0;
    }
  }

  //? checking checkSubscriptionStatusToLogout and showing expairy popup
  checkSubscriptionStatusToLogout() async {
    try {
      Shop shop = await getShop(subcId);
      //? setting and reading shop details in hive to update values if any changes happened
      //? eg : user is recharged plan and need to update expiry date in profile page
      if (shop.fdShopId != -1) {
        DateTime expiryDate_ = shop.expiryDate ?? DateTime.now();
        showPlanExpiryAlert(expiryDate_);
        if (shop.subcIdStatus == 'Deactivate') {
          //? log out app if its not active
          Get.find<SettingsController>().logOutFromApp();
        }
      }
    } catch (e) {
      String myMessage = showErr ? e.toString() : 'Something wrong !!';
      AppSnackBar.errorSnackBar('Error', myMessage);
      errHandler.myResponseHandler(error: e.toString(), pageName: 'startup_controller', methodName: 'checkSubscriptionStatusToLogout()');
      return;
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
