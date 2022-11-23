import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class DatePickerForOrderView extends StatelessWidget {
  final DateTimeRange dateTime;
  final Function onTap;
  const DatePickerForOrderView({Key? key, required this.onTap, required this.dateTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: InkWell(
        onTap: () async {
         await onTap();
        },
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          child: SizedBox(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.grey,
                      size: 20.sp,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.0.w),
                      child: FittedBox(
                        child: Text(
                          '${DateFormat('dd-MM-yyyy').format(dateTime.start)} - ${DateFormat('dd-MM-yyyy').format(dateTime.end)}',
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}