// ignore_for_file: unnecessary_this

import 'dart:io';
import 'dart:convert';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:async';

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
    await windowManager.setSize(const Size(largeur, longeur));
    await windowManager.setMinimumSize(const Size(largeur, longeur));
    await windowManager.setMaximumSize(const Size(largeur, longeur));
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

  int tacheLength() {
    if (tache != null) {
      return tache!.length;
    } else {
      return 0;
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
  Diaporama? complexTest;
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
        updatePub();
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

  void updatePub() async {
    String testUpdate =
        '{"name": "test Diaporam", "date": "23/09/2022", "tache": [{"kindOf": "photo", "link": "http://localhost/pubserver/images/bison-3840x2160-grand-teton-national-park-wyoming-usa-bing-microsoft-23142.jpg","periode" : 4}, {"kindOf": "photo", "link": "https://www.tunisienumerique.com/wp-content/uploads/2019/08/Tunisie-Telecom.png","periode" : 10}]}';

    complexTest = Diaporama.fromJson(jsonDecode(testUpdate));
    print(complexTest.toString);
    print(complexTest);
    _counter = complexTest!.tacheLength() - 1;

    startTimer();
  }

  void startTimer() {
    print("Starting");
    _timer = Timer(
        Duration(minutes: 0, seconds: complexTest!.tache![nowPub].periode),
        () => {
              print(_timer.tick),
              if (_counter == 0)
                {
                  setState(() {
                    _counter = complexTest!.tacheLength() - 1;
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
    updatePub();
    dataListenning();
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

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (complexTest!.tache![nowPub].kindOf.contains("photo"))
              Image.network(complexTest!.tache![nowPub].link),
            if (complexTest!.tache![nowPub].kindOf.contains("video"))
              Image.network(complexTest!.tache![nowPub].link),
            Text('$nowPub'),
            const Text("Testings lags"),
          ],
        ),
      ),
    );
  }
}
