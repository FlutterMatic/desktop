// 🎯 Dart imports:
import 'dart:async';
import 'dart:math';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/dialog_templates/fun/type_result.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/meta/utils/app_theme.dart';
import 'package:fluttermatic/meta/views/tabs/components/circle_chart.dart';

class TypeTestChallengeDialog extends StatefulWidget {
  const TypeTestChallengeDialog({Key? key}) : super(key: key);

  @override
  _TypeTestChallengeDialogState createState() =>
      _TypeTestChallengeDialogState();
}

class _TypeTestChallengeDialogState extends State<TypeTestChallengeDialog> {
  List<String> _words = <String>[];

  // Utils
  int _currentWord = 0; // Sum of total wrong and total correct
  bool _errorWord = false;

  bool _startedCountdown = false;

  // Progress
  int _totalWrongWords = 0;
  int _totalCorrectWords = 0;
  int _totalCharsPerMin = 0;

  int _secondsLeft = 60;

  void _startCountdown() {
    setState(() => _startedCountdown = true);

    const Duration oneSec = Duration(seconds: 1);
    Timer.periodic(oneSec, (Timer timer) {
      if (_secondsLeft < 1) {
        timer.cancel();
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (_) => TypeTestResultDialog(
            totalWrongWords: _totalWrongWords,
            totalCorrectWords: _totalCorrectWords,
            totalCharsPerMin: _totalCharsPerMin,
          ),
        );
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  @override
  void initState() {
    // Set the words randomly to the variable [_words].
    List<String> _list = _speedTestWords.toList();
    _list.shuffle(Random());
    setState(() => _words = _list);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      width: 600,
      child: Column(
        children: <Widget>[
          // const DialogHeader(title: 'Type Speed Test'),
          const Text(
            'TYPING SPEED TEST',
            style: TextStyle(color: Colors.grey),
          ),
          VSeparators.small(),
          const Text(
            'Test your typing skills',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          VSeparators.xLarge(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CircularPercentIndicator(
                backgroundColor:
                    (AppTheme.darkTheme.buttonTheme.colorScheme?.primary ??
                            kGreenColor)
                        .withOpacity(0.2),
                size: 100,
                lineWidth: 6,
                percent: _secondsLeft / 60,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      _secondsLeft.toString(),
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5),
                    ),
                    const Text(
                      'seconds',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              HSeparators.xLarge(),
              HSeparators.normal(),
              // words/min rate
              Column(
                children: <Widget>[
                  RoundContainer(
                    width: 60,
                    height: 60,
                    padding: EdgeInsets.zero,
                    child: Center(
                      child: Text(
                        _totalCorrectWords.toString(),
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5),
                      ),
                    ),
                  ),
                  VSeparators.xSmall(),
                  const Text(
                    'words/min',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              HSeparators.normal(),
              // chars/min rate
              Column(
                children: <Widget>[
                  RoundContainer(
                    padding: EdgeInsets.zero,
                    width: 60,
                    height: 60,
                    child: Center(
                      child: Text(
                        _totalCharsPerMin.toString(),
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5),
                      ),
                    ),
                  ),
                  VSeparators.xSmall(),
                  const Text(
                    'chars/min',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              HSeparators.normal(),
              // accuracy rate
              Column(
                children: <Widget>[
                  RoundContainer(
                    width: 60,
                    height: 60,
                    padding: EdgeInsets.zero,
                    child: Center(
                      child: Text(
                        _totalCorrectWords == 0
                            ? '0'
                            : '${((_totalCorrectWords / (_totalCorrectWords + _totalWrongWords)) * 100).round()}',
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5),
                      ),
                    ),
                  ),
                  VSeparators.xSmall(),
                  const Text(
                    '% accuracy',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          VSeparators.xLarge(),
          RoundContainer(
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: <Widget>[
                  for (int i = 0; i < _words.length - _currentWord; i++)
                    Text(
                      _words.elementAt(i + _currentWord) + ' ',
                      style: TextStyle(
                        fontSize: 20,
                        color: _currentWord == (i + _currentWord)
                            ? (_errorWord ? AppTheme.errorColor : kGreenColor)
                            : Colors.grey,
                      ),
                    )
                ],
              ),
            ),
          ),
          VSeparators.normal(),
          RoundContainer(
            padding: EdgeInsets.zero,
            child: TextFormField(
              inputFormatters: <TextInputFormatter>[
                TextInputFormatter.withFunction(
                  (TextEditingValue oldValue, TextEditingValue newValue) {
                    if (!_startedCountdown) {
                      _startCountdown();
                    }

                    // Ignore if only white spaces
                    if (newValue.text.length != newValue.text.trim().length &&
                        newValue.text.trim().isEmpty) {
                      return oldValue;
                    }

                    if (_words.elementAt(_currentWord).length <
                        newValue.text.trim().length) {
                      setState(() {
                        _errorWord = true;
                      });
                    }

                    // If it ends with a space, that means we need to confirm
                    // and compare to move on to the next word.
                    if (newValue.text.endsWith(' ')) {
                      // If the word is correct, add to correct words
                      if (_words.elementAt(_currentWord) ==
                          newValue.text.trim()) {
                        setState(() {
                          _totalCorrectWords++;
                          _totalCharsPerMin +=
                              newValue.text.trim().length; // Without spaces
                          _errorWord = false;
                          _currentWord++;
                        });
                      } else {
                        setState(() {
                          _totalWrongWords++;
                          _errorWord = false;
                          _currentWord++;
                        });
                      }
                      return const TextEditingValue(text: '');
                    }

                    // Remove all if attempting to clear input box
                    if (newValue.text.trim().isEmpty) {
                      return newValue;
                    }

                    // --- Validate the word so far.
                    List<String> _correctLetters =
                        _words.elementAt(_currentWord).split('').toList();

                    List<String> _inputLetters =
                        newValue.text.trim().split('').toList();

                    bool _soFarCorrect = true;

                    // Check if the input is correct so far
                    for (int i = 0; i < _inputLetters.length; i++) {
                      if (_correctLetters.elementAt(i) !=
                          _inputLetters.elementAt(i)) {
                        _soFarCorrect = false;
                        break;
                      }
                    }

                    setState(() => _errorWord = !_soFarCorrect);

                    return newValue;
                  },
                ),
              ],
              autofocus: true,
              autocorrect: false,
              decoration: InputDecoration(
                hintText: _currentWord == 0 && _secondsLeft == 60
                    ? 'Start whenever you are ready'
                    : 'Type here...',
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                border: const OutlineInputBorder(),
                fillColor: Colors.transparent,
                iconColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                prefixIconColor: Colors.transparent,
                suffixIconColor: Colors.transparent,
              ),
            ),
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}

// A list of ~200 common programming words and English words.
const Set<String> _speedTestWords = <String>{
  'abstract',
  'as',
  'assert',
  'async',
  'await',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'default',
  'deferred',
  'do',
  'dynamic',
  'else',
  'enum',
  'export',
  'extends',
  'external',
  'factory',
  'false',
  'final',
  'finally',
  'for',
  'get',
  'poison',
  'short',
  'letter',
  'guiltless',
  'gamy',
  'girls',
  'chalk',
  'near',
  'harmonious',
  'profuse',
  'subtract',
  'vagabond',
  'concentrate',
  'painstaking',
  'fire',
  'exchange',
  'lush',
  'cultured',
  'jobless',
  'steady',
  'fallacious',
  'humdrum',
  'good',
  'amount',
  'coast',
  'invincible',
  'crime',
  'immense',
  'cheer',
  'baby',
  'hot',
  'late',
  'rampant',
  'helpful',
  'library',
  'comfortable',
  'show',
  'squeal',
  'afternoon',
  'race',
  'true',
  'straw',
  'giant',
  'needless',
  'tent',
  'cheat',
  'wasteful',
  'marry',
  'sticks',
  'volleyball',
  'crook',
  'plate',
  'old',
  'frighten',
  'crowd',
  'bake',
  'unbiased',
  'fascinated',
  'attend',
  'agonizing',
  'majestic',
  'night',
  'love',
  'cast',
  'tongue',
  'angry',
  'smart',
  'juvenile',
  'utter',
  'scrawny',
  'unequaled',
  'stare',
  'glove',
  'changeable',
  'dream',
  'arithmetic',
  'truthful',
  'rings',
  'wealth',
  'frightening',
  'cent',
  'entertaining',
  'homeless',
  'kitty',
  'enthusiastic',
  'windy',
  'grain',
  'irritate',
  'hat',
  'absorbed',
  'lame',
  'open',
  'upbeat',
  'innocent',
  'wonderful',
  'normal',
  'idea',
  'morning',
  'sable',
  'pickle',
  'possess',
  'bent',
  'repulsive',
  'sprout',
  'cow',
  'nifty',
  'mundane',
  'tough',
  'makeshift',
  'blush',
  'hulking',
  'swanky',
  'baseball',
  'eyes',
  'cattle',
  'scrub',
  'grandmother',
  'damp',
  'bite',
  'past',
  'optimal',
  'school',
  'strap',
  'red',
  'remarkable',
  'insect',
  'glorious',
  'bump',
  'cabbage',
  'groan',
  'railway',
  'fair',
  'vest',
  'condemned',
  'enter',
  'highfalutin',
  'carpenter',
  'float',
  'first',
  'tricky',
  'alluring',
  'adorable',
  'greasy',
  'spell',
  'car',
  'quaint',
  'sneaky',
  'misty',
  'spill',
  'attach',
  'memorize',
  'meat',
  'suggest',
  'wrong',
  'crash',
  'scatter',
  'scarf',
  'size',
  'load',
  'hallowed',
  'sulky',
  'arrest',
  'reading',
  'worm',
  'cloistered',
  'freezing',
  'compete',
  'pour',
  'ethereal',
  'tin',
  'breathe',
  'curved',
  'spoil',
  'placid',
  'gleaming',
  'hydrant',
  'weary',
  'prick',
  'destroy',
  'berry',
  'ahead',
  'cannon',
  'license',
  'beneficial',
  'allow',
  'squeak',
  'certain',
  'report',
  'didactic',
  'mom',
  'jagged',
  'flat',
  'list',
  'psychedelic',
  'judge',
  'command',
  'unfasten',
  'year',
  'fang',
  'reign',
};
