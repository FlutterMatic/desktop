import 'package:flutter/material.dart';
import 'package:flutter_installer/components/widgets/close_button.dart';
import 'package:flutter_installer/components/widgets/dialog_template.dart';

class ControlSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 40),
              const Spacer(),
              const Text(
                'Control Settings',
                style: TextStyle(fontSize: 20),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: CustomCloseButton(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
