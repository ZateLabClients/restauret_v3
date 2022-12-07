import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:rest_verision_3/constants/app_secret_constants/app_secret_constants.dart';

import '../constants/api_link/api_link.dart';
import '../models/foods_response/food_response.dart';
import '../models/my_response.dart';
import '../screens/login_screen/controller/startup_controller.dart';
import '../services/dio_error.dart';
import '../services/service.dart';

//? this repository call  all the data from api and store MyResponse the variable
class FoodRepo extends GetxService {
  final HttpService _httpService = Get.find<HttpService>();

  //? get todayFood
  Future<MyResponse> getTodayFoods() async {
    // TODO: implement getNewsHeadline
    try {
      final response = await _httpService.getRequestWithBody(TODAY_FOOD_URL, {'fdShopId': Get.find<StartupController>().SHOPE_ID});
      FoodResponse? parsedResponse = FoodResponse.fromJson(response.data);
      if (parsedResponse.error ?? true) {
        return MyResponse(statusCode: 0, status: 'Error', data: null, message: response.statusMessage.toString());
      } else {
        return MyResponse(statusCode: 1, status: 'Success', data: parsedResponse, message: response.statusMessage.toString());
      }
    } on DioError catch (e) {
      return MyResponse(statusCode: 0, status: 'Error', message: MyDioError.dioError(e));
    } catch (e) {
      return MyResponse(statusCode: 0, status: 'Error', message: 'Error');
    }
  }

  //? getALl food
  Future<MyResponse> getAllFoods() async {
    // TODO: implement getNewsHeadline

    try {
      final response = await _httpService.getRequestWithBody(ALL_FOOD_URL, {'fdShopId': Get.find<StartupController>().SHOPE_ID});
      FoodResponse? parsedResponse = FoodResponse.fromJson(response.data);
      if (parsedResponse.error ?? true) {
        return MyResponse(statusCode: 0, status: 'Error', data: null, message: response.statusMessage.toString());
      } else {
        return MyResponse(statusCode: 1, status: 'Success', data: parsedResponse, message: response.statusMessage.toString());
      }
    } on DioError catch (e) {
      return MyResponse(statusCode: 0, status: 'Error', message: MyDioError.dioError(e));
    } catch (e) {
      return MyResponse(statusCode: 0, status: 'Error', message: e.toString());
    }
  }

  //? search today food
  //! need add shopId for retrieving foods
  //! currently it not used now using search from local data
  Future<MyResponse> searchTodayFoods({required int fdShopId, required String query, required String fdIsToday}) async {
    // TODO: implement getNewsHeadline

    try {
      //? fdIsToday has no effect working based in server side
      final response = await _httpService.getRequestWithBody(SEARCH_TODAY_FOOD, {'fdName': query, 'fdIsToday': fdIsToday});
      FoodResponse? parsedResponse = FoodResponse.fromJson(response.data);
      return MyResponse(statusCode: 1, status: 'Success', data: parsedResponse, message: response.statusMessage.toString());
    } on DioError catch (e) {
      return MyResponse(statusCode: 0, status: 'Error', message: MyDioError.dioError(e));
    } catch (e) {
       return MyResponse(statusCode: 0, status: 'Error', message: 'Error');
    }
  }

  //? search all food
  //! need add shopId for retrieving foods
  //! currently it not used now using search from local data
  Future<MyResponse> searchAllFoods({required int fdShopId, required String query, required String fdIsToday}) async {
    // TODO: implement getNewsHeadline

    try {
      //? fdIsToday has no effect work based on server side
      final response = await _httpService.getRequestWithBody(SEARCH_ALL_FOOD, {'fdName': query, 'fdIsToday': fdIsToday});
      FoodResponse? parsedResponse = FoodResponse.fromJson(response.data);
      return MyResponse(statusCode: 1, status: 'Success', data: parsedResponse, message: response.statusMessage.toString());
    } on DioError catch (e) {
      return MyResponse(statusCode: 0, status: 'Error', message: MyDioError.dioError(e));
    } catch (e) {
      rethrow;
      // return MyResponse(statusCode: 0, status: 'Error', message: 'Error');
    } finally {}
  }

