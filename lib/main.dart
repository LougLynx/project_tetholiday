import 'package:flutter/material.dart';
import 'package:project_tetholiday/di.dart';
import 'package:project_tetholiday/views/auth/home_page.dart';
import 'package:project_tetholiday/views/auth/login_page.dart';
import 'package:project_tetholiday/views/auth/register_page.dart';
import 'package:project_tetholiday/views/home/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mâm Cỗ Việt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEE5B2B),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/login': (context) => LoginPage(viewModel: Di.getLoginViewModel()),
        '/register': (context) => RegisterPage(viewModel: Di.getLoginViewModel()),
        '/main': (context) => const MainPage(),
      },
    );
  }
}
