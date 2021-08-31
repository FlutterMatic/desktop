/// Prints the given message to the console with a new line.
void println(String text) {
  print('$text\n');
}

/// Prints the given message to the console as ***`Warning`***.
void printWarning(String text) {
  print('\x1B[33m$text\x1B[0m');
}

/// Prints the given message to the console as ***`Warning`*** with the new line.
void printWarningln(String text) {
  printWarning('$text\n');
}

/// Prints the given message to the console as ***`Error`***.
void printError(String text) {
  print('\x1B[31m$text\x1B[0m');
}

/// Prints the given message to the console as ***`Error`*** with the new line.
void printErrorln(String text) {
  printError('$text\n');
}

/// Prints the given message to the console as ***`Information`***.
void printInfo(String text) {
  print('\x1B[36m$text\x1B[0m');
}

/// Prints the given message to the console as ***`Information`*** with the new line.
void printInfoln(String text) {
  printInfo('$text\n');
}
