## Flutter Documentation
- Note that Flutter will be installed in a separate directory called `fluttermatic`. Any other tool installed by FlutterMatic will also be installed in this directory. This helps making it easier for us to manage the installation of Flutter and other tools. Flutter will still behave as if it was installed in the default `src` directory.

## Installing Flutter
Flutter is installed and extracted automatically by FlutterMatic. We use a temporary directory to install Flutter and then move it to the `fluttermatic` directory. This makes sure that in case something goes wrong, the `fluttermatic` directory doesn't get cluttered with old versions of Flutter or partially installed versions.

If Flutter is already installed on your device, we will skip installing Flutter. We will also make sure to set the environment variables, so that Flutter can be used in the future and interacted directly with the CLI.

## Keeping Flutter Updated
Keeping in mind that it is always a good idea to keep any tool up-to-date, with that in mind, we will keep checking to make sure you always have the latest version of Flutter installed on your device.