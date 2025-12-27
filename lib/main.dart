import 'package:flutter/material.dart';
import 'package:yagsl_app/DataController.dart';
import 'package:yagsl_app/home_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MyApp()
    );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DataController(),
      child: MaterialApp(
        title: 'YAGSL Configurator',
        theme: ThemeData(primarySwatch: Colors.green, 
          appBarTheme: AppBarTheme(color: Color(0xff5bb201)),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green)
        ),
        debugShowCheckedModeBanner: false,
        home: HomePage(),
      ),
    );
  }
}
