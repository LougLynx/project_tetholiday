import 'package:flutter/material.dart';
import 'package:project_tetholiday/data/database/app_database.dart';
import 'package:project_tetholiday/di.dart';
import 'package:project_tetholiday/views/home_page.dart';
import 'package:project_tetholiday/views/login_page.dart';
import 'package:project_tetholiday/views/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.ensureOpen();
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
        '/main': (context) => const MainPage(),
      },
    );
  }
}
