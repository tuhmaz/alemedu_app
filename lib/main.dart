import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/home/providers/classes_provider.dart';
import 'features/home/providers/subjects_provider.dart';
import 'features/home/providers/semesters_provider.dart';
import 'features/home/providers/articles_provider.dart';
import 'features/home/providers/news_provider.dart';
import 'features/dashboard/providers/profile_provider.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'core/constants/colors.dart';
import 'core/firebase/firebase_config.dart';
import 'core/localization/timeago_ar.dart';
import 'features/messages/providers/message_provider.dart';
import 'core/services/api_service.dart';
import 'features/home/providers/comments_provider.dart';
import 'features/home/services/comment_service.dart';
import 'features/home/providers/news_comments_provider.dart';
import 'features/home/services/news_comment_service.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await FirebaseConfig.initialize();

    timeago.setLocaleMessages('ar', TimeagoAr());

    MobileAds.instance.initialize();

    final apiService = ApiService(); // Get the singleton instance
    await apiService.initialize();

    runApp(
      MultiProvider(
        providers: [
          Provider<ApiService>.value(value: apiService),// Provide the singleton instance
          ChangeNotifierProvider(
            create: (_) => AuthProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => ClassesProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => SubjectsProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => SemestersProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => ArticlesProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => NewsProvider(
                context.read<ApiService>(), // Use the singleton instance
                NewsCommentService(context.read<ApiService>()) // Use the singleton instance
            ),
          ),
          ChangeNotifierProxyProvider<NewsProvider, NewsCommentsProvider>(
            create: (context) => NewsCommentsProvider(
                NewsCommentService(context.read<ApiService>()) // Use the singleton instance
            ),
            update: (BuildContext context, NewsProvider newsProvider, NewsCommentsProvider? previous) {
              previous?.updateCommentService(newsProvider.commentService);
              return previous ?? NewsCommentsProvider(newsProvider.commentService);
            },
          ),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
          ChangeNotifierProvider(
            create: (context) => MessageProvider(
              context.read<ApiService>(), // Use the singleton instance
            ),
          ),
          ChangeNotifierProvider( // Use the singleton instance
            create: (context) => NotificationProvider(
              context.read<ApiService>(),
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => CommentsProvider(
              CommentService(context.read<ApiService>()),
            ),
          ),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'حدث خطأ أثناء بدء التطبيق\n$e',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alemedu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Cairo',
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'SA'),
      ],
      locale: const Locale('ar', 'SA'),
      initialRoute: '/home',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
