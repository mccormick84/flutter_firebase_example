import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_example/memoPage.dart';
import 'package:flutter/material.dart';
import 'tabsPage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// 파이어베이스 초기화
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorObservers: <NavigatorObserver>[observer],
      home: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // 에러 발생시 출력
            return const Center(
              child: Text('Error'),
            );
          }
          // 선언 완료 후 표시할 위젯
          if (snapshot.connectionState == ConnectionState.done) {
            _initFirebaseMessaging(context);
            _getToken();
            return MemoPage();
          }
          // 선언되는 동안 표시할 위젯
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  _initFirebaseMessaging(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      debugPrint(event.notification!.title);
      debugPrint(event.notification!.body);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('알림'),
              content: Text(event.notification!.body!),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'))
              ],
            );
          });
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
  }

  void _getToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    print('messaging.getToken(), ${await messaging.getToken()}');
  }
}

class FirebaseApp extends StatefulWidget {
  FirebaseApp({Key? key, required this.analytics, required this.observer})
      : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _FirebaseAppState createState() => _FirebaseAppState(analytics, observer);
}

class _FirebaseAppState extends State<FirebaseApp> {
  _FirebaseAppState(this.analytics, this.observer);

  final FirebaseAnalyticsObserver observer;
  final FirebaseAnalytics analytics;
  String _message = '';

  void setMessages(String message) {
    setState(() {
      _message = message;
    });
  }

  Future<void> _sendAnalyticsEvent() async {
    // 애널리틱스의 logEvent를 호출해 test_event라는 키 값으로 데이터 저장
    await analytics.logEvent(
      name: 'test_event',
      parameters: <String, dynamic>{
        'string': 'hello flutter',
        'int': 100,
      },
    );
    setMessages('Analytics 보내기 성공');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Example'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            ElevatedButton(
                onPressed: _sendAnalyticsEvent, child: const Text('테스트')),
            Text(
              _message,
              style: const TextStyle(color: Colors.blueAccent),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.tab),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute<TabsPage>(
                settings: const RouteSettings(name: '/tab'),
                builder: (BuildContext context) {
                  return TabsPage(observer);
                }));
          }),
    );
  }
}
