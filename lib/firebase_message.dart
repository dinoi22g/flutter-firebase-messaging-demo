import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_message_demo/message_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 監聽FirebaseMessage前景訊息 (開啟狀態)
//
// 預設情況下，在 Android 和 iOS 上，當應用程式位於前台時到達的通知訊息不會顯示可見的通知。
//
void foregroundMessage(BuildContext context) {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // 透過snackBar顯示內容
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("前景通知: ${message.notification!.body ?? '無法取得訊息內容'}"),
    ));

    // 將通知訊息加入MessageProvider
    Provider.of<MessageProvider>(context, listen: false).add(message.messageId, message.notification!.title, message.notification!.body);

    // Debug print
    print('前景訊息: ${message.messageId}');
  });
}


// 監聽FirebaseMessage開啟訊息
//
// 當使用者點開通知開啟/跳轉回APP後透過該方法處理其他行為
//
Future<void> openedAppMessage(BuildContext context) async {
  // 當APP完全中止時透過通知開啟時的訊息，一旦使用， RemoteMessage將被刪除
  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    if (context.mounted) {
      // 透過snackBar顯示內容
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("開啟通知: ${initialMessage.notification!.body ?? '無法取得訊息內容'}"),
      ));

      // 將通知訊息加入MessageProvider
      Provider.of<MessageProvider>(context, listen: false).add(initialMessage.messageId, initialMessage.notification!.title, initialMessage.notification!.body);
    }

    // Debug print
    print('開啟通知: ${initialMessage.messageId}');
  }

  // 當APP從背景狀態開啟時發布RemoteMessage Stream
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    // 透過snackBar顯示內容
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("開啟通知: ${message.notification!.body ?? '無法取得訊息內容'}"),
    ));

    // 將通知訊息加入MessageProvider
    Provider.of<MessageProvider>(context, listen: false).add(message.messageId, message.notification!.title, message.notification!.body);

    // Debug print
    print('開啟通知: ${message.messageId}');
  });
}
