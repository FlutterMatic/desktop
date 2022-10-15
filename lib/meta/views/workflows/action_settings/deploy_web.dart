// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/meta/utils/general/app_theme.dart';
import 'package:fluttermatic/meta/views/workflows/components/input_hover.dart';

class DeployWebWorkflowActionConfig extends StatefulWidget {
  final TextEditingController webUrlController;
  final TextEditingController firebaseProjectName;
  final TextEditingController firebaseProjectIDController;
  final bool isValidated;
  final Function(bool isValid) onFirebaseValidated;

  const DeployWebWorkflowActionConfig({
    Key? key,
    required this.webUrlController,
    required this.firebaseProjectName,
    required this.firebaseProjectIDController,
    required this.onFirebaseValidated,
    required this.isValidated,
  }) : super(key: key);

  @override
  _DeployWebWorkflowActionStateConfig createState() =>
      _DeployWebWorkflowActionStateConfig();
}

class _DeployWebWorkflowActionStateConfig
    extends State<DeployWebWorkflowActionConfig> {
  bool _isVerifying = false;
  final List<bool> _totalVerify = <bool>[false, false, false];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.isValidated)
          RoundContainer(
            width: double.infinity,
            child: Column(
              children: <Widget>[
                SvgPicture.asset(Assets.done, height: 20),
                VSeparators.normal(),
                const Text(
                  'Verified',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                VSeparators.normal(),
                const SizedBox(
                  width: 400,
                  child: Text(
                    'You have verified that all the information is correct. You can still edit and go back if you are not sure.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
                VSeparators.normal(),
                RectangleButton(
                  width: double.infinity,
                  child: const Text('Go Back'),
                  onPressed: () {
                    widget.onFirebaseValidated(false);
                    setState(() {
                      for (int i = 0; i < _totalVerify.length; i++) {
                        _totalVerify[i] = false;
                      }
                    });
                  },
                ),
              ],
            ),
          )
        else if (!_isVerifying) ...<Widget>[
          infoWidget(
            context,
            'We will show you the information you entered to verify one by one to make sure there are no mistakes.',
          ),
          VSeparators.normal(),
          const Text('Configure your web deploy workflow action here.'),
          VSeparators.normal(),
          InputHoverAffect(
            inputFormatters: <TextInputFormatter>[
              TextInputFormatter.withFunction(
                (TextEditingValue oldValue, TextEditingValue newValue) {
                  if (newValue.text.startsWith('.')) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      snackBarTile(
                        context,
                        'You can\'t start a url with "."',
                        type: SnackBarType.warning,
                      ),
                    );
                    return oldValue;
                  }
                  if (newValue.text.contains('.')) {
                    int totalDots = 0;

                    for (String char in newValue.text.split('')) {
                      if (char == '.') {
                        totalDots++;
                        if (totalDots > 1) {
                          break;
                        }
                      }
                    }
                    if (totalDots == 1) {
                      List<String> split = newValue.text.split('.');
                      if (split.first != 'www') {
                        String newText = 'www.${newValue.text}';
                        return newValue.copyWith(
                          text: newText,
                          selection: TextSelection(
                            baseOffset: newText.length,
                            extentOffset: newText.length,
                          ),
                        );
                      } else {
                        return newValue;
                      }
                    } else {
                      return newValue;
                    }
                  } else {
                    return newValue;
                  }
                },
              ),
            ],
            hintText: 'Web URL (ex: www.example.com)',
            infoText:
                'It makes it easier to verify that we are deploying to the correct host.',
            controller: widget.webUrlController,
          ),
          VSeparators.normal(),
          InputHoverAffect(
            hintText: 'Firebase Project ID',
            infoText:
                'The ID of the Firebase project to deploy to. This is verified before deployed.',
            controller: widget.firebaseProjectIDController,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 _]')),
              TextInputFormatter.withFunction(
                (TextEditingValue oldValue, TextEditingValue newValue) {
                  String newText =
                      newValue.text.toLowerCase().replaceAll(' ', '_');

                  if (newText.startsWith('_')) {
                    return oldValue;
                  }

                  if (newText.length > 1) {
                    if (newText[newText.length - 1] == '_' &&
                        newText[newText.length - 2] == '_') {
                      return oldValue;
                    }
                  }

                  return newValue.copyWith(
                    text: newText,
                    selection: TextSelection(
                      baseOffset: newText.length,
                      extentOffset: newText.length,
                    ),
                  );
                },
              ),
            ],
          ),
          VSeparators.normal(),
          InputHoverAffect(
            hintText: 'Firebase Project Name',
            infoText:
                'The name of the Firebase project to deploy to. This is verified before deployed.',
            controller: widget.firebaseProjectName,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z -]')),
              TextInputFormatter.withFunction(
                  (TextEditingValue oldValue, TextEditingValue newValue) {
                String newText =
                    newValue.text.toLowerCase().replaceAll(' ', '-');

                if (newText.startsWith('-')) {
                  return oldValue;
                }

                if (newText.length > 1) {
                  if (newText[newText.length - 1] == '-' &&
                      newText[newText.length - 2] == '-') {
                    return oldValue;
                  }
                }

                return newValue.copyWith(
                  text: newText,
                  selection: TextSelection(
                    baseOffset: newText.length,
                    extentOffset: newText.length,
                  ),
                );
              }),
            ],
          ),
          VSeparators.normal(),
          Align(
            alignment: Alignment.centerRight,
            child: RectangleButton(
              width: 100,
              child: const Text('Confirm'),
              onPressed: () {
                if (widget.webUrlController.text.isNotEmpty &&
                    widget.firebaseProjectIDController.text.isNotEmpty &&
                    widget.firebaseProjectName.text.isNotEmpty) {
                  setState(() => _isVerifying = true);
                } else {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    snackBarTile(
                      context,
                      'Please fill out all fields about your Firebase app.',
                      type: SnackBarType.warning,
                    ),
                  );
                }
              },
            ),
          ),
        ] else ...<Widget>[
          _VerifyColumnBar(
            onEdit: () => widget.onFirebaseValidated(false),
            title: 'Website URL',
            value: widget.webUrlController.text,
            onVerify: () {
              setState(() => _totalVerify[0] = true);
              // All has been verified, we show a snackbar.
              if (!_totalVerify.contains(false)) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  snackBarTile(
                    context,
                    'You have verified all inputs.',
                    type: SnackBarType.done,
                  ),
                );
                widget.onFirebaseValidated(true);
              }
            },
          ),
          VSeparators.normal(),
          _VerifyColumnBar(
            onEdit: () => widget.onFirebaseValidated(false),
            title: 'Project ID',
            value: widget.firebaseProjectIDController.text,
            onVerify: () {
              setState(() => _totalVerify[1] = true);
              // All has been verified, we show a snackbar.
              if (!_totalVerify.contains(false)) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  snackBarTile(
                    context,
                    'You have verified all inputs.',
                    type: SnackBarType.done,
                  ),
                );

                widget.onFirebaseValidated(true);
              }
            },
          ),
          VSeparators.normal(),
          _VerifyColumnBar(
            onEdit: () => widget.onFirebaseValidated(false),
            title: 'Project Name',
            value: widget.firebaseProjectName.text,
            onVerify: () {
              setState(() => _totalVerify[2] = true);
              // All has been verified, we show a snackbar.
              if (!_totalVerify.contains(false)) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  snackBarTile(
                    context,
                    'You have verified all inputs.',
                    type: SnackBarType.done,
                  ),
                );

                widget.onFirebaseValidated(true);
              }
            },
          ),
        ],
      ],
    );
  }
}

