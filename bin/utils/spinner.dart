// 🎯 Dart imports:
import 'dart:async';
import 'dart:io';
import 'dart:isolate';

Isolate? _spinnerIsolate;

Future<Isolate> startSpinner() async {
  stdout.write('\x1B[?25l');
  return _spinnerIsolate ?? await Isolate.spawn(_animate, null);
}

void stopSpinner() {
  _spinnerIsolate?.kill(priority: Isolate.immediate);
  _spinnerIsolate = null;
  stdout.write('\x1B[2K\x1B[1G');
  stdout.write('\x1B[?25h');
}

Future<void> _animate(void t) async {
  Spinner().animate();
}

abstract class Spinner {
  dynamic frames;
  int framePeriod;

  Spinner._(this.frames, this.framePeriod);

  factory Spinner() {
    return Loader();
  }

  void animate() {
    int frame = 0;
    while (true) {
      stdout.write(frames[frame]);
      frame = ((frame + 1) % frames.length).toInt();
      sleep(Duration(milliseconds: framePeriod));
      stdout.write('\x1B[2K\x1B[1G'); // Clear line and put cursor at col 1.
    }
  }
}

class Loader extends Spinner {
  static const List<String> _frames = <String>['⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷'];
  static const int _framePeriod = 80;

  Loader() : super._(_frames, _framePeriod);
}
