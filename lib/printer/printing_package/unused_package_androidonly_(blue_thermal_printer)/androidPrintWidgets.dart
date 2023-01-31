import 'package:flutter/material.dart';

class AndroidPrintWidgets {
  static TextStyle boldText() {
    return const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w600);
  }

  static TextStyle normalText() {
    return const TextStyle(color: Colors.black, fontSize: 10);
  }

  static Widget tableRow({required List items, List flex = const [],bool isBold=false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        items.length,
            (index) => Expanded(
          flex: flex.isEmpty?1: flex[index],
          child: Text(
            items[index],
            textAlign: index == 0 ? TextAlign.start :index == items.length-1?TextAlign.end: TextAlign.center,
            overflow: index == items.length - 1 ? TextOverflow.ellipsis : TextOverflow.visible,
            style: isBold?AndroidPrintWidgets.boldText():AndroidPrintWidgets.normalText(),
          ),
        ),
      ),
    );
  }
}
