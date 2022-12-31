import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:rest_verision_3/screens/report_screen/controller/report_controller.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../constants/app_colors/app_colors.dart';
import '../../models/settled_order_response/settled_order.dart';
import '../../widget/common_widget/common_text/big_text.dart';
import '../../widget/common_widget/common_text/mid_text.dart';
import '../../widget/common_widget/common_text/small_text.dart';
import '../../widget/common_widget/loading_page.dart';
import '../../widget/order_view_screen/date_picker_for_order_view.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: RichText(
          softWrap: false,
          text: TextSpan(children: [
            TextSpan(text: 'Sales Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28.sp, color: AppColors.textColor)),
          ]),
          maxLines: 1,
        ),
        actions: [
          Container(
              margin: EdgeInsets.only(right: 10.w),
              child: Icon(
                FontAwesomeIcons.bell,
                size: 24.sp,
              )),
          10.horizontalSpace
        ],
      ),
      body: GetBuilder<ReportController>(builder: (ctrl) {
        int totalOrder = 0;
        num totalCash = 0;
        Map<String, Map<String, num>> ordersByTypeMap = {};
        List<OrdersByType> ordersByTypeList = [];

        Map<String, Map<String, num>> sortByFoodMap = {};
        List<OrdersByFoodName> sortByFoodList = [];

        Map<String, Map<String, num>> ordersByPaymentTypeMap = {};
        List<OrdersByPaymentMethod> ordersByPaymentTypeList = [];

        Map<String, Map<String, num>> ordersByOnlineAppMap = {};
        List<OrdersByOnlineApp> ordersByOnlineAppList = [];

        for (var element in ctrl.mySettledItem) {
          totalOrder += 1;
          totalCash += element.grandTotal ?? 0;

          // ordersByType
          if (element.fdOrderType != null) {
            if (ordersByTypeMap[element.fdOrderType] == null) {
              ordersByTypeMap[element.fdOrderType!] = {'orderCount': 0, 'total': 0};
            }
            num orderCount = (ordersByTypeMap[element.fdOrderType!]!['orderCount'])! + 1;
            num total = (ordersByTypeMap[element.fdOrderType!]!['total'])! + (element.grandTotal!);
            ordersByTypeMap[element.fdOrderType!] = {'orderCount': orderCount, 'total': total};
          }

          //GroupBypayment type
          if (element.paymentType != null) {
            if (ordersByPaymentTypeMap[element.paymentType] == null) {
              ordersByPaymentTypeMap[element.paymentType!] = {'orderCount': 0, 'total': 0};
            }
            num orderCount = (ordersByPaymentTypeMap[element.paymentType!]!['orderCount'])! + 1;
            num total = (ordersByPaymentTypeMap[element.paymentType!]!['total'])! + (element.grandTotal!);
            ordersByPaymentTypeMap[element.paymentType!] = {'orderCount': orderCount, 'total': total};
          }

          //Group by online app
          if (element.fdOnlineApp != null) {
            if (ordersByOnlineAppMap[element.fdOnlineApp] == null) {
              ordersByOnlineAppMap[element.fdOnlineApp!] = {'orderCount': 0, 'total': 0};
            }
            num orderCount = (ordersByOnlineAppMap[element.fdOnlineApp!]!['orderCount'])! + 1;
            num total = (ordersByOnlineAppMap[element.fdOnlineApp!]!['total'])! + (element.grandTotal!);
            ordersByOnlineAppMap[element.fdOnlineApp!] = {'orderCount': orderCount, 'total': total};
          }

          //sort by food name
          if (element.fdOrder != null) {
            for (var element in element.fdOrder!) {
              if (element.name == null || element.qnt == null || element.price == null) {
                continue;
              }
              if (sortByFoodMap[element.name] == null) {
                sortByFoodMap[element.name!] = {'orderCount': 0, 'total': 0};
              }
              num orderCount = (sortByFoodMap[element.name!]!['orderCount'])! + element.qnt!;
              num total = (sortByFoodMap[element.name!]!['total'])! + (element.price! * element.qnt!);
              sortByFoodMap[element.name!] = {'orderCount': orderCount, 'total': total};
            }
          }
        }

        ordersByTypeMap.forEach((key, value) {
          ordersByTypeList.add(OrdersByType(type: key, orderCount: value['orderCount'] ?? 0, priceTotal: value['total'] ?? 0));
        });

        ordersByPaymentTypeMap.forEach((key, value) {
          ordersByPaymentTypeList.add(OrdersByPaymentMethod(paymentMethod: key, orderCount: value['orderCount'] ?? 0, priceTotal: value['total'] ?? 0));
        });

        ordersByOnlineAppMap.forEach((key, value) {
          ordersByOnlineAppList.add(OrdersByOnlineApp(appName: key, orderCount: value['orderCount'] ?? 0, priceTotal: value['total'] ?? 0));
        });

        sortByFoodMap.forEach((key, value) {
          sortByFoodList.add(OrdersByFoodName(title: key, qtyTotal: value['orderCount'] ?? 0, priceTotal: value['total'] ?? 0));
        });

        Color getColorForBarChart({required int index}) {
          List<Color> color = [
            Colors.lightBlue,
            Colors.teal,
            Colors.deepPurpleAccent,
            Colors.pinkAccent,
            Colors.cyan,
            Colors.amberAccent,
            Colors.greenAccent,
            Colors.purpleAccent,
            Colors.brown,
            Colors.orange,
          ];
          if (index >= color.length) {
            return Colors.deepPurpleAccent;
          }
          return color[index];
        }

        return SafeArea(
          child: ctrl.isLoading
              ? const MyLoading()
              : RefreshIndicator(
                  onRefresh: () async {
                    await ctrl.refreshSettledOrder();
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            10.horizontalSpace,
                            DatePickerForOrderView(
                              maninAxisAlignment: MainAxisAlignment.center,
                              dateTime: ctrl.selectedDateRangeForSettledOrder,
                              onTap: () async {
                                ctrl.datePickerForSettledOrder(context);
                              },
                            ),
                            10.horizontalSpace,
                          ],
                        ),
                        10.verticalSpace,
                        if(ctrl.mySettledItem.isNotEmpty)...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              20.horizontalSpace,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MidText(text: 'Total order: $totalOrder'),
                                  5.verticalSpace,
                                  MidText(text:'TotalCash : $totalCash'),
                                ],
                              ),
                            ],
                          ),
                          30.verticalSpace,
                          Card(
                            child: Column(
                              children: [
                                SfCartesianChart(
                                  primaryXAxis: CategoryAxis(
                                    axisLabelFormatter: (axisLabelRenderArgs) {
                                      return ChartAxisLabel(axisLabelRenderArgs.text, TextStyle());
                                    },
                                  ),
                                  title: ChartTitle(text: 'ORDERS BY TYPE'),
                                  tooltipBehavior: TooltipBehavior(enable: true),
                                  series: [
                                    StackedColumnSeries(
                                        pointColorMapper: (datum, index) {
                                          return getColorForBarChart(index: index);
                                        },
                                        dataSource: ordersByTypeList,
                                        xValueMapper: (OrdersByType data, _) => data.type,
                                        yValueMapper: (OrdersByType data, _) => data.orderCount),
                                  ],
                                ),
                                const ListTile(
                                  dense: true,
                                  title: Text('Order count', style: TextStyle(fontWeight: FontWeight.bold)),
                                  leading: Text('Order Type', style: TextStyle(fontWeight: FontWeight.bold)),
                                  trailing: Text('Revenue', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                Column(
                                  children: List.generate(ordersByTypeList.length, (index) {
                                    return ListTile(
                                      dense: true,
                                      leading: Text(ordersByTypeList[index].type),
                                      title: Text('    ${ordersByTypeList[index].orderCount}'),
                                      trailing: Text('${ordersByTypeList[index].priceTotal}'),
                                    );
                                  }),
                                )
                              ],
                            ),
                          ),
                          Card(
                            child: Column(
                              children: [
                                10.verticalSpace,
                                SfCircularChart(
                                  title: ChartTitle(text: 'Orders by payment method'.toUpperCase()),
                                  // backgroundColor: Colors.red,
                                  // margin: EdgeInsets.zero,
                                  tooltipBehavior: TooltipBehavior(enable: true),
                                  legend: Legend(
                                    isVisible: true,
                                    position: LegendPosition.bottom,
                                    overflowMode: LegendItemOverflowMode.wrap,
                                  ),
                                  series: [
                                    PieSeries<OrdersByPaymentMethod, String>(
                                      dataSource: ordersByPaymentTypeList,
                                      xValueMapper: (OrdersByPaymentMethod data, _) => data.paymentMethod,
                                      yValueMapper: (OrdersByPaymentMethod data, _) => data.orderCount,
                                      // radius: '70%',
                                      dataLabelSettings: const DataLabelSettings(
                                        isVisible: true,
                                      ),
                                    ),
                                  ],
                                ),
                                const ListTile(
                                  dense: true,
                                  title: Text('Order count', style: TextStyle(fontWeight: FontWeight.bold)),
                                  leading: Text('Payment', style: TextStyle(fontWeight: FontWeight.bold)),
                                  trailing: Text('Revenue', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                Column(
                                  children: List.generate(ordersByPaymentTypeList.length, (index) {
                                    return ListTile(
                                      dense: true,
                                      leading: Text(ordersByPaymentTypeList[index].paymentMethod),
                                      title: Text(
                                        '    ${ordersByPaymentTypeList[index].orderCount}',
                                      ),
                                      trailing: Text('${ordersByPaymentTypeList[index].priceTotal}'),
                                    );
                                  }),
                                )
                              ],
                            ),
                          ),
                          Card(
                            child: Column(
                              children: [
                                SfCircularChart(
                                  // primaryXAxis: CategoryAxis(),
                                  title: ChartTitle(text: 'ORDERS BY ONLINE APP'),
                                  tooltipBehavior: TooltipBehavior(enable: true),
                                  legend: Legend(isVisible: true, position: LegendPosition.bottom, overflowMode: LegendItemOverflowMode.wrap),
                                  series: [
                                    PieSeries<OrdersByOnlineApp, String>(
                                      dataSource: ordersByOnlineAppList,
                                      xValueMapper: (OrdersByOnlineApp data, _) => data.appName,
                                      yValueMapper: (OrdersByOnlineApp data, _) => data.orderCount,
                                      // radius: '60%',
                                      dataLabelSettings: const DataLabelSettings(
                                        isVisible: true,
                                      ),
                                    ),
                                  ],
                                ),
                                const ListTile(
                                  dense: true,
                                  title: Text('Order count', style: TextStyle(fontWeight: FontWeight.bold)),
                                  leading: Text('App Name', style: TextStyle(fontWeight: FontWeight.bold)),
                                  trailing: Text('Revenue', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                Column(
                                  children: List.generate(ordersByOnlineAppList.length, (index) {
                                    return ListTile(
                                      dense: true,
                                      leading: Text(ordersByOnlineAppList[index].appName),
                                      title: Text(
                                        '    ${ordersByOnlineAppList[index].orderCount}',
                                      ),
                                      trailing: Text('${ordersByOnlineAppList[index].priceTotal}'),
                                    );
                                  }),
                                )
                              ],
                            ),
                          ),
                          Card(
                            child: Column(
                              children: [
                                 Text('Orders By product'.toUpperCase(),style: TextStyle(fontSize: 20.sp),),
                                const ListTile(
                                  dense: true,
                                  title: Text(
                                    'Qty',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  leading: Text('Title', style: TextStyle(fontWeight: FontWeight.bold)),
                                  trailing: Text('Revenue', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                Column(
                                    children: List.generate(sortByFoodList.length, (index) {
                                      return ListTile(
                                        dense: true,
                                        title: Text(sortByFoodList[index].title),
                                        leading: Text('${sortByFoodList[index].qtyTotal}'),
                                        trailing: Text('${sortByFoodList[index].priceTotal}'),
                                      );
                                    })),
                              ],
                            ),
                          ),
                          250.verticalSpace,
                        ]else...[
                          200.verticalSpace,
                          //TODO : overflow not added in MidText
                          const BigText(text: 'No orders !!')
                        ],

                      ],
                    ),
                  ),
                ),
        );
      }),
    );
  }
}

class OrdersByType {
  OrdersByType({required this.type, required this.orderCount, required this.priceTotal});

  final String type;
  final num orderCount;
  final num priceTotal;
}

class OrdersByPaymentMethod {
  OrdersByPaymentMethod({required this.priceTotal, required this.paymentMethod, required this.orderCount});

  final String paymentMethod;
  final num orderCount;
  final num priceTotal;
}

class OrdersByOnlineApp {
  OrdersByOnlineApp({required this.appName, required this.orderCount, required this.priceTotal});

  final String appName;
  final num orderCount;
  final num priceTotal;
}

class OrdersByFoodName {
  OrdersByFoodName({required this.title, required this.qtyTotal, required this.priceTotal});

  final String title;
  final num qtyTotal;
  final num priceTotal;
}
