import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_message_demo/firebase_message.dart';
import 'package:firebase_message_demo/firebase_options.dart';
import 'package:firebase_message_demo/message_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

String token = '';
String apnToken = '';


// FirebaseMessage背景訊息Handler (必須放在main上方)
//
// 透過註冊onBackgroundMessage處理程序來處理後台訊息
// 收到訊息時會產生隔離（僅限 Android，iOS/macOS 不需要單獨的隔離）
// 即使應用程式未執行，您也可以處理訊息。
//
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('背景通知: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化Firebase Core
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 註冊背景通知Handler
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
    provisional: false,
    sound: true,
  );

  // 取得裝置的Firebase Token
  final firebaseDeviceToken = await FirebaseMessaging.instance.getToken();
  if (firebaseDeviceToken != null) {
    token = firebaseDeviceToken;
  }

  // 取得裝置的APNs Token
  final firebaseAPNToken = await FirebaseMessaging.instance.getAPNSToken();
  if (firebaseAPNToken != null) {
    apnToken = firebaseAPNToken;
  }

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MessageProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Message 範例',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            brightness: Brightness.dark, seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {


  @override
  void initState() {
    super.initState();
    // 監聽開啟通知
    openedAppMessage(context);

    // 監聽前景通知
    foregroundMessage(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Firebase Message'),
        ),
        body: Consumer<MessageProvider>(builder: (context, provider, child) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Device Token"),
                          TextField(
                            controller: TextEditingController()..text = token,
                          ),
                          const SizedBox(height: 8.0),
                          const Text("APNs Token"),
                          TextField(
                            controller: TextEditingController()..text = apnToken,
                          ),
                        ])),
              ),
              // Other slivers for Tab 1 content
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        Message message = provider.messages[index];

                        return InkWell(
                          onTap: () => showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => Dialog(
                                  surfaceTintColor: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text('Message Id: ${message.id.substring(0, 10)}...'),
                                        const SizedBox(height: 15),
                                        Text('Message Title: ${message.title}'),
                                        const SizedBox(height: 15),
                                        Text('Message Body: ${message.body}'),
                                        const SizedBox(height: 15),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    ),
                                  )
                              )
                          ),
                          child: ListTile(
                            title: Text(message.title),
                            subtitle: Text(message.body),
                          ),
                        );
                  },
                  childCount: provider.messages.length,
                ),
              ),
            ],
          );
        }));
  }
}
