import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    try {
      // تهيئة Firebase مع خيارات مختلفة للويب والموبايل
      if (kIsWeb) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'AIzaSyBnK5YBi-bys6yi42C5LbabJAV_5cvIAZ0',
            authDomain: 'alemedu-app.firebaseapp.com',
            projectId: 'alemedu-app',
            storageBucket: 'alemedu-app.appspot.com',
            messagingSenderId: '629802140732',
            appId: '1:629802140732:android:ae6f2633248e46988cef39',
            measurementId: 'G-1234567890',
          ),
        );  
      } else {
        await Firebase.initializeApp();
      }
      
      // تهيئة Firebase Analytics
      FirebaseAnalytics.instance; // تهيئة Analytics بدون تخزين المرجع
      
      // تهيئة Firebase Crashlytics (فقط للمنصات المدعومة)
      if (!kIsWeb && !kDebugMode) {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
        FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
        
        // التقاط الأخطاء غير المتوقعة
        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
      }
      
    } catch (e) {
      rethrow; // إعادة رمي الخطأ للتعامل معه في مستوى أعلى
    }
  }
}
