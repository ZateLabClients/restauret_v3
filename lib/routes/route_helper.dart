import 'package:get/get.dart';
import 'package:rest_verision_3/screens/add_food_screen/add_food_screen.dart';
import 'package:rest_verision_3/screens/add_food_screen/binding/add_food_binding.dart';
import 'package:rest_verision_3/screens/update_food_screen/update_food_screen.dart';
import '../screens/all_food_screen/all_food_screen.dart';
import '../screens/all_food_screen/binding/all_food_binding.dart';
import '../screens/billing_screen/billing_screen.dart';
import '../screens/billing_screen/binding/billing_screen_binding.dart';
import '../screens/home_screen/binding/home_screen_binding.dart';
import '../screens/home_screen/home_screen.dart';
import '../screens/update_food_screen/binding/update_food_binding.dart';

class RouteHelper {
  static const String initial = '/';
  static const String allFoodScreen = '/all-food';
  static const String addFoodScreen = '/add-food';
  static const String updateFoodScreen = '/update-food';
  static const String billingScreen = '/billing-food';

  static String getInitial() => initial;
  static String getAllFoodScreen() => allFoodScreen;
  static String getAddFoodScreen() => addFoodScreen;
  static String getUpdateFoodScreen() => updateFoodScreen;
  static String getBillingScreenScreen() => billingScreen;

  static List<GetPage> routes = [
    GetPage(
      name: initial,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 600),
    ),
    GetPage(
      name: allFoodScreen,
      page: () => const AllFoodScreen(),
      binding: AllFoodBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: addFoodScreen,
      page: () => const AddFoodScreen(),
      binding: AddFoodBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: updateFoodScreen,
      page: () => const UpdateFoodScreen(),
      binding: UpdateFoodBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: billingScreen,
      page: () => const BillingScreen(),
      binding: BillingScreenBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 500),
    ),
  ];
}
