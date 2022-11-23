import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rest_verision_3/constants/app_secret_constants/app_secret_constants.dart';
import 'package:rest_verision_3/constants/strings/my_strings.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../../alerts/kitchen_ring_popup_alert/kitchen_popup_ring_alert.dart';
import '../../../../check_internet/check_internet.dart';
import '../../../../constants/api_link/api_link.dart';
import '../../../../constants/hive_constants/hive_costants.dart';
import '../../../../local_storage/local_storage_controller.dart';
import '../../../../models/foods_response/food_response.dart';
import '../../../../models/kitchen_order_response/kitchen_order.dart';
import '../../../../models/kitchen_order_response/kitchen_order_array.dart';
import '../../../../routes/route_helper.dart';
import '../../../../services/dio_error.dart';
import '../../../../services/service.dart';
import '../../../../socket/socket_controller.dart';
import '../../../../widget/common_widget/snack_bar.dart';
import '../../../login_screen/controller/startup_controller.dart';


class KitchenModeMainController extends GetxController {
  final IO.Socket _socket = Get.find<SocketController>().socket;
  final HttpService _httpService = Get.find<HttpService>();
  final MyLocalStorage _myLocalStorage = Get.find<MyLocalStorage>();
  bool isLoading = false;

  //? to chane tapped color of order status tab
  int tappedIndex = 0;
  String tappedTabName = PENDING;

  //? this will change as per clicking tab
  //? when click pending it assign pending kots
  //? if click ready it assign ready Kot's and this list is showing in UI
  final List<KitchenOrder> _kotBillingItems = [];
  List<KitchenOrder> get kotBillingItems => _kotBillingItems;

  //? this one to showing  store all KOT in ALL KOT TAB
  List<KitchenOrder> _allKotBillingItems = [];
  List<KitchenOrder> get allKotBillingItems => _allKotBillingItems;

  //? to set kot ring sound silent or general
  bool kotRingSound = true;

  //? to set  remember alert sound silent or general
  bool ringRememberAlertSound = true;

  RoundedLoadingButtonController btnControllerUpdateFullKotSts = RoundedLoadingButtonController();
  RoundedLoadingButtonController btnControllerProgressUpdateFullKotSts = RoundedLoadingButtonController();
  RoundedLoadingButtonController btnControllerReadyUpdateFullKotSts = RoundedLoadingButtonController();
  RoundedLoadingButtonController btnControllerPendingUpdateFullKotSts = RoundedLoadingButtonController();
  RoundedLoadingButtonController btnControllerRejectUpdateFullKotSts = RoundedLoadingButtonController();


  final player = AudioPlayer();
  final cache = AudioCache();

  @override
  void onInit() async {
    checkInternetConnection();
    _socket.connect();
    //? to listen new kot ring reminding
    setNewKotRingRemember();
    //? for loading all kot
    setUpKitchenOrderFromDbListener();
    //?for new kot order
    setUpKitchenOrderSingleListener();
    //? kot ring sound silent or general
    await readNewKotRingSound();
    //? to set  remember alert sound silent or general
    await readRingRememberAlert();
    print('sound $ringRememberAlertSound');
    super.onInit();
  }

  @override
  void onClose() {
    _socket.close();
    _socket.dispose();
    super.onClose();
  }

