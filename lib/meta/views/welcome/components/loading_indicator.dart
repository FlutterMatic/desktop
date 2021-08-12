import 'package:flutter/material.dart';
import 'package:manager/components/widgets/ui/round_container.dart';

Widget welcomeLoadingIndicator({BuildContext? context, String? message}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 15),
    child: Tooltip(
      message: message ?? 'Loading some resources...',
      child: RoundContainer(
        width: 200,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: const LinearProgressIndicator(),
        ),
      ),
    ),
  );
}