  //? update today food
  Future<MyResponse> updateTodayFood(int fdId, String isToday) async {
    try {
      Map<String, dynamic> foodData = {'fdId': fdId, 'fdIsToday': isToday, 'fdShopId': Get.find<StartupController>().SHOPE_ID};
      final response = await _httpService.updateData(TODAY_FOOD_UPDATE, foodData);
      FoodResponse parsedResponse = FoodResponse.fromJson(response.data);
      if (parsedResponse.error ?? true) {
        return MyResponse(statusCode: 0, status: 'Error', message: SHOW_ERR ? response.statusMessage.toString() : 'Something wrong !!');
      } else {
        return MyResponse(statusCode: 1, status: 'Success', message: response.statusMessage.toString());
      }
    } on DioError catch (e) {
      return MyResponse(statusCode: 0, status: 'Error', message: SHOW_ERR ? MyDioError.dioError(e) : 'Something wrong !!');
    } catch (e) {
      return MyResponse(statusCode: 0, status: 'Error', message: SHOW_ERR ? e.toString() : 'Something wrong !!');
    }
  }

  //? update quickBill food
  Future<MyResponse> updateQuickBillFood(int fdId, String isQuick) async {
    try {
      Map<String, dynamic> foodData = {'fdId': fdId, 'fdIsQuick': isQuick, 'fdShopId': Get.find<StartupController>().SHOPE_ID};
      final response = await _httpService.updateData(QUICK_FOOD_UPDATE, foodData);
      FoodResponse parsedResponse = FoodResponse.fromJson(response.data);
      if (parsedResponse.error ?? true) {
        return MyResponse(statusCode: 0, status: 'Error', message: SHOW_ERR ? response.statusMessage.toString() : 'Something wrong !!');
      } else {
        return MyResponse(statusCode: 1, status: 'Success', message: response.statusMessage.toString());
      }
    } on DioError catch (e) {
      return MyResponse(statusCode: 0, status: 'Error', message: SHOW_ERR ? MyDioError.dioError(e) : 'Something wrong !!');
    } catch (e) {
      return MyResponse(statusCode: 0, status: 'Error', message: SHOW_ERR ? e.toString() : 'Something wrong !!');
    }
  }

  //? delete food
  deleteFood(int id) async {
    try {
      Map<String, dynamic> foodData = {
        'fdShopId': Get.find<StartupController>().SHOPE_ID,
        'fdId': id,
      };
      final response = await _httpService.delete(DELETE_FOOD, foodData);
      FoodResponse parsedResponse = FoodResponse.fromJson(response.data);
      if (parsedResponse.error ?? true) {
        return MyResponse(statusCode: 0, status: 'Error', message: SHOW_ERR ? response.statusMessage.toString() : 'Something wrong !!');
      } else {
        return MyResponse(statusCode: 1, status: 'Success', message: response.statusMessage.toString());
      }
    } on DioError catch (e) {
      return MyResponse(statusCode: 0, status: 'Error', message: SHOW_ERR ? MyDioError.dioError(e) : 'Something wrong !!');
    } catch (e) {
      return MyResponse(statusCode: 0, status: 'Error', message: SHOW_ERR ? e.toString() : 'Something wrong !!');
    }
  }


  //? insert food
  Future<MyResponse> insertFood({
    File? file,
    required fdName,
    required fdCategory,
    required fdPrice,
    required fdThreeBiTwoPrsPrice,
    required fdHalfPrice,
    required fdQtrPrice,
    required fdIsLoos,
    required cookTime,
  }) async {
    // TODO: implement getNewsHeadline

    try {
      final response = await _httpService.insertFood(
        fdShopId: Get.find<StartupController>().SHOPE_ID,
        file: file,
        fdName: fdName,
        fdCategory: fdCategory,
        fdPrice: fdPrice,
        fdThreeBiTwoPrsPrice: fdThreeBiTwoPrsPrice,
        fdHalfPrice: fdHalfPrice,
        fdQtrPrice: fdQtrPrice,
        fdIsLoos: fdIsLoos,
        cookTime: cookTime,
      );
      FoodResponse parsedResponse = FoodResponse.fromJson(response.data);
      if (parsedResponse.error ?? true) {
        return MyResponse(statusCode: 0, status: 'Error', message: SHOW_ERR ? response.statusMessage.toString() : 'Something wrong !!');
      } else {
        return MyResponse(statusCode: 1, status: 'Success', data: parsedResponse, message: parsedResponse.errorCode ?? 'Error');
      }
    } on DioError catch (e) {
      return MyResponse(statusCode: 0, status: 'Error', message: SHOW_ERR ? MyDioError.dioError(e) : 'Something wrong !!');
    } catch (e) {
      return MyResponse(statusCode: 0, status: 'Error', message: SHOW_ERR ?  e.toString() : 'Something wrong !!');
    }
  }

