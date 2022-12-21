import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rest_verision_3/alerts/message_alert.dart';
import 'package:rest_verision_3/routes/route_helper.dart';
import 'package:rest_verision_3/screens/help_video_screen/help_video_screen.dart';
import 'package:rest_verision_3/screens/login_screen/controller/startup_controller.dart';
import 'package:rest_verision_3/screens/profile_page/profile_screen.dart';
import 'package:rest_verision_3/screens/settings_page_screen/controller/settings_controller.dart';
import '../../alerts/add_new_complaint_alert/add_new_complaint_alert.dart';
import '../../alerts/change_mode_of_alert/change_mode_of_alert.dart';
import '../../widget/common_widget/common_text/heading_rich_text.dart';
import '../../widget/settings_page_screen/profile_menu.dart';
import '../../widget/settings_page_screen/profile_pic.dart';


class SettingsPageScreen extends StatelessWidget {
  const SettingsPageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsController>(builder: (ctrl) {
      return SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //? back arrow
                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        HeadingRichText(name: 'Settings'),
                      ],
                    ),
                  ),
                ],
              ),

              10.verticalSpace,

              20.verticalSpace,
              ProfileMenu(
                text: "My Profile",
                icon: Icons.account_circle_rounded,
                press: () => {
                  Get.toNamed(RouteHelper.getProfileScreen())
                },
              ),
              Visibility(
                visible: Get.find<StartupController>().appModeNumber == 1 ? true : false,
                child: ProfileMenu(
                  text: "Renew plan",
                  icon: Icons.autorenew,
                  press: () {
                    messageAlert(context: context,text: 'Pleas contact on 8111866213',title: 'Renew plan');
                  },
                ),
              ),
              Visibility(
                visible: Get.find<StartupController>().appModeNumber == 1 ? true : false,
                child: ProfileMenu(
                  text: "General",
                  icon: Icons.settings,
                  press: () {
                    Get.toNamed(RouteHelper.getPreferenceScreen());
                  },
                ),
              ),
              ProfileMenu(
                text: "Help Center",
                icon: Icons.help,
                press: () {
                  addNewComplaintAlert(context: context);
                },
              ),
              Visibility(
                visible: Get.find<StartupController>().applicationPlan == 1 ? true : false,
                child: ProfileMenu(
                  text: "Change mode",
                  icon: Icons.mode_sharp,
                  press: () async {
                    //? to refresh _appModeNumber from hive before show popup
                    //? because these appModeNumber is used to show and hide password field
                    await ctrl.getAppModeNumber();
                    changeModeOfAppAlert(context: context);
                  },
                ),
              ),
              ProfileMenu(
                text: "Tutorials",
                icon: Icons.logout,
                press: () {
                  Get.to(HelpVideoScreen());
                },
              ),
              ProfileMenu(
                text: "Log Out",
                icon: Icons.logout,
                press: () {
                    ctrl.logOutFromApp();
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}