class _VerifyColumnBar extends StatefulWidget {
  final String title;
  final String value;
  final Function() onEdit;
  final Function() onVerify;

  const _VerifyColumnBar({
    Key? key,
    required this.title,
    required this.value,
    required this.onEdit,
    required this.onVerify,
  }) : super(key: key);

  @override
  __VerifyColumnBarState createState() => __VerifyColumnBarState();
}

class __VerifyColumnBarState extends State<_VerifyColumnBar> {
  bool _isVerified = false;
  bool _showControls = true;

  @override
  Widget build(BuildContext context) {
    return RoundContainer(
      child: Row(
        children: <Widget>[
          SvgPicture.asset(Assets.done, height: 20),
          HSeparators.normal(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(widget.title, style: const TextStyle(color: Colors.grey)),
                VSeparators.xSmall(),
                Text(widget.value),
              ],
            ),
          ),
          HSeparators.normal(),
          AnimatedOpacity(
            opacity: _showControls ? 1 : 0,
            duration: const Duration(milliseconds: 100),
            child: _isVerified
                ? SquareButton(
                    icon: const Icon(Icons.edit_rounded, color: kYellowColor),
                    onPressed: widget.onEdit,
                  )
                : Row(
                    children: <Widget>[
                      SquareButton(
                        icon: const Icon(Icons.close_rounded,
                            color: AppTheme.errorColor),
                        onPressed: widget.onEdit,
                      ),
                      HSeparators.small(),
                      SquareButton(
                        icon:
                            const Icon(Icons.check_rounded, color: kGreenColor),
                        onPressed: () async {
                          setState(() => _showControls = false);
                          await Future<void>.delayed(
                              const Duration(milliseconds: 100));
                          setState(() {
                            _isVerified = true;
                            _showControls = true;
                          });
                          widget.onVerify();
                        },
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
