import 'package:covoitcalc_app/pages/benefit_estimator_page.dart';
import 'package:covoitcalc_app/pages/cost_estimation_page.dart';
import 'package:covoitcalc_app/pages/planning_page.dart';
import 'package:covoitcalc_app/pages/vehicle_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:covoitcalc_app/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(CovoitCalcApp());
}

class CovoitCalcApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // hides debug banner
      title: 'CovoitCalc',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF6F6F6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1D3557),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
        ),
      ),
      // home: LoginPage(),
      home: PlanningPage(),
    );
  }
}
