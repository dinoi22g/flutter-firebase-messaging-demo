# Firebase Messaging Demo

## 基本設置

### 1. 建立專案
```
flutter create firbase_messaging_demo --org com.dinoi22g
```

### 2. 安裝套件

```
flutter pub add firebase_core
flutter pub add firebase_messaging
```

### 3. 安裝Firebase CLI

**Windows**

至[FirebaseCLI](https://firebase.google.com/docs/cli?hl=zh-tw)下載


**Linux/MacOS**
```
curl -sL https://firebase.tools | bash
```

安裝完後使用```firebase login```進行登入


### 4. 啟用flutterfire_cli (若失敗請重新嘗試)

```
dart pub global activate flutterfire_cli
```


### 5. 設定firebase congifure

至[Firebase Console](https://console.firebase.google.com/u/0/?hl=zh-tw)新增一個專案

執行以下命令，並選擇剛剛新建的專案
```
flutterfire configure
```

配置完成後分別會產生三個檔案
- android/app/ : google-services.json
- ios/Runner/ : GoogleService-Info.plist
- lib/ : firebase_options.dart

### 6. 設定Android

- **確保使用的模擬器有GOOGLE PLAY服務**
- **必須編譯成release才能夠在關閉時仍接受訊息**

- **android/build.gradle**
```
buildscript {
    ext.kotlin_version = '1.8.10' // 版本調整為1.8.10 (版本太低編譯會出錯)
    ...

    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.0' // 新增這行
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        classpath 'com.google.gms:google-services:4.4.0' // 新增這行
    }
}
```

- **android/app/build.gradle**
```
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin" 
    id 'com.google.gms.google-services' // 新增這行
}
```

### 設定iOS (參考[使用 Flutter Firebase 建構聊天室 APP](https://hackmd.io/@WangShuan/SySYUmVf3))

- **下載APNs檔案 (需確認為開發者帳戶)**

1. 於 Apple Developer 頁面最下方點擊進入 Certificates, IDs, & Profiles 頁面
2. 於左側選單點擊進入 keys 頁面，點擊加號新增 key
3. 設置 Key Name 並勾選 APNs
4. 點擊右上角 Continue，接著確認配置無誤繼續點擊 Confirm
5. 下載 key 檔案(注意：該檔案僅能下載一次，若遺失檔案就只能刪除現有的 key 並重新建立一個 key 了)

- **設置APP ID**
  
1. 回到 Certificates, IDs, & Profiles 頁面，點擊進入 Identifiers 頁面
2. 點擊加號新增，選擇 App ID 點擊 Continue
3. 輸入簡短的描述(FLutter Chat Example 之類即可)、填上 Bundle ID(於 /ios/Runner.xcodeproj/project.pbxproj 文件中可找到 PRODUCT_BUNDLE_IDENTIFIER)
4. 往頁面下方滾動，確保有勾選 “Push Notifications” 後點擊右上角 Continue，確認配置無誤繼續點擊 Confirm

- **設置Xcode**
1. 用 Xcode 開啟 cahtapp/ios
2. 點選 Runner 並於右側選單切換至 Signing & Capabilities
3. 點擊 “＋Capability” 選擇 “Push Notifications”(點兩下啟用)
4. 再次點擊 “＋Capability” 選擇 “Background Modes”(點兩下啟用)
5. 於 “Background Modes” 中勾選 “Background fetch” 跟 “Remote notifications”

- **上傳 APNs key 到 Firebase 專案**
 於 Firebase 中點擊左上角專案總覽旁的齒輪，並點選專案設定，切換至 “雲端通訊”
2. 往下滾到 “Apple 應用程式設定” 於 APN 驗證金鑰處點擊上傳，上傳步驟 2 下載的 .p8 檔案
3. 輸入金鑰 ID(於 Certificates, IDs, & Profiles 頁面進入 keys 後可看到) 與團隊 ID(在 Certificates, IDs, & Profiles 頁面的右上角可看到)

- **ios/Runner/AppDelegate.swift**
```
if #available(iOS 10.0, *) {
  UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
}
...
return super.application(application, didFinishLaunchingWithOptions: launchOptions)
```

### 設定Flutter

```
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 向使用者發送開啟「通知」請求
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

  // 取得Token，用於發送通知給指定裝置
  final firebaseDeviceToken = await FirebaseMessaging.instance.getToken();
  if (firebaseDeviceToken != null) {
    print(firebaseDeviceToken);
  }
  ...
}
```

### 開啟監聽

```
//FirebaseMessage背景訊息Handler (必須放在main上方)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('背景通知: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化Firebase Core
  ...

  // 註冊背景通知Handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  ...
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();

    // 監聽前景(Foreground)通知
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('前景訊息: ${message.messageId}');
    });

    // 監聽開啟(OpenedApp)通知
    Future<void> openedAppMessage(BuildContext context) async {
      // 當APP完全中止時透過通知開啟時的訊息，一旦使用， RemoteMessage將被刪除
      RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    
      if (initialMessage != null) {
        print('開啟通知: ${initialMessage.messageId}');
      }
    
      // 當APP從背景狀態開啟時發布RemoteMessage Stream
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('開啟通知: ${message.messageId}');
      });
    }
  }
  ...
}
```

### 完成

可以嘗試發送訊息了！
