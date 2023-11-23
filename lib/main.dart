import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_message_demo/firebase_options.dart';
import 'package:firebase_message_demo/notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

// FirebaseMessage背景訊息Handler
//
// 透過註冊onBackgroundMessage處理程序來處理後台訊息
// 收到訊息時會產生隔離（僅限 Android，iOS/macOS 不需要單獨的隔離）
// 即使應用程式未執行，您也可以處理訊息。
//
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('接收到背景訊息(Background Message): ${message.messageId}');
}

String Token = '';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化Firebase Core
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 註冊背景訊息Handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 向使用者發送開啟「通知」請求
  //
  // 使用settings.authorizationStatus查詢狀態
  // authorized ：使用者授予權限。
  // denied ：使用者拒絕權限。
  // notDetermined ：使用者尚未選擇是否授予權限。
  // provisional ：使用者授予臨時權限
  //
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: true,
    sound: true,
  );

  // 取得裝置的Firebase Token
  final firebaseDeviceToken = await FirebaseMessaging.instance.getToken();
  if (firebaseDeviceToken != null) {
    Token = firebaseDeviceToken;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Message Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Firebase Message Demo'),
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
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("開啟通知: ${message.notification!.body ?? '無法取得訊息內容'}"),
    ));
    print('開啟通知: ${message.messageId}');
  }

  @override
  void initState() {
    super.initState();
    setupInteractedMessage();

    // 監聽FirebaseMessage前景訊息
    //
    // 預設情況下，在 Android 和 iOS 上，當應用程式位於前台時到達的通知訊息不會顯示可見的通知。
    // 但仍可以覆寫此行為
    //
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("前景通知: ${message.notification!.body ?? '無法取得訊息內容'}"),
      ));
      print('前景訊息: ${message.messageId}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: TextField(
        controller: TextEditingController()..text=Token,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
