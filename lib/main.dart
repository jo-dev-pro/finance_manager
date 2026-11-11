import 'package:flutter/material.dart';
import 'package:finance_manager/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // .env 파일 로드
  await dotenv.load(fileName: ".env");
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
        fontFamily: GoogleFonts.notoSansKr().fontFamily,

        // 1. ColorScheme의 surface(표면색)를 흰색으로 지정
        colorScheme: ColorScheme.light(
          primary: Colors.indigo,
          surface: Colors.white, // M3 기본 표면색을 순백색으로 오버라이드
        ),

        // 2. Scaffold 및 NavigationRail 배경을 흰색으로 고정
        // scaffoldBackgroundColor: Colors.white,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAFAFA), // 바탕색과 동일하게 맞추어 일체감 부여
          elevation: 0, // 앱바 밑의 그림자 제거 (선택, 토스 스타일)
          iconTheme: IconThemeData(color: Colors.black), // 앱바 아이콘 색상
          titleTextStyle: TextStyle(
            // 앱바 제목 텍스트 스타일
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
      locale: const Locale('ko', 'KR'),

      routerConfig: router,
      builder: (context, child) {
        // 현재 실행 중인 플랫폼이 모바일(안드로이드 또는 iOS)인지 확인
        final bool isMobilePlatform =
            Theme.of(context).platform == TargetPlatform.android ||
            Theme.of(context).platform == TargetPlatform.iOS;

        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.0)),
          child:
              isMobilePlatform
                  ? InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 3.0,
                    clipBehavior: Clip.none,
                    child: child ?? const SizedBox(),
                  )
                  : (child ?? const SizedBox()), // PC/웹에서는 기본 스크롤 유지
        );
      },

    );
  }
}
