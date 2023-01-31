import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:rest_verision_3/constants/app_colors/app_colors.dart';
import '../../alerts/printer_scan_alert/print_scan_alert.dart';
import '../../printer/printing_package/printer_config.dart';
import '../../widget/common_widget/common_text/heading_rich_text.dart';
import '../../widget/settings_page_screen/profile_menu.dart';
import '../login_screen/controller/startup_controller.dart';
import 'controller/printer_settings_controller.dart';

class PrinterSettingsScreen extends StatelessWidget {
  const PrinterSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<PrinterSettingsController>(builder: (ctrl) {
        bool horizontal = 1.sh < 1.sw ? true : false;
        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    5.horizontalSpace,
                    BackButton(onPressed: () => Get.back()),
                    40.horizontalSpace,
                    const HeadingRichText(name: 'Printer settings'),
                  ],
                ),
                Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: horizontal ? 100.w : 0),
                    child: Column(
                      children: [
                        20.verticalSpace,
                        ProfileMenu(
                          text: "3 inch printer",
                          icon: Icons.print,
                          press: () {},
                          actionWidget: FlutterSwitch(
                            width: 50.sp,
                            height: 30.sp,
                            activeColor: AppColors.mainColor,
                            value: ctrl.setShowDeliveryAddressInBillToggle,
                            onToggle: (bool value) {
                              ctrl.setShowDeliveryAddressInBillInHive(value);
                              //? to update in general screen controller
                              ctrl.readShowDeliveryAddressInBillFromHive();
                              //? to update in StartupController for global use
                              Get.find<StartupController>().readShowDeliveryAddressInBillFromHive();
                            },
                          ),
                        ),
                        ProfileMenu(
                          text: "Select Billing printer",
                          icon: Icons.bluetooth_searching,
                          press: () async {
                            printerScanAlert(context: context,pOSPrinterType: POSPrinterType.billingPrinter);
                          },
                        ),
                        ProfileMenu(
                          text: "Select Kot printer",
                          icon: Icons.bluetooth_searching,
                          press: () async {
                            printerScanAlert(context: context,pOSPrinterType: POSPrinterType.kotPrinter);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
