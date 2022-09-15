import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:async';
import 'package:http/http.dart';

void main() async {
  /**
   * const double wi,hei pour fixé largeur,longeur réspectivement 
   * peut etre initialisé a partir d'une DB
   */
  const double largeur = 400;
  const double longeur = 700;
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setSize(Size(largeur, longeur));
    await windowManager.setMinimumSize(Size(largeur, longeur));
    await windowManager.setMaximumSize(Size(largeur, longeur));
    await windowManager.setAsFrameless();
    await windowManager.center();
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Timer _timer;
  final int _counter = 4;
  int _t = 0;
  List<int> tacheSeconde = [5, 1, 10, 3, 14];

  void startTimer() {
    var tempsAlloce = Duration(seconds: tacheSeconde[_t]);
    _timer = Timer.periodic(tempsAlloce, (Timer timer) {
      if (_counter == 0) {
        setState(() {
          print("closing");
          timer.cancel();
        });
      } else {
        setState(() {});
        _t++;
        if (_t > 4) {
          _t = 0;
        }
      }
    });
  }

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    const List<String> pub = [
      "http://localhost/pubserver/images/bison-3840x2160-grand-teton-national-park-wyoming-usa-bing-microsoft-23142.jpg",
      "https://picsum.photos/250?image=9",
      "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c4/Orange-Fruit-Pieces.jpg/220px-Orange-Fruit-Pieces.jpg",
      "https://www.tunisienumerique.com/wp-content/uploads/2019/08/Tunisie-Telecom.png",
      "https://www.delice.tn/wp-content/uploads/2021/12/LOGO-MENU.png",
    ];

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(pub[_t]),
            Text('$_t'),
            Text("Testings lags"),
          ],
        ),
      ),
    );
  }
}
