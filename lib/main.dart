import 'package:finance_manager/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: '자산관리 앱',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'NotoSansKR',

        // 1. ColorScheme의 surface(표면색)를 흰색으로 지정
        colorScheme: ColorScheme.light(
          primary: Colors.blue,
          surface: Colors.white, // M3 기본 표면색을 순백색으로 오버라이드
        ),

        // 2. Scaffold 및 NavigationRail 배경을 흰색으로 고정
        scaffoldBackgroundColor: Colors.white,
        navigationRailTheme: const NavigationRailThemeData(
          backgroundColor: Colors.white,
        ),
      ),

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('ko', 'KR'),

      routerConfig: router,
    );
  }
}
