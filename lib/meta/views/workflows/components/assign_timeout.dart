// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/widgets/inputs/text_field.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';

class SelectActionTimeout extends StatelessWidget {
  final TextEditingController controller;

  const SelectActionTimeout({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        infoWidget(context,
            'You may need to assign a timeout for your action so it doesn\'t run forever if something goes wrong. Set to 0 minutes (default) to have no timeout.'),
        VSeparators.normal(),
        RoundContainer(
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 95,
                child: CustomTextField(
                  controller: controller,
                  filteringTextInputFormatter: TextInputFormatter.withFunction(
                      (TextEditingValue oldValue, TextEditingValue newValue) {
                    if (newValue.text.isEmpty) {
                      return newValue.copyWith(
                        text: '0',
                        selection:
                            const TextSelection(baseOffset: 1, extentOffset: 1),
                      );
                    }
                    if (int.tryParse(newValue.text) == null) {
                      return oldValue;
                    }
                    if (int.parse(newValue.text) < 0) {
                      return oldValue;
                    }
                    if (int.parse(newValue.text) > 60) {
                      return oldValue;
                    }
                    return newValue.copyWith(
                      // Remove the 0 before the number (for UI purposes)
                      text: newValue.text.replaceFirst(RegExp(r'^0'), ''),
                      selection: const TextSelection(
                        baseOffset: 1,
                        extentOffset: 1,
                      ),
                    );
                  }),
                  hintText: '(minutes)',
                ),
              ),
              HSeparators.normal(),
              const Expanded(
                child: Text(
                  'Each workflow action may take longer than the other. For example, build actions usually take 5 minutes, or longer for larger projects.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
