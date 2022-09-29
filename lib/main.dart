// ignore_for_file: unnecessary_this

import 'dart:io';
import 'dart:convert';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

late Diaporama complexTest;
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
  //video pub plugins initializer
  DartVLC.initialize();

  UpdatePub pubInit = UpdatePub();
  print("main complextest");
  print(pubInit.complexTest1);
  complexTest = pubInit.complexTest1;
  runApp(const MyApp());
}

class UpdatePub {
  Diaporama complexTest1 = Diaporama('initDiap', 'intDate', [
    Taches(
        "photo",
        "http://localhost/pubserver/images/bison-3840x2160-grand-teton-national-park-wyoming-usa-bing-microsoft-23142.jpg",
        20)
  ]);
  late http.Response response;

  UpdatePub() {
    update();
  }

  void update() async {
    try {
      response = await http
          .get((Uri.parse("http://localhost/pubserver/getDiapo.php")));
      if (response.statusCode == 200) {
        print('if response ok .');
        print(response.body);
        final diap = json.decode(response.body)[0]["pub"];
        //var x = diap[0];

        print('******** json.decode ==');
        print(diap);
        print('**********');
        //print(x);

        complexTest = Diaporama.fromJson(jsonDecode(diap));
      }
    } catch (e) {
      print(e);
    }
  }
}

class Diaporama {
  String name = "init";
  String date = "init";

  List<Taches>? tache = [
    Taches(
        "photo",
        "http://localhost/pubserver/images/bison-3840x2160-grand-teton-national-park-wyoming-usa-bing-microsoft-23142.jpg",
        10)
  ];
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
      return tache!.length - 1;
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
  String kindOf = "photo";
  String link =
      "http://localhost/pubserver/images/bison-3840x2160-grand-teton-national-park-wyoming-usa-bing-microsoft-23142.jpg";
  int periode = 20;

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
  //Diaporama? complexTest;
  late Timer _timer;
  int _counter = 4;
  bool update = true;
  int nowPub = 0;
  late Socket socket;
  Player player =
      Player(id: 10, videoDimensions: const VideoDimensions(400, 700));
  Media? vid;
  //List<int> tacheSeconde = [5, 1, 10, 3, 14];

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

  Future updatePub() async {
    UpdatePub pubInit = UpdatePub();
    print("main complextest");
    print(pubInit.complexTest1);
    complexTest = pubInit.complexTest1;
    print(complexTest.toString);
    print(complexTest);
    print(complexTest.toString);
    print(complexTest);
    _counter = complexTest.tacheLength();
    if (complexTest.tache![nowPub].kindOf.contains('video')) {
      vid = Media.network(complexTest.tache![nowPub].link);
    }

    startTimer();
  }

  void startTimer() {
    print("Starting");
    _timer = Timer(
        Duration(minutes: 0, seconds: complexTest.tache![nowPub].periode),
        () => {
              print(_timer.tick),
              if (_counter == 0)
                {
                  setState(() {
                    _counter = complexTest.tacheLength();
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
                    if (complexTest.tache![nowPub].kindOf.contains('video')) {
                      vid = Media.network(complexTest.tache![nowPub].link);
                    }
                    player.open(Media.network(complexTest.tache![nowPub].link));
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
            if (complexTest.tache![nowPub].kindOf.contains("photo"))
              Image.network(complexTest.tache![nowPub].link),
            if (complexTest.tache![nowPub].kindOf.contains("video"))
              Video(
                player: player,
                width: 400,
                height: 700,
              ),
            if (complexTest.tache![nowPub].kindOf.contains("text"))
              Text(complexTest.tache![nowPub].link),
            const Text("Testings lags"),
          ],
        ),
      ),
    );
  }
}
