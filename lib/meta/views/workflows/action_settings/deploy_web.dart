// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/widgets/buttons/rectangle_button.dart';
import 'package:manager/components/widgets/buttons/square_button.dart';
import 'package:manager/components/widgets/ui/info_widget.dart';
import 'package:manager/components/widgets/ui/round_container.dart';
import 'package:manager/components/widgets/ui/snackbar_tile.dart';
import 'package:manager/core/libraries/utils.dart';
import 'package:manager/meta/views/workflows/components/expandable_tile.dart';
import 'package:manager/meta/views/workflows/components/input_hover.dart';

class DeployWebWorkflowActionConfig extends StatefulWidget {
  final TextEditingController webUrlController;
  final TextEditingController firebaseProjectName;
  final TextEditingController firebaseProjectIDController;
  final bool isValidated;
  final Function(bool isValid) onValidate;

  const DeployWebWorkflowActionConfig({
    Key? key,
    required this.webUrlController,
    required this.firebaseProjectName,
    required this.firebaseProjectIDController,
    required this.onValidate,
    required this.isValidated,
  }) : super(key: key);

  @override
  _DeployWebWorkflowActionStateConfig createState() =>
      _DeployWebWorkflowActionStateConfig();
}

class _DeployWebWorkflowActionStateConfig
    extends State<DeployWebWorkflowActionConfig> {
  final List<bool> _totalVerify = <bool>[false, false, false];

  @override
  Widget build(BuildContext context) {
    return ConfigureExpandableTile(
      title: 'Deploy Web - Firebase',
      subtitle: 'Deploy web workflow action',
      icon: SvgPicture.asset(Assets.firebase, height: 20),
      children: widget.isValidated
          ? !_totalVerify.contains(false)
              ? <Widget>[
                  RoundContainer(
                    width: double.infinity,
                    color: Colors.blueGrey.withOpacity(0.2),
                    child: Column(
                      children: <Widget>[
                        SvgPicture.asset(Assets.done, height: 20),
                        VSeparators.normal(),
                        const Text(
                          'Verified',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
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
                          onPressed: () => setState(() {
                            widget.onValidate(false);
                            for (int i = 0; i < _totalVerify.length; i++) {
                              _totalVerify[i] = false;
                            }
                          }),
                        ),
                      ],
                    ),
                  )
                ]
              : <Widget>[
                  _VerifyColumnBar(
                    onEdit: () => widget.onValidate(false),
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
                            revert: true,
                          ),
                        );
                      }
                    },
                  ),
                  VSeparators.normal(),
                  _VerifyColumnBar(
                    onEdit: () => widget.onValidate(false),
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
                            revert: true,
                          ),
                        );
                      }
                    },
                  ),
                  VSeparators.normal(),
                  _VerifyColumnBar(
                    onEdit: () => widget.onValidate(false),
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
                            revert: true,
                          ),
                        );
                      }
                    },
                  ),
                ]
          : <Widget>[
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
                            revert: true,
                          ),
                        );
                        return oldValue;
                      }
                      if (newValue.text.contains('.')) {
                        int _totalDots = 0;
                        for (String char in newValue.text.split('')) {
                          if (char == '.') {
                            _totalDots++;
                            if (_totalDots > 1) {
                              break;
                            }
                          }
                        }
                        if (_totalDots == 1) {
                          List<String> _split = newValue.text.split('.');
                          if (_split.first != 'www') {
                            String _newText = 'www.' + newValue.text;
                            return newValue.copyWith(
                              text: _newText,
                              selection: TextSelection(
                                baseOffset: _newText.length,
                                extentOffset: _newText.length,
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
                      String _newText =
                          newValue.text.toLowerCase().replaceAll(' ', '_');

                      if (_newText.startsWith('_')) {
                        return oldValue;
                      }

                      if (_newText.length > 1) {
                        if (_newText[_newText.length - 1] == '_' &&
                            _newText[_newText.length - 2] == '_') {
                          return oldValue;
                        }
                      }

                      return newValue.copyWith(
                        text: _newText,
                        selection: TextSelection(
                          baseOffset: _newText.length,
                          extentOffset: _newText.length,
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
                    String _newText =
                        newValue.text.toLowerCase().replaceAll(' ', '-');

                    if (_newText.startsWith('-')) {
                      return oldValue;
                    }

                    if (_newText.length > 1) {
                      if (_newText[_newText.length - 1] == '-' &&
                          _newText[_newText.length - 2] == '-') {
                        return oldValue;
                      }
                    }

                    return newValue.copyWith(
                      text: _newText,
                      selection: TextSelection(
                        baseOffset: _newText.length,
                        extentOffset: _newText.length,
                      ),
                    );
                  }),
                ],
              ),
              VSeparators.normal(),
              Row(
                children: <Widget>[
                  Expanded(
                    child: RoundContainer(
                      padding: EdgeInsets.zero,
                      borderColor: kGreenColor,
                      borderWith: 1.5,
                      child: infoWidget(
                        context,
                        'We will show you the information you entered to verify one by one to make sure there are no mistakes.',
                      ),
                    ),
                  ),
                  HSeparators.normal(),
                  RoundContainer(
                    borderWith: 1.5,
                    padding: EdgeInsets.zero,
                    borderColor: kGreenColor,
                    child: RectangleButton(
                      width: 100,
                      color: Colors.transparent,
                      hoverColor: Colors.transparent,
                      child: const Text('Start'),
                      onPressed: () {
                        if (widget.webUrlController.text.isNotEmpty &&
                            widget
                                .firebaseProjectIDController.text.isNotEmpty &&
                            widget.firebaseProjectName.text.isNotEmpty) {
                          widget.onValidate(true);
                        } else {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            snackBarTile(
                              context,
                              'Please fill out all fields about your Firebase app.',
                              type: SnackBarType.warning,
                              revert: true,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
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
      color: Colors.blueGrey.withOpacity(0.2),
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
                    color: Colors.blueGrey.withOpacity(0.2),
                    icon: const Icon(Icons.edit_rounded, color: kYellowColor),
                    onPressed: widget.onEdit,
                  )
                : Row(
                    children: <Widget>[
                      SquareButton(
                        color: Colors.blueGrey.withOpacity(0.2),
                        icon: const Icon(Icons.close_rounded,
                            color: AppTheme.errorColor),
                        onPressed: widget.onEdit,
                      ),
                      HSeparators.small(),
                      SquareButton(
                        color: Colors.blueGrey.withOpacity(0.2),
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
