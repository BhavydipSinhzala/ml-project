import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const SmartLoanPredictorApp());
}

class SmartLoanPredictorApp extends StatelessWidget {
  const SmartLoanPredictorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Loan Risk Predictor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFDFBF7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E293B),
          background: const Color(0xFFFDFBF7),
          surface: Colors.white,
          primary: const Color(0xFF1E293B),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF1E293B), width: 2),
          ),
        ),
      ),
      home: const LoanPredictorScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// DATA MODELS & LOGISTIC REGRESSION BINARY CLASSIFICATION ALGORITHM
// -----------------------------------------------------------------------------
class LoanApplicant {
  int age = 38;
  double income = 82000;
  double loanAmount = 28000;
  int creditScore = 740;
  int monthsEmployed = 60;
  int numCreditLines = 4;
  double interestRate = 9.5;
  int loanTerm = 36;
  double dtiRatio = 0.28;

  String education = "Bachelor's";
  String employmentType = "Full-time";
  String maritalStatus = "Married";
  String loanPurpose = "Business";

  bool hasMortgage = true;
  bool hasDependents = false;
  bool hasCoSigner = true;

  PredictionResult evaluateRisk() {
    double z = -2.0;

    // Credit score impact
    double normCredit = (creditScore - 650) / 100.0;
    z -= normCredit * 0.85;

    // DTI ratio impact
    z += (dtiRatio - 0.35) * 3.5;

    // Interest rate impact
    z += (interestRate - 10.0) * 0.18;

    // LTI Ratio
    double ltiRatio = income > 0 ? (loanAmount / income) : 2.0;
    z += (ltiRatio - 0.4) * 1.6;

    // Employment
    double yearsEmployed = monthsEmployed / 12.0;
    z -= min(yearsEmployed, 10.0) * 0.09;

    if (employmentType == 'Unemployed') z += 1.8;
    if (employmentType == 'Part-time') z += 0.7;
    if (employmentType == 'Full-time') z -= 0.35;

    if (education == 'PhD') z -= 0.45;
    if (education == "Master's") z -= 0.35;

    if (hasCoSigner) z -= 0.70;
    if (hasMortgage) z -= 0.40;
    if (hasDependents) z += 0.20;

    // Logistic Sigmoid P(Default=1) = 1 / (1 + e^-z)
    double prob = 1.0 / (1.0 + exp(-z));
    double percentage = (prob * 100).clamp(0.1, 99.9);

    int defaultClass = percentage >= 50.0 ? 1 : 0;
    String defaultPredictionText = defaultClass == 1 ? "YES" : "NO";
    bool isApproved = defaultClass == 0;

    return PredictionResult(
      isApproved: isApproved,
      defaultClass: defaultClass,
      defaultPredictionText: defaultPredictionText,
      defaultProbability: percentage,
      title: isApproved ? "Default Predicted: NO (Class 0)" : "Default Predicted: YES (Class 1)",
      subtitle: isApproved
          ? "Logistic Regression model predicts applicant will NOT default on loan repayment."
          : "Logistic Regression model predicts high likelihood of loan default.",
      riskTier: isApproved ? "Low Default Risk (Class 0)" : "High Default Risk (Class 1)",
      positiveFactors: creditScore >= 700 ? ["High Credit Score ($creditScore/900)", "Has Co-Signer Attached"] : ["Has Co-Signer"],
      riskFactors: dtiRatio > 0.35 ? ["High DTI Ratio (${(dtiRatio * 100).toStringAsFixed(0)}%)"] : [],
      recommendedActions: isApproved
          ? ["Loan Approved for disbursement under standard terms.", "Set up automated monthly payments."]
          : ["Reduce debt to lower DTI ratio under 0.35", "Add a qualified Co-Signer or increase down payment."],
    );
  }
}

class PredictionResult {
  final bool isApproved;
  final int defaultClass;
  final String defaultPredictionText;
  final double defaultProbability;
  final String title;
  final String subtitle;
  final String riskTier;
  final List<String> positiveFactors;
  final List<String> riskFactors;
  final List<String> recommendedActions;

  PredictionResult({
    required this.isApproved,
    required this.defaultClass,
    required this.defaultPredictionText,
    required this.defaultProbability,
    required this.title,
    required this.subtitle,
    required this.riskTier,
    required this.positiveFactors,
    required this.riskFactors,
    required this.recommendedActions,
  });
}

