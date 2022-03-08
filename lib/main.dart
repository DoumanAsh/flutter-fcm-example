import 'dart:async';
import 'dart:convert' show json;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import 'config.dart' show DefaultFirebaseConfig;

//MANABE: on web background messages can only be received within JS worker
//        need to test and determine how to propagate to flutter
Future<void> fcmBackgroundCb(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(options: DefaultFirebaseConfig.platformOptions);
  print('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
//MANABE: This must be first call
  await Firebase.initializeApp(options: DefaultFirebaseConfig.platformOptions);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.setAutoInitEnabled(true);
//MANABE: This is necessary to prompt user to permit notifications.
//        Need to investigate what to do in case of now permissions
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  //MANABE: Open firebase console: Go Project Settings -> Web Configuration -> Generate key
  //        After keys are generated there should be section with `Web Push certificates` with key pair.
  //        This key pair can be used by _all_ apps to receive its unique token.
  String token = await messaging.getToken(vapidKey: "BPiRLu_eYDOU-F_S8mWkbW3rDVNfqFErvzO_m9wyVdLzhRg1pbEXo2eTZvc5eqMBF74HD8uk_HhOiWnR-Fo5AfU") ?? "<unknown>";
  FirebaseMessaging.onBackgroundMessage(fcmBackgroundCb);
  runApp(MyApp(token: token, messaging: messaging));
}

class MyApp extends StatelessWidget {
  final FirebaseMessaging messaging;
  final String token;
  MyApp({Key? key, required this.token, required this.messaging}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page', token: this.token, messaging: this.messaging),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title, required this.token, required this.messaging}) : super(key: key);

  final String title;
  final String token;
  final FirebaseMessaging messaging;

  @override
  State<MyHomePage> createState() => _MyHomePageState(token: this.token, messaging: this.messaging);
}

class _MyHomePageState extends State<MyHomePage> {
  String token;
  final FirebaseMessaging messaging;
  List<RemoteMessage> notifications = [];
  late Stream<String> tokenRefreshStream;

  _MyHomePageState({required this.token, required this.messaging});

  void addMessage(RemoteMessage msg) {
    print("INFO: New message ${msg.messageId}");
    setState(() {
        notifications.add(msg);
    });
  }

  void setFcmToken(String token) {
    print("INFO: Token refresh $token");
    setState(() {
        this.token = token;
    });
  }

  @override
  void initState() {
      //MANABE: Listening to this stream to refresh app's token.
      //        App should notify server about changes whenever it happens.
      this.tokenRefreshStream = this.messaging.onTokenRefresh;
      this.tokenRefreshStream.listen((String? token) {
          if (token != null) {
              setFcmToken(token);
          }
      });

      //MANABE: Initial notification when app goes online from background/terminated state
      //        If present you probably want to present it to user
      messaging.getInitialMessage().then((RemoteMessage? msg) {
          if (msg != null) {
              addMessage(msg);
          }
      });

      //MANABE: Listen to all messages while app is in foreground(actively used)
      FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
          print("Received message");
          this.addMessage(msg);
      });

      super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
              if (notifications.length == 0)
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                    child: Text("Trigger Notification"),
                    onPressed: () {
                        sendPushMessageToWeb();
                    }
                  )
              ,
              ListView.builder(
                shrinkWrap: true,
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                    RemoteMessage msg = notifications[index];
                    String id = msg.messageId ?? "<UNKNOWN ID>";
                    String title = msg.notification?.title ?? "<empty title>";
                    return ListTile(
                      title: Text(
                        "$title($id)",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
                      ),
                      subtitle: Text(
                        msg.notification?.body ?? "<empty body>",
                        style: TextStyle(fontStyle: FontStyle.italic, fontSize: 60.0),
                      ),
                    );
                }
              )
          ],
        ),
      ),
    );
  }

  //send notification
  sendPushMessageToWeb() async {
    //MANABE: This is example how to send notification to self using token.
    //        Authorization key is taken from `Project Settings`->`Cloud Messaging`->`Project credentials`->`Server key`
    print("Send notification to token=$token");
    try {
      await http
          .post(
            Uri.parse('https://fcm.googleapis.com/fcm/send'),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization':
                  'key=AAAA97FwvTo:APA91bH_TOLViBZ-ei1DV3CMZrtfWWwOTOicxGmaU7nU3jsW8rMZhGt4quwPEbiyAcV7TbbRsxlwEPL0BAN_WOj5dr0wFqUO4MC9UF7CKVh6VIfIaO0U2dkjIsyjtVMbuMXuB2R-Zlvc'
            },
            body: json.encode({
              'to': token,
              'message': {
                'token': token,
              },
              "notification": {
                "title": "Test Notification",
                "body": "App triggers notification"
              }
            }),
          )
          .then((value) => print(value.body));
      print('FCM request for web sent!');
    } catch (e) {
      print(e);
    }
  }
}
