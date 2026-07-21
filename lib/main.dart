import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Chưa chạy `flutterfire configure` nên chưa có firebase_options.dart —
  // gọi initializeApp() không kèm `options`, dựa vào GoogleService-Info.plist/
  // google-services.json native (cũng chưa có, cần thêm ở Phase 1 thật).
  // Sau khi chạy flutterfire configure, đổi thành:
  //   Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
  await Firebase.initializeApp();

  // Không báo cáo crash khi chạy debug trên máy phát triển, tránh làm nhiễu
  // Crashlytics dashboard bằng lỗi phát sinh lúc code chưa hoàn chỉnh.
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const App());
}
