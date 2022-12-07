

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:rest_verision_3/screens/login_screen/controller/startup_controller.dart';
import 'package:rest_verision_3/widget/common_widget/common_text/big_text.dart';
import 'package:rest_verision_3/widget/common_widget/common_text/mid_text.dart';
import 'package:store_redirect/store_redirect.dart';
import '../../models/notice_and_update/notice_and_update.dart';
import '../../widget/common_widget/buttons/app_round_mini_btn.dart';

void showKNoticeUpdateAlert({
  required String message,
  required BuildContext context,
  required NoticeAndUpdate noticeAndUpdate,
  required String type,
}) {
  try {
    showAnimatedDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
          insetPadding: const EdgeInsets.all(0),
          titlePadding: const EdgeInsets.all(5),
          contentPadding: const EdgeInsets.all(10),
          actionsAlignment: MainAxisAlignment.center,
          alignment: Alignment.center,
          title: Center(
              child: BigText(
            text: type == 'update' ? 'UPDATE' : 'NOTICE',
          )),
          actions: [
            AppRoundMiniBtn(
              text: type == 'update' ? 'Update' : 'Ok',
              color: Colors.green,
              onTap: () {
                //? if type is notice then no need to any operation
                if(type == 'notice'){
                  Navigator.pop(context);
                }
                else if(type == 'update'){
                  if(Platform.isWindows){
                    //? give exe download link
                  }
                  StoreRedirect.redirect(androidAppId: "com.iyaffle.rangoli",
                      iOSAppId: "585027354");
                }
                else{
                  Navigator.pop(context);
                }
              },
            ),
            20.horizontalSpace,
            AppRoundMiniBtn(
                text: 'Close',
                color: Colors.redAccent,
                onTap: () {
                  Navigator.pop(context);
                })
          ],
          content: SizedBox(
              height: 60.sp,
              width: 0.7.sw,
              child: Center(
                  child: Text(
                message,
                maxLines: 3,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15.sp,),
              ))),
        );
      },
      animationType: DialogTransitionType.scale,
      curve: Curves.fastOutSlowIn,
      duration: const Duration(milliseconds: 900),
    );
  } catch (e) {
    rethrow;
  }
}