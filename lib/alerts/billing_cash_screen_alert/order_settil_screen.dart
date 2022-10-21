import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rest_verision_3/alerts/billing_cash_screen_alert/payment_type__drop_down.dart';
import 'package:rest_verision_3/widget/common_widget/horizontal_divider.dart';
import '../../constants/app_colors/app_colors.dart';
import '../../widget/common_widget/buttons/app_min_button.dart';
import '../../widget/common_widget/buttons/progress_button.dart';
import '../../widget/common_widget/common_text/big_text.dart';
import '../../widget/common_widget/text_field_widget.dart';
import 'invoice_alert_for_billing_page.dart';


//? this is the popup open when click settled btn click to enter cash details
class OrderSettleScreen extends StatelessWidget {
  final ctrl;

  const OrderSettleScreen({Key? key, required this.ctrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        width: 0.8.sw,
        padding: EdgeInsets.all(10.sp),
        child: SizedBox(
          width: 0.8.sw,
          child: (Column(
            children: [
              const HorizontalDivider(),
              10.verticalSpace,
              //net total
              Row(
                children: [
                  FittedBox(
                    child: BigText(
                      text: 'Net Total : ',
                      size: 20.sp,
                      color: AppColors.titleColor,
                    ),
                  ),
                  Flexible(
                      child: TextFieldWidget(
                    textEditingController: ctrl.settleNetTotalCtrl.value,
                    hintText: 'Net Amount',
                    isDens: true,
                    hintSize: 16,
                    borderRadius: 10.r,
                    onChange: (value) {
                      ctrl.calculateNetTotal();
                    },
                  ))
                ],
              ),
              10.verticalSpace,

              //discount
              Row(
                children: [
                  FittedBox(
                    child: BigText(
                      text: 'Discount : ',
                      size: 20.sp,
                      color: AppColors.titleColor,
                    ),
                  ),
                  Flexible(
                      child: TextFieldWidget(
                    textEditingController: ctrl.settleDiscountPercentageCtrl.value,
                    hintText: 'in %',
                    isDens: true,
                    hintSize: 16,
                    borderRadius: 10.r,
                    onChange: (value) {
                      ctrl.calculateNetTotal();
                    },
                  )),
                  Flexible(
                      child: TextFieldWidget(
                    textEditingController: ctrl.settleDiscountCashCtrl.value,
                    hintText: 'in Cash',
                    isDens: true,
                    hintSize: 16,
                    borderRadius: 10.r,
                    onChange: (_) {
                      ctrl.calculateNetTotal();
                    },
                  ))
                ],
              ),
              10.verticalSpace,
              Row(
                children: [
                  FittedBox(
                    child: BigText(
                      text: 'Charges : ',
                      size: 20.sp,
                      color: AppColors.titleColor,
                    ),
                  ),
                  Flexible(
                      child: TextFieldWidget(
                    textEditingController: ctrl.settleChargesCtrl.value,
                    hintText: 'Amount',
                    hintSize: 16,
                    isDens: true,
                    borderRadius: 10.r,
                    onChange: (_) {
                      ctrl.calculateNetTotal();
                    },
                  ))
                ],
              ),
              10.verticalSpace,
              //grand total
              Row(
                children: [
                  FittedBox(
                    child: BigText(
                      text: 'Grand Total : ',
                      size: 20.sp,
                      color: AppColors.titleColor,
                    ),
                  ),
                  Flexible(
                      child: TextFieldWidget(
                    textEditingController: ctrl.settleGrandTotalCtrl.value,
                    hintText: 'Grand Total',
                    isDens: true,
                    hintSize: 16,
                    borderRadius: 10.r,
                    onChange: (_) {},
                  ))
                ],
              ),
              10.verticalSpace,
              //payment type
              Row(
                children: [
                  FittedBox(
                    child: BigText(
                      text: 'Payment : ',
                      size: 20.sp,
                      color: AppColors.titleColor,
                    ),
                  ),
                  const Flexible(child: PaymentTypeDropDown())
                ],
              ),
              10.verticalSpace,
              //cash received
              Row(
                children: [
                  FittedBox(
                    child: BigText(
                      text: 'Cash Received : ',
                      size: 20.sp,
                      color: AppColors.titleColor,
                    ),
                  ),
                  Flexible(
                      child: TextFieldWidget(
                    textEditingController: ctrl.settleCashReceivedCtrl.value,
                    hintText: 'Amount Received',
                    isDens: true,
                    hintSize: 16,
                    borderRadius: 10.r,
                    onChange: (value) {
                      ctrl.calculateNetTotal();
                    },
                  ))
                ],
              ),
              10.verticalSpace,
              //change cash text
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FittedBox(
                    child: BigText(
                      text: 'Change : ',
                      size: 20.sp,
                      color: AppColors.titleColor,
                    ),
                  ),
                  10.horizontalSpace,
                  FittedBox(
                    child: BigText(
                      text: ctrl.balanceChange.value.toString(),
                      size: 20.sp,
                      color: AppColors.mainColor,
                    ),
                  ),
                ],
              ),
              10.verticalSpace,
              //buttons
              SizedBox(
                height: 40.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                        child: ctrl.isClickedSettle.value
                            ? AppMiniButton(text: 'Settled', color: Colors.grey, onTap: () {}) //disable if already click
                            : ProgressButton(
                                btnCtrlName: 'settle',
                                ctrl: ctrl,
                                color: Colors.blue,
                                text: 'settle',
                                onTap: () async {
                                  await ctrl.insertSettledBill(context);
                                },
                              )),
                    3.horizontalSpace,
                    Flexible(
                      child: AppMiniButton(
                        color: const Color(0xff4caf50),
                        text: 'Print',
                        onTap: () {
                          print('object');
                          Navigator.pop(context);
                          //? bill page to print invoice
                          invoiceAlertForBillingViewPage(
                              context: context,
                              grandTotal:ctrl.grandTotalNew,
                              discountPercent: ctrl.discountPresent,
                              discountCash: ctrl.discountCash,
                              charges: ctrl.charges,
                              billingItems: ctrl.billingItems,
                              change: ctrl.balanceChange.value,
                              netAmount:ctrl.netTotal,
                              cashReceived:ctrl.cashReceived,
                              orderType: ctrl.orderType.toString().toUpperCase());
                        },
                      ),
                    ),
                    3.horizontalSpace,
                    Flexible(
                      child: ctrl.isClickedSettle.value
                          ? AppMiniButton(text: 'Settle & print', color: Colors.grey, onTap: () {}) //disable if already click
                          : AppMiniButton(
                              color: AppColors.mainColor,
                              text: 'Settle & print',
                              onTap: () {},
                            ),
                    ),
                    3.horizontalSpace,
                  ],
                ),
              ),
            ],
          )),
        ),
      );
    });
  }
}
