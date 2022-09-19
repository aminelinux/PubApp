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
  //int _t = 0;
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
    stdin.listen(
        (data) => socket.write('${String.fromCharCodes(data).trim()}\n'));
  }
  // Socket.connect("127.0.0.1", 9000).then((Socket sock) {
  //   socket = sock;
  //   print(socket);
  //   print("socket paired");
  //   socket.listen(
  //     dataHandler,
  //     onError: errorHandler,
  //     cancelOnError: false,
  //   );
  //   socket.add(utf8.encode('hello'));
  // }).catchError((Object e) {
  //   print("Unable to connect : $e");
  // });
  //socket.add(utf8.encode('hello'));

  // stdin.listen(
  //     (data) => socket.write(new String.fromCharCodes(data).trim() + '\n'));

  void dataHandler(data) {
    print(String.fromCharCodes(data).trim());
  }

  void errorHandler(error, StackTrace trace) {
    print(error);
  }

  void doneHandler() {
    //socket.destroy();
    //exit(0);
  }

  // void startTimer() {
  //   var tempsAlloce = Duration(seconds: tacheSeconde[_t]);
  //   _timer = Timer.periodic(tempsAlloce, (Timer timer) {
  //     if (_counter == 0) {
  //       setState(() {
  //         print("closing");
  //         timer.cancel();
  //       });
  //     } else {
  //       setState(() {});
  //       _t++;
  //       if (_t > 4) {
  //         _t = 0;
  //       }
  //     }
  //   });
  // }
  void UpdatePub() async {}
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
