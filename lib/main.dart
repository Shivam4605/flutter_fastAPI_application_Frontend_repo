import 'package:fast_api_and_flutter/provider/connectivity_check_provider.dart';
import 'package:fast_api_and_flutter/provider/theam_provider.dart';
import 'package:fast_api_and_flutter/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/task_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),

        ChangeNotifierProvider.value(value: themeProvider),

        ChangeNotifierProvider(create: (_) => InternetProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData.light(),

      darkTheme: ThemeData.dark(),

      themeMode: themeProvider.themeMode,

      home: const HomeScreen(),
    );
  }
}
