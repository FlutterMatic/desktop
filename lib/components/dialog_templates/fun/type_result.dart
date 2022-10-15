// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';

class TypeTestResultDialog extends StatelessWidget {
  final int totalWrongWords;
  final int totalCorrectWords;
  final int totalCharsPerMin;

  const TypeTestResultDialog({
    Key? key,
    required this.totalWrongWords,
    required this.totalCorrectWords,
    required this.totalCharsPerMin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        children: <Widget>[
          const DialogHeader(title: 'Typing Test Results'),
          Row(
            children: <Widget>[
              const RoundContainer(
                  height: 50, width: 50, child: Icon(Icons.keyboard_rounded)),
              HSeparators.large(),
              Expanded(
                flex: 3,
                child: RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      const TextSpan(
                          text: 'Your speed is ',
                          style: TextStyle(color: Colors.grey)),
                      TextSpan(
                          text: '$totalCorrectWords wpm. ',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      const TextSpan(
                          text: 'You have typed ',
                          style: TextStyle(color: Colors.grey)),
                      TextSpan(
                          text:
                              '$totalCharsPerMin characters per minute (cpm). ',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      const TextSpan(
                          text: 'You have an accuracy rate of ',
                          style: TextStyle(color: Colors.grey)),
                      TextSpan(
                          text: totalCorrectWords == 0
                              ? '0%'
                              : '${((totalCorrectWords / (totalCorrectWords + totalWrongWords)) * 100).round()}%',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      const TextSpan(text: '. '),
                      if (totalCorrectWords > 100)
                        const TextSpan(
                            text:
                                'You have an incredible typing speed. Way to go! Way beyond average!',
                            style: TextStyle(color: Colors.grey))
                      else if (totalCorrectWords > 60)
                        const TextSpan(
                            text:
                                'You have an average typing speed. Keep it up!',
                            style: TextStyle(color: Colors.grey))
                      else if (totalCorrectWords > 30)
                        const TextSpan(
                            text: 'You have a decent typing speed. Keep it up!',
                            style: TextStyle(color: Colors.grey))
                      else
                        const TextSpan(
                            text:
                                'You have a poor typing speed. Try to improve it!',
                            style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          VSeparators.normal(),
          RectangleButton(
            width: double.infinity,
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
