## Flutter
- Note that Flutter will be installed in a separate directory called `fluttermatic`. Any other tool installed by FlutterMatic will also be installed in this directory. This helps make it easier for us to manage the installation of Flutter and other tools. Flutter will still behave as if it was installed in the default `src` directory.

## Installing Flutter
Flutter is installed and extracted automatically by FlutterMatic. We use a temporary directory to install Flutter and then move it to the `fluttermatic` directory. This makes sure that in case something goes wrong, the `fluttermatic` directory doesn't get cluttered with old versions of Flutter or partially installed versions.

If Flutter is already installed on your device, we will skip installing Flutter. We will also make sure to set the environment variables so that Flutter can be used in the future and interacted directly with the CLI.

## Keeping Flutter Updated
Keeping in mind that it is always a good idea to keep any tool up-to-date, with that in mind, we will keep checking to make sure you always have the latest version of Flutter installed on your device.

## Editors
- You can install up to two editors that work best with Flutter:
    - Visual Studio Code (VS Code)
    - Android Studio (Studio)
These editors will be installed in the `fluttermatic` directory. We will make sure to set any necessary environment variables so that they can be interacted with in the CLI.

### Keeping the Editors Updated
Keeping editors updated is always a good idea. However, because of some limitations in the way that we can communicate with the editors, you will need to manually check for updates in your editors to keep your editors up-to-date always.

### Emulators
Emulators are used to run Flutter apps on your device. They are used to test your apps and make sure that they work as expected. If you need to install an emulator, we will help guide you through the process later after the editor installation is complete.

## Extensions
- You can install extensions for Flutter in your editors. These extensions are used to make your editors more user-friendly and compatible to open `dart` files which are used to write Flutter apps.
    - Flutter for VS Code [VS Code](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)
    - Flutter for Android Studio [Studio](https://plugins.jetbrains.com/plugin/9212-flutter)

## Git
Git is a version control system that is used to track changes in your code. Git is installed automatically and required when installing Flutter. It is used with the pub service. This service is how you will be able to download packages from [pub.dev](https://pub.dev). We will make sure to set the environment variables so that Git can be used in the future and interacted directly with the CLI.
 
### Keeping Git Updated
Keeping in mind that it is always a good idea to keep any tool up-to-date, with that in mind, we will keep checking to make sure you always have the latest version of Git installed on your device.

## Java
Java is a programming language that is used to write programs for Android. Java is recommended when using Flutter for Android. It helps avoid a lot of platform-specific errors for Android that are common. We will make sure to set the environment variables so that Java can be used in the future and interacted directly with the CLI.

### Keeping Java Updated
Keeping in mind that it is always a good idea to keep any tool up-to-date, with that in mind, we will keep checking to make sure you always have the latest version of Java installed on your device.