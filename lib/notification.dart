import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class LocalNotification {
  final FlutterLocalNotificationsPlugin np = FlutterLocalNotificationsPlugin();

  init() async {
    var android = const AndroidInitializationSettings("@mipmap/ic_launcher");
    var ios = const DarwinInitializationSettings();

    await np.initialize(InitializationSettings(android: android, iOS: ios) );
  }

  Future<String?> getDetail() async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails = !kIsWeb &&
        Platform.isLinux
        ? null
        : await np.getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      return notificationAppLaunchDetails!.notificationResponse?.payload;
    }
    return null;
  }

  @pragma('vm:entry-point')
  void notificationTapBackground(NotificationResponse notificationResponse) {
    // ignore: avoid_print
    print('notification(${notificationResponse.id}) action tapped: '
        '${notificationResponse.actionId} with'
        ' payload: ${notificationResponse.payload}');
    if (notificationResponse.input?.isNotEmpty ?? false) {
      // ignore: avoid_print
      print(
          'notification action tapped with input: ${notificationResponse.input}');
    }
  }


  /// params为点击通知时，可以拿到的参数，title和body仅仅是展示作用
  /// Map params = {};
  /// params['type'] = "100";
  /// params['id'] = "10086";
  /// params['content'] = "content";
  /// notification.send("title", "content",params: json.encode(params));
  ///
  /// notificationId指定时，不在根据时间生成
  void send(String title, String body, {int? notificationId, String? params, String channelId="channelId", String channelName="一般通知"}) {
    // 构建描述
    var androidDetails = AndroidNotificationDetails(
      //区分不同渠道的标识
      channelId,

      //channelName渠道描述不要随意填写，会显示在手机设置，本app 、通知列表中，
      //规范写法根据业务：比如： 重要通知，一般通知、或者，交易通知、消息通知、等
      channelName,

      //通知的级别
      importance: Importance.max,
      priority: Priority.high,

    );
    //ios配置选项相对较少
    var iosDetails = const DarwinNotificationDetails();
    var details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    // 显示通知, 第一个参数是id,id如果一致则会覆盖之前的通知
    // String? payload, 点击时可以拿到的参数
    np.show(notificationId ?? DateTime.now().millisecondsSinceEpoch >> 10,
        title, body, details,
        payload: params);
  }

  ///清除所有通知
  void cleanNotification() {
    np.cancelAll();
  }

  ///清除指定id的通知
  /// `tag`参数指定Android标签。 如果提供，
  /// 那么同时匹配 id 和 tag 的通知将会
  /// 被取消。 `tag` 对其他平台没有影响。
  void cancelNotification(int id, {String? tag}) {
    np.cancel(id, tag: tag);
  }
}
