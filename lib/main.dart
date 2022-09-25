import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
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

class Diaporama {
  String name;
  String date;

  List<Taches>? tache;

  Diaporama(this.name, this.date, [this.tache]);

  factory Diaporama.fromJson(dynamic json) {
    if (json['tache'] != null) {
      var tacheObJson = json['tache'] as List;
      List<Taches> _tache =
          tacheObJson.map((tacheJson) => Taches.fromJson(tacheJson)).toList();

      return Diaporama(json['name'] as String, json['date'] as String, _tache);
    } else {
      return Diaporama(json['name'] as String, json['date'] as String);
    }
  }
  @override
  String toString() {
    return '{ ${this.name}, ${this.date}, ${this.tache} }';
  }
}

class Taches {
  String kindOf;
  String link;
  int periode;

  Taches(this.kindOf, this.link, this.periode);

  factory Taches.fromJson(dynamic json) {
    return Taches(json['kindOf'] as String, json['link'] as String,
        json['periode'] as int);
  }

  @override
  String toString() {
    return '{ ${this.kindOf}, ${this.link}, ${this.periode} }';
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pub App',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'pubApp'),
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
  int _counter = 4;
  bool update = true;
  int nowPub = 0;
  late Socket socket;
  List<int> tacheSeconde = [5, 1, 10, 3, 14];

  void dataListenning() async {
    Socket.connect("localhost", 9000).then((Socket sock) {
      socket = sock;
      socket.listen(dataHandler,
          onError: errorHandler, onDone: doneHandler, cancelOnError: false);
      socket.add(utf8.encode('hello there from lcd'));
    }).catchError((Object e) {
      print("Unable to connect: $e");
      exit(1);
    });

    //Connect standard in to the socket
    stdin.listen((data) {
      socket.write('${String.fromCharCodes(data).trim()}\n');
      print(data);
    });
  }

  void dataHandler(data) {
    print(String.fromCharCodes(data).trim());

    if (String.fromCharCodes(data).contains('Update')) {
      print("update???????");
      setState(() {
        UpdatePub();
      });
    }
  }

  void errorHandler(error, StackTrace trace) {
    print(error);
  }

  void doneHandler() {
    //socket.destroy();
    //exit(0);
  }

  void UpdatePub() async {
    String testUpdate =
        '{"name": "test Diaporam", "date": "23/09/2022", "tache": [{"kindOf": "photo", "link": "http://localhost/pubserver/images/bison-3840x2160-grand-teton-national-park-wyoming-usa-bing-microsoft-23142.jpg","periode" : 60}, {"kindOf": "photo", "link": "https://www.tunisienumerique.com/wp-content/uploads/2019/08/Tunisie-Telecom.png","periode" : 30}]}';

    Diaporama complexTest = Diaporama.fromJson(jsonDecode(testUpdate));
    print(complexTest.toString);
    print(complexTest);
  }

  void startTimer() {
    print("Starting");
    _timer = Timer(
        Duration(minutes: 0, seconds: tacheSeconde[nowPub]),
        () => {
              print(_timer.tick),
              if (_counter == 0)
                {
                  setState(() {
                    _counter = 4;
                    nowPub = 0;
                    _timer.cancel();
                    startTimer();
                  })
                }
              else
                {
                  setState(() {
                    nowPub++;
                    _counter--;
                    startTimer();
                  })
                }
            });
  }

  @override
  void initState() {
    startTimer();
    dataListenning();
    UpdatePub();
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    socket.destroy();
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
            Image.network(pub[nowPub]),
            Text('$nowPub'),
            Text("Testings lags"),
          ],
        ),
      ),
    );
  }
}
