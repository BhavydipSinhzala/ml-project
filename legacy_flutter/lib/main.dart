import 'package:flutter/material.dart';

import 'screens/loan_predictor_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const LoanPredictorApp());
}

class LoanPredictorApp extends StatelessWidget {
  const LoanPredictorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Loan Risk Predictor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoanPredictorScreen(),
    );
  }
}