  //? it update food
  Future<MyResponse> updateFood(
      {File? file,
        required fdName,
        required fdCategory,
        required fdPrice,
        required fdThreeBiTwoPrsPrice,
        required fdHalfPrice,
        required fdQtrPrice,
        required fdIsLoos,
        required cookTime,
        required fdImg,
        required fdIsToday,
        required id}) async {
    // TODO: implement getNewsHeadline

    try {
      final response = await _httpService.updateFood(
        file: file,
        fdName: fdName,
        fdCategory: fdCategory,
        fdPrice: fdPrice,
        fdThreeBiTwoPrsPrice: fdThreeBiTwoPrsPrice,
        fdHalfPrice: fdHalfPrice,
        fdQtrPrice: fdQtrPrice,
        fdIsLoos: fdIsLoos,
        cookTime: cookTime,
        fdShopId: Get.find<StartupController>().SHOPE_ID,
        fdImg: fdImg,
        fdIsToday: fdIsToday,
        fdId: id,
      );
      FoodResponse parsedResponse = FoodResponse.fromJson(response.data);
      if (parsedResponse.error ?? true) {
        return MyResponse(statusCode: 0, status: 'Error', message: SHOW_ERR ? response.statusMessage.toString() : 'Something wrong !!');
      } else {
        return MyResponse(statusCode: 1, status: 'Success', data: parsedResponse, message: parsedResponse.errorCode ?? 'Error');
      }
    } on DioError catch (e) {
      return MyResponse(statusCode: 0, status: 'Error', message: SHOW_ERR ? MyDioError.dioError(e) : 'Something wrong !!');
    }catch (e){
      return MyResponse(statusCode: 0, status: 'Error', message: SHOW_ERR ? e.toString(): 'Something wrong !!');
    }

  }


  //? update available food
  Future<MyResponse> updateAvailableFood(int fdId, String isAvailable) async {
    try {
      Map<String, dynamic> foodData = {'fdId': fdId, 'fdIsAvailable': isAvailable, 'fdShopId': Get.find<StartupController>().SHOPE_ID};
      final response = await _httpService.updateData(AVAILABLE_FOOD_UPDATE, foodData);
      FoodResponse parsedResponse = FoodResponse.fromJson(response.data);
      print('erroor ${parsedResponse.errorCode}');
      if (parsedResponse.error ?? true) {
        return MyResponse(statusCode: 0, status: 'Error', message: SHOW_ERR ? response.statusMessage.toString() : 'Something wrong !!');
      } else {
        return MyResponse(statusCode: 1, status: 'Success', message: response.statusMessage.toString());
      }
    } on DioError catch (e) {
      return MyResponse(statusCode: 0, status: 'Error', message: SHOW_ERR ? MyDioError.dioError(e) : 'Something wrong !!');
    } catch (e) {
      return MyResponse(statusCode: 0, status: 'Error', message: SHOW_ERR ? e.toString() : 'Something wrong !!');
    }
  }

  //? update special food
  Future<MyResponse> updateSpecialFood(int fdId, String isSpecial) async {
    try {
      Map<String, dynamic> foodData = {'fdId': fdId, 'fdIsSpecial': isSpecial, 'fdShopId': Get.find<StartupController>().SHOPE_ID};
      final response = await _httpService.updateData(SPECIAL_FOOD_UPDATE, foodData);
      FoodResponse parsedResponse = FoodResponse.fromJson(response.data);
      print('erroor ${parsedResponse.errorCode}');
      if (parsedResponse.error ?? true) {
        return MyResponse(statusCode: 0, status: 'Error', message: SHOW_ERR ? response.statusMessage.toString() : 'Something wrong !!');
      } else {
        return MyResponse(statusCode: 1, status: 'Success', message: response.statusMessage.toString());
      }
    } on DioError catch (e) {
      return MyResponse(statusCode: 0, status: 'Error', message: SHOW_ERR ? MyDioError.dioError(e) : 'Something wrong !!');
    } catch (e) {
      return MyResponse(statusCode: 0, status: 'Error', message: SHOW_ERR ? e.toString() : 'Something wrong !!');
    }
  }

}
