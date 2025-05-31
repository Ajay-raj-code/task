import 'package:flutter/material.dart';

Widget customDateTimePicker() {
  final FixedExtentScrollController monthsController =
      FixedExtentScrollController();
  final List<int> months = List.generate(12, (index) => index + 1);
  return Column(
    children: [
      Expanded(
        child: ListWheelScrollView.useDelegate(
          itemExtent: 50,
          controller: monthsController,
          perspective: 0.003,
          diameterRatio: 1.5,
          physics: FixedExtentScrollPhysics(),
          onSelectedItemChanged: (value) {
            print(value);
          },
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: months.length,
            builder: (context, index) {
              if (index < 0 || index >= months.length) {
                return null;
              }
              return Center(
                child: Text(
                  months[index].toString().padLeft(0, '0'),
                  style: TextStyle(fontSize: 35),
                ),
              );
            },
          ),
        ),
      ),
    ],
  );
}
