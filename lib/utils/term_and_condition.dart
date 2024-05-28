import 'package:flutter/material.dart';
import 'package:studysakha_calling/classes.dart';
Widget termAndCondition(BuildContext context) {
  return const Padding(
    padding: EdgeInsets.all(8.0),
    child: Row(
      children: [
        Icon(Icons.fiber_manual_record, size: 10),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            "Lorem Ipsum is simply dummy text of the printing and typesetting industry. "
                "Lorem Ipsum has been the industry's standard dummy text.",
          ),
        ),
      ],
    ),
  );
}