  //? for single order adding live
  setUpKitchenOrderSingleListener() {
    try {
      KitchenOrder order = EMPTY_KITCHEN_ORDER;
      _socket.on('kitchen_orders_receive', (data) async {
        if (kDebugMode) {
          print('kot order single rcv');
          //? assign single KOT to order variable
          order = KitchenOrder.fromJson(data);
          //?no error
          bool err = order.error ?? true;
        if (!err) {
          //? check if item is already in list
          bool isExist = true;
          for (var element in _allKotBillingItems) {
            if (element.Kot_id != order.Kot_id) {
              isExist = false;
            } else {
              isExist = true;
            }
          }
          //? add if not exist
          if (isExist == false) {
            _allKotBillingItems.insert(0, order);
            updateKotItemsAsPerTab();
            ringOrderAlert();
          } else {
            //? nothing will happened
          }
            _allKotBillingItems = _allKotBillingItems;
          }
          update();
        } else {
          return;
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  //? for first load data to bill from data base
  setUpKitchenOrderFromDbListener() {
    try {
      KitchenOrderArray order = KitchenOrderArray(error: true, errorCode: '', totalSize: 0);
      _socket.on('database-data-receive', (data) {
        if (kDebugMode) {
          print('kot socket database refresh');
        }

        //? this is not single KOT order , its list of orders
        order = KitchenOrderArray.fromJson(data);
        List<KitchenOrder>? kitchenOrders = order.kitchenOrder;
        //? no error
        bool err = order.error;
        if (!err) {
          //?check if item is already in list
          _allKotBillingItems.clear();
          _allKotBillingItems
              .addAll(kitchenOrders!.where((newItem) => _allKotBillingItems.every((oldItem) => newItem.Kot_id != oldItem.Kot_id)));
          //?to update all items items in all tab
          updateKotItemsAsPerTab();
          update();
        } else {
          return;
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  //? this emit will receive and emit from server to refresh data
  //? used to refresh data
  refreshDatabaseKot() {
    _socket.emit('refresh-database-order');
  }

  //? te get witch tab is selected
  updateTappedTabName(String name) {
    if (kDebugMode) {
      print(name);
    }
    tappedTabName = name;
    update();
  }

  //?to change tapped category
  setStatusTappedIndex(int val) {
    tappedIndex = val;
    update();
  }

  updateKotItemsAsPerTab() {
    if (kDebugMode) {
      print('tappedTabName $tappedTabName');
    }
    if (tappedTabName == PENDING) {
      _kotBillingItems.clear();
      for (var element in _allKotBillingItems) {
        if(element.fdOrderStatus == PENDING){
          _kotBillingItems.add(element);
        }
      }
      update();
    } else if (tappedTabName == PROGRESS) {
      _kotBillingItems.clear();
      for (var element in _allKotBillingItems) {
        if(element.fdOrderStatus == PROGRESS){
          _kotBillingItems.add(element);
        }
      }
      update();
    } else if (tappedTabName == READY) {
      _kotBillingItems.clear();
      for (var element in _allKotBillingItems) {
        if (element.fdOrderStatus == READY) {
          _kotBillingItems.add(element);
        }
      }
      update();
    } else if (tappedTabName == REJECT) {
      _kotBillingItems.clear();
      for (var element in _allKotBillingItems) {
        if (element.fdOrderStatus == REJECT) {
          _kotBillingItems.add(element);
        }
      }
      update();
    } else {
      _kotBillingItems.clear();
      _kotBillingItems.addAll(_allKotBillingItems);
      update();
    }
  }

  //?update full order status to server
  Future updateFullOrderStatus({required BuildContext context, required int kotId, required String fdOrderStatus}) async {
    try {
      //? setting progress btn controller
      if (fdOrderStatus == PROGRESS) {
        btnControllerUpdateFullKotSts = btnControllerProgressUpdateFullKotSts;
      } else if (fdOrderStatus == READY) {
        btnControllerUpdateFullKotSts = btnControllerReadyUpdateFullKotSts;
      } else if (fdOrderStatus == PENDING) {
        btnControllerUpdateFullKotSts = btnControllerPendingUpdateFullKotSts;
      } else if (fdOrderStatus == REJECT) {
        btnControllerUpdateFullKotSts = btnControllerRejectUpdateFullKotSts;
      } else {
        btnControllerUpdateFullKotSts = btnControllerPendingUpdateFullKotSts;
      }

      Map<String, dynamic> kotOrderStatusUpdate = {'fdShopId': Get.find<StartupController>().SHOPE_ID, 'Kot_id': kotId, 'fdOrderStatus': fdOrderStatus};
      final response = await _httpService.updateData(UPDATE_FULL_ORDER_STATUS, kotOrderStatusUpdate);

      FoodResponse parsedResponse = FoodResponse.fromJson(response.data);
      if (parsedResponse.error ?? true) {
        btnControllerUpdateFullKotSts.error();
        AppSnackBar.errorSnackBar('Error', parsedResponse.errorCode ?? 'Error');
      } else {
        btnControllerUpdateFullKotSts.success();
        AppSnackBar.successSnackBar('Success', parsedResponse.errorCode ?? 'Error');
        //? to refresh and emit new data from db
        refreshDatabaseKot();
        update();
      }
    } on DioError catch (e) {
      btnControllerUpdateFullKotSts.error();
      AppSnackBar.errorSnackBar('Error', MyDioError.dioError(e));
    } catch (e) {
      btnControllerUpdateFullKotSts.error();
    } finally {
      Future.delayed(const Duration(seconds: 1), () {
        btnControllerUpdateFullKotSts.reset();
      });
      Navigator.pop(context);
      update();
    }
  }

  //? update single order status
  Future updateSingleOrderStatus({
    required BuildContext context,
    required int kotId,
    required int fdOrderIndex,
    required String fdOrderSingleStatus,
    required RoundedLoadingButtonController btnControllerUpdateSingleKotSts
  }) async {
    try {

      Map<String, dynamic> kotOrderSingleStatusUpdate = {
        'fdShopId': Get.find<StartupController>().SHOPE_ID,
        'Kot_id': kotId,
        'fdOrderIndex': fdOrderIndex,
        'fdOrderSingleStatus': fdOrderSingleStatus,
      };
      final response = await _httpService.updateData(UPDATE_SINGLE_ORDER_STATUS, kotOrderSingleStatusUpdate);

      FoodResponse parsedResponse = FoodResponse.fromJson(response.data);
      if (parsedResponse.error ?? true) {
        btnControllerUpdateSingleKotSts.error();
        AppSnackBar.errorSnackBar('Error', parsedResponse.errorCode ?? 'Error');
      } else {
        btnControllerUpdateSingleKotSts.success();
        AppSnackBar.successSnackBar('Success', parsedResponse.errorCode ?? 'error');
        refreshDatabaseKot();
        update();
      }
    } on DioError catch (e) {
      btnControllerUpdateSingleKotSts.error();
      AppSnackBar.errorSnackBar('Error', MyDioError.dioError(e));
    } catch (e) {
      btnControllerUpdateSingleKotSts.error();
    } finally {
      Future.delayed(const Duration(seconds: 1), () {
        btnControllerUpdateSingleKotSts.reset();
      });
      // Navigator.pop(context);
      update();
    }
  }

  showLoading() {
    isLoading = true;
  }

  hideLoading() {
    isLoading = false;
  }

  //? to ring on new order
  Future<void> ringOrderAlert() async {
    //? checking user is make it silent or not
    if(kotRingSound){
      if (kDebugMode) {
        print('ring sound');
      }
      await player.setSource(AssetSource('sounds/ring_two.mp3'));
      await player.resume();
    }
  }

  //? to ring when remember alert
  Future<void> ringRememberAlert() async {
    //? check user is turned off alert sound
    if(ringRememberAlertSound){
      if (kDebugMode) {
        print('ring remember sound');
      }
      await player.setSource(AssetSource('sounds/alert.mp3'));
      await player.resume();
    }
  }

  //? for single order adding live
  //? when remember kot alert this socket is listening
  setNewKotRingRemember() {
    try {
      _socket.on('for-ring-to-kitchen', (data) async {
        if (kDebugMode) {
          print('ring kot $data');
        }
        //?show popup
        KitchenOrder kitchenOrder = EMPTY_KITCHEN_ORDER;
        for (var element in _allKotBillingItems) {
          if (element.Kot_id == data) {
            kitchenOrder = element;
            break;
          }
        }
        kitchenRingPopupAlert(kitchenOrder);
        //?make sound
        ringRememberAlert();
      });
    } catch (e) {
      rethrow;
    }
  }


  //? to logOut from app
  logOutFromApp() {
    try {
      //? clearing login information of shop in hive and clear app mode number
      _myLocalStorage.removeData(HIVE_APP_MODE_NUMBER);
      _myLocalStorage.removeData(HIVE_SHOP_DETAILS);
      Get.find<StartupController>().subIdTD.text ='';
      Get.find<StartupController>().showLoginScreen();
      Get.offAllNamed(RouteHelper.getInitial());
    } catch (e) {
      rethrow;
    }
  }


  //? reset appMode in to cashier or  setting app mode 1 when user exit from kitchen mode
  resetAppModeNumberInHive() {
    try {
      _myLocalStorage.setData(HIVE_APP_MODE_NUMBER, 1);
    } catch (e) {
      rethrow;
    }
  }


  //? to set kot ring sound silent or general
  Future setNewKotRingSound(bool sound) async {
    try {
      await _myLocalStorage.setData(HIVE_KOT_RING_SOUND, sound);
      kotRingSound = sound;
      update();
    } catch (e) {
      rethrow;
    }
  }

  //? to read kot ring sound silent or general
  Future<bool> readNewKotRingSound() async {
    try {
      bool result = await _myLocalStorage.readData(HIVE_KOT_RING_SOUND) ?? true;
      kotRingSound = result;
      update();
      return result;
    } catch (e) {
      rethrow;
    }
  }

  //? to set  ring remember sound silent or general
  Future setRingRememberAlert(bool sound) async {
    try {
      await _myLocalStorage.setData(HIVE_KOT_REMEMBER_RING_SOUND, sound);
      ringRememberAlertSound = sound;
      update();
    } catch (e) {
      rethrow;
    }
  }

  //? to read  ring remember sound silent or general
  Future<bool> readRingRememberAlert() async {
    try {
      bool result = await _myLocalStorage.readData(HIVE_KOT_REMEMBER_RING_SOUND) ?? true;
      ringRememberAlertSound = result;
      update();
      return result;
    } catch (e) {
      rethrow;
    }
  }


}