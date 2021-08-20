import 'package:flutter/material.dart';
import 'package:manager/components/widgets/ui/round_container.dart';

Widget hLoadingIndicator(
    {BuildContext? context, String? message, Color? bgColor, double? value, Animation<Color?>? valueColor}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 15),
    child: Tooltip(
      message: message ?? 'Loading some resources...',
      child: RoundContainer(
        width: 200,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            backgroundColor: Colors.blue.withOpacity(0.1),
            value: value,
            valueColor: valueColor,
          ),
        ),
      ),
    ),
  );
}
