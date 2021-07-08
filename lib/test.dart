// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => MainNotifier()),
//         ChangeNotifierProvider(create: (_) => ChangeNotifier1()),
//         ChangeNotifierProvider(create: (_) => ChangeNotifier2()),
//       ],
//       child: MaterialApp(
//         title: 'Material App',
//         home: Home(),
//       ),
//     );
//   }
// }

// enum NotifierType { first, second }

// class Home extends StatefulWidget {
//   const Home({Key? key}) : super(key: key);

//   @override
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   @override
//   void didChangeDependencies() {
//     context.read<MainNotifier>().startChecking(context);
//     super.didChangeDependencies();
//   }

//   Widget get _text {
//     if (context.watch<MainNotifier>().value == NotifierType.first) {
//       return Text(context.watch<ChangeNotifier1>().value);
//     }
//     return Text(context.watch<ChangeNotifier2>().value);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Material App Bar'),
//       ),
//       body: Center(child: Container(child: _text)),
//     );
//   }
// }

// class MainNotifier extends ValueNotifier<NotifierType> {
//   MainNotifier() : super(NotifierType.first);

//   Future<void> startChecking(BuildContext context) async {
//     await context.read<ChangeNotifier1>().check();
//     value = NotifierType.second;
//     await context.read<ChangeNotifier2>().check();
//   }
// }

// class BaseNotifier extends ValueNotifier<String> {
//   BaseNotifier([String value = 'Please wait checking']) : super(value);
//   final random = Random();
//   Future<void> check() async {
//     await Future.delayed(const Duration(seconds: 1));
//     if (random.nextBool()) {
//       value = '${this.runtimeType} Checking done with error';
//     } else {
//       value = '${this.runtimeType} Checking done successfully';
//     }
//     await Future.delayed(const Duration(seconds: 1));
//   }
// }

// class ChangeNotifier1 extends BaseNotifier {
//   ChangeNotifier1() : super('Please wait checking ChangeNotifier1');
// }

// class ChangeNotifier2 extends BaseNotifier {
//   ChangeNotifier2() : super('Please wait checking ChangeNotifier2');
// }
