import 'package:get/get.dart';
import 'package:rest_verision_3/screens/purchase_book_screen/controller/purchase_book_controller.dart';

class PurchaseBookBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PurchaseBookCTRL());
  }
}