// -----------------------------------------------------------------------------
// MAIN PREDICTOR SCREEN WIDGET
// -----------------------------------------------------------------------------
class LoanPredictorScreen extends StatefulWidget {
  const LoanPredictorScreen({Key? key}) : super(key: key);

  @override
  State<LoanPredictorScreen> createState() => _LoanPredictorScreenState();
}

class _LoanPredictorScreenState extends State<LoanPredictorScreen> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final LoanApplicant _applicant = LoanApplicant();

  PredictionResult? _result;
  bool _isLoading = false;

  late TextEditingController _ageCtrl;
  late TextEditingController _incomeCtrl;
  late TextEditingController _loanAmtCtrl;
  late TextEditingController _creditCtrl;
  late TextEditingController _monthsCtrl;
  late TextEditingController _creditLinesCtrl;
  late TextEditingController _rateCtrl;
  late TextEditingController _termCtrl;
  late TextEditingController _dtiCtrl;

  @override
  void initState() {
    super.initState();
    _ageCtrl = TextEditingController(text: _applicant.age.toString());
    _incomeCtrl = TextEditingController(text: _applicant.income.toStringAsFixed(0));
    _loanAmtCtrl = TextEditingController(text: _applicant.loanAmount.toStringAsFixed(0));
    _creditCtrl = TextEditingController(text: _applicant.creditScore.toString());
    _monthsCtrl = TextEditingController(text: _applicant.monthsEmployed.toString());
    _creditLinesCtrl = TextEditingController(text: _applicant.numCreditLines.toString());
    _rateCtrl = TextEditingController(text: _applicant.interestRate.toStringAsFixed(1));
    _termCtrl = TextEditingController(text: _applicant.loanTerm.toString());
    _dtiCtrl = TextEditingController(text: _applicant.dtiRatio.toStringAsFixed(2));
  }

  void _onPredict() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      _applicant.age = int.tryParse(_ageCtrl.text) ?? 35;
      _applicant.income = double.tryParse(_incomeCtrl.text) ?? 75000;
      _applicant.loanAmount = double.tryParse(_loanAmtCtrl.text) ?? 25000;
      _applicant.creditScore = int.tryParse(_creditCtrl.text) ?? 700;
      _applicant.monthsEmployed = int.tryParse(_monthsCtrl.text) ?? 36;
      _applicant.numCreditLines = int.tryParse(_creditLinesCtrl.text) ?? 4;
      _applicant.interestRate = double.tryParse(_rateCtrl.text) ?? 10.0;
      _applicant.loanTerm = int.tryParse(_termCtrl.text) ?? 36;
      _applicant.dtiRatio = double.tryParse(_dtiCtrl.text) ?? 0.35;

      await Future.delayed(const Duration(milliseconds: 1000));

      if (mounted) {
        setState(() {
          _isLoading = false;
          _result = _applicant.evaluateRisk();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Smart Loan Risk Predictor",
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextFormField(controller: _ageCtrl, decoration: const InputDecoration(labelText: "Age")),
                      const SizedBox(height: 12),
                      TextFormField(controller: _incomeCtrl, decoration: const InputDecoration(labelText: "Income (\$)")),
                      const SizedBox(height: 12),
                      TextFormField(controller: _loanAmtCtrl, decoration: const InputDecoration(labelText: "Loan Amount (\$)")),
                      const SizedBox(height: 12),
                      TextFormField(controller: _creditCtrl, decoration: const InputDecoration(labelText: "Credit Score (300-900)")),
                      const SizedBox(height: 12),
                      TextFormField(controller: _dtiCtrl, decoration: const InputDecoration(labelText: "DTI Ratio (0.0-1.0)")),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _onPredict,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B)),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Predict Default Risk", style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_result != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _result!.isApproved ? const Color(0xFFE6F4EA) : const Color(0xFFFDF2E9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text("Default Prediction: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _result!.isApproved ? const Color(0xFF15803D) : const Color(0xFFC05621),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "${_result!.defaultPredictionText} (Class ${_result!.defaultClass})",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(_result!.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(_result!.subtitle),
                    ],
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
