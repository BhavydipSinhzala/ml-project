import 'package:flutter/material.dart';

import '../models/loan_applicant.dart';
import '../models/prediction_result.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_switch.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/model_info_section.dart';
import '../widgets/result_card.dart';

class LoanPredictorScreen extends StatefulWidget {
  const LoanPredictorScreen({Key? key}) : super(key: key);

  @override
  State<LoanPredictorScreen> createState() => _LoanPredictorScreenState();
}

class _LoanPredictorScreenState extends State<LoanPredictorScreen> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  // Model & State
  final LoanApplicant _applicant = LoanApplicant();
  PredictionResult? _predictionResult;
  bool _isLoading = false;

  // Controllers for Numeric TextFields
  late TextEditingController _ageController;
  late TextEditingController _incomeController;
  late TextEditingController _loanAmountController;
  late TextEditingController _creditScoreController;
  late TextEditingController _monthsEmployedController;
  late TextEditingController _numCreditLinesController;
  late TextEditingController _interestRateController;
  late TextEditingController _loanTermController;
  late TextEditingController _dtiRatioController;

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController(text: _applicant.age.toString());
    _incomeController = TextEditingController(text: _applicant.income.toStringAsFixed(0));
    _loanAmountController = TextEditingController(text: _applicant.loanAmount.toStringAsFixed(0));
    _creditScoreController = TextEditingController(text: _applicant.creditScore.toString());
    _monthsEmployedController = TextEditingController(text: _applicant.monthsEmployed.toString());
    _numCreditLinesController = TextEditingController(text: _applicant.numCreditLines.toString());
    _interestRateController = TextEditingController(text: _applicant.interestRate.toStringAsFixed(1));
    _loanTermController = TextEditingController(text: _applicant.loanTerm.toString());
    _dtiRatioController = TextEditingController(text: _applicant.dtiRatio.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _ageController.dispose();
    _incomeController.dispose();
    _loanAmountController.dispose();
    _creditScoreController.dispose();
    _monthsEmployedController.dispose();
    _numCreditLinesController.dispose();
    _interestRateController.dispose();
    _loanTermController.dispose();
    _dtiRatioController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handlePrediction() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Update applicant state from controllers
      _applicant.age = int.tryParse(_ageController.text) ?? 35;
      _applicant.income = double.tryParse(_incomeController.text) ?? 75000;
      _applicant.loanAmount = double.tryParse(_loanAmountController.text) ?? 25000;
      _applicant.creditScore = int.tryParse(_creditScoreController.text) ?? 700;
      _applicant.monthsEmployed = int.tryParse(_monthsEmployedController.text) ?? 36;
      _applicant.numCreditLines = int.tryParse(_numCreditLinesController.text) ?? 4;
      _applicant.interestRate = double.tryParse(_interestRateController.text) ?? 10.0;
      _applicant.loanTerm = int.tryParse(_loanTermController.text) ?? 36;
      _applicant.dtiRatio = double.tryParse(_dtiRatioController.text) ?? 0.35;

      // Simulate ML API Call delay
      await Future.delayed(const Duration(milliseconds: 1200));

      final result = _applicant.evaluateRisk();

      if (mounted) {
        setState(() {
          _isLoading = false;
          _predictionResult = result;
        });

        // Smooth scroll to prediction result card
        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollController.animateTo(
            450.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic,
          );
        });
      }
    }
  }

  void _resetPrediction() {
    setState(() {
      _predictionResult = null;
    });
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 900;
    final bool isTablet = screenWidth > 600 && screenWidth <= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: isDesktop ? 40 : 20,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Smart Loan Risk Predictor",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  "AI-Powered Credit Evaluation & Risk Intelligence",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderResting),
              ),
              child: Row(
                children: const [
                  Icon(Icons.bolt_rounded, size: 14, color: AppColors.primaryNavy),
                  SizedBox(width: 4),
                  Text(
                    "Model v2.4 (Active)",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 60 : (isTablet ? 30 : 16),
            vertical: 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isDesktop ? 32 : 20),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.borderResting, width: 1),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.assignment_ind_rounded, color: AppColors.primaryNavy, size: 22),
                              SizedBox(width: 10),
                              Text(
                                "Applicant Credit Assessment Profile",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Fill out all applicant parameters required by the XGBoost Risk Classification Engine.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Section 1: Personal & Demographics
                          _buildSectionHeader("1. Personal & Demographics"),
                          const SizedBox(height: 12),
                          _buildGridGroup(
                            columns: isDesktop ? 3 : (isTablet ? 2 : 1),
                            children: [
                              CustomTextField(
                                label: "Age (Years)",
                                hint: "e.g. 35",
                                icon: Icons.person_outline_rounded,
                                controller: _ageController,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return "Required";
                                  final num = int.tryParse(v);
                                  if (num == null || num < 18 || num > 100) return "Valid age: 18-100";
                                  return null;
                                },
                              ),
                              CustomDropdownMenu<String>(
                                label: "Education Level",
                                value: _applicant.education,
                                icon: Icons.school_outlined,
                                items: const ["Bachelor's", "High School", "Master's", "PhD"],
                                onChanged: (v) => setState(() => _applicant.education = v!),
                                itemLabelBuilder: (item) => item,
                              ),
                              CustomDropdownMenu<String>(
                                label: "Marital Status",
                                value: _applicant.maritalStatus,
                                icon: Icons.favorite_border_rounded,
                                items: const ["Married", "Divorced", "Single"],
                                onChanged: (v) => setState(() => _applicant.maritalStatus = v!),
                                itemLabelBuilder: (item) => item,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Section 2: Employment & Income Metrics
                          _buildSectionHeader("2. Financial & Employment Metrics"),
                          const SizedBox(height: 12),
                          _buildGridGroup(
                            columns: isDesktop ? 3 : (isTablet ? 2 : 1),
                            children: [
                              CustomTextField(
                                label: "Annual Income",
                                hint: "e.g. 75000",
                                prefixText: "\$ ",
                                icon: Icons.payments_outlined,
                                controller: _incomeController,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return "Required";
                                  if (double.tryParse(v) == null) return "Enter valid income";
                                  return null;
                                },
                              ),
                              CustomDropdownMenu<String>(
                                label: "Employment Type",
                                value: _applicant.employmentType,
                                icon: Icons.work_outline_rounded,
                                items: const ["Full-time", "Part-time", "Self-employed", "Unemployed"],
                                onChanged: (v) => setState(() => _applicant.employmentType = v!),
                                itemLabelBuilder: (item) => item,
                              ),
                              CustomTextField(
                                label: "Months Employed",
                                hint: "e.g. 48",
                                icon: Icons.access_time_rounded,
                                controller: _monthsEmployedController,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return "Required";
                                  if (int.tryParse(v) == null) return "Invalid months";
                                  return null;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Section 3: Credit History & Debt Exposure
                          _buildSectionHeader("3. Credit History & Debt Ratios"),
                          const SizedBox(height: 12),
                          _buildGridGroup(
                            columns: isDesktop ? 3 : (isTablet ? 2 : 1),
                            children: [
                              CustomTextField(
                                label: "Credit Score (300 - 900)",
                                hint: "300 - 900",
                                icon: Icons.speed_rounded,
                                controller: _creditScoreController,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return "Required";
                                  final num = int.tryParse(v);
                                  if (num == null || num < 300 || num > 900) return "Score must be 300-900";
                                  return null;
                                },
                              ),
                              CustomTextField(
                                label: "DTI Ratio (Debt-to-Income)",
                                hint: "e.g. 0.35",
                                suffixText: "ratio",
                                icon: Icons.pie_chart_outline_rounded,
                                controller: _dtiRatioController,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return "Required";
                                  final val = double.tryParse(v);
                                  if (val == null || val < 0 || val > 1.0) return "Valid ratio: 0.0 - 1.0";
                                  return null;
                                },
                              ),
                              CustomTextField(
                                label: "Number of Credit Lines",
                                hint: "e.g. 4",
                                icon: Icons.credit_card_rounded,
                                controller: _numCreditLinesController,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return "Required";
                                  if (int.tryParse(v) == null) return "Invalid count";
                                  return null;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Section 4: Loan Specifications
                          _buildSectionHeader("4. Loan Terms & Specifications"),
                          const SizedBox(height: 12),
                          _buildGridGroup(
                            columns: isDesktop ? 3 : (isTablet ? 2 : 1),
                            children: [
                              CustomTextField(
                                label: "Requested Loan Amount",
                                hint: "e.g. 25000",
                                prefixText: "\$ ",
                                icon: Icons.account_balance_wallet_outlined,
                                controller: _loanAmountController,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return "Required";
                                  if (double.tryParse(v) == null) return "Invalid amount";
                                  return null;
                                },
                              ),
                              CustomTextField(
                                label: "Interest Rate (%)",
                                hint: "e.g. 10.5",
                                suffixText: "%",
                                icon: Icons.percent_rounded,
                                controller: _interestRateController,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return "Required";
                                  if (double.tryParse(v) == null) return "Invalid rate";
                                  return null;
                                },
                              ),
                              CustomTextField(
                                label: "Loan Term (Months)",
                                hint: "e.g. 36",
                                icon: Icons.calendar_month_outlined,
                                controller: _loanTermController,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return "Required";
                                  if (int.tryParse(v) == null) return "Invalid term";
                                  return null;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          CustomDropdownMenu<String>(
                            label: "Loan Purpose",
                            value: _applicant.loanPurpose,
                            icon: Icons.category_outlined,
                            items: const ["Auto", "Business", "Education", "Home", "Other"],
                            onChanged: (v) => setState(() => _applicant.loanPurpose = v!),
                            itemLabelBuilder: (item) => item,
                          ),
                          const SizedBox(height: 24),

                          // Section 5: Risk Flags & Collateral
                          _buildSectionHeader("5. Collateral & Risk Mitigants"),
                          const SizedBox(height: 12),
                          _buildGridGroup(
                            columns: isDesktop ? 3 : (isTablet ? 2 : 1),
                            children: [
                              CustomSwitchTile(
                                title: "Has Mortgage",
                                subtitle: "Existing property mortgage",
                                icon: Icons.home_outlined,
                                value: _applicant.hasMortgage,
                                onChanged: (v) => setState(() => _applicant.hasMortgage = v),
                              ),
                              CustomSwitchTile(
                                title: "Has Dependents",
                                subtitle: "Financially dependent family",
                                icon: Icons.family_restroom_rounded,
                                value: _applicant.hasDependents,
                                onChanged: (v) => setState(() => _applicant.hasDependents = v),
                              ),
                              CustomSwitchTile(
                                title: "Has Co-Signer",
                                subtitle: "Guarantor added to loan",
                                icon: Icons.verified_user_outlined,
                                value: _applicant.hasCoSigner,
                                onChanged: (v) => setState(() => _applicant.hasCoSigner = v),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Primary Call-to-Action Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handlePrediction,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryNavy,
                                disabledBackgroundColor: AppColors.primaryNavy.withOpacity(0.7),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: _isLoading
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          ),
                                          SizedBox(width: 14),
                                          Text(
                                            "Evaluating ML Model...",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Text(
                                        "Predict Default Risk",
                                        key: ValueKey("btn_text"),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Prediction Result Banner (Dynamically displayed upon completion)
                  if (_predictionResult != null) ...[
                    const SizedBox(height: 28),
                    PredictionResultCard(
                      result: _predictionResult!,
                      onReset: _resetPrediction,
                    ),
                  ],

                  const SizedBox(height: 28),

                  // Model Information Accordion Section
                  const ModelInfoSection(),

                  const SizedBox(height: 40),

                  // Footer
                  Center(
                    child: Text(
                      "Powered by AI Risk Assessment Engine • Dataset v1.0.4",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.primaryNavy,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildGridGroup({required int columns, required List<Widget> children}) {
    if (columns == 1) {
      return Column(
        children: children
            .map((child) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: child,
                ))
            .toList(),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: columns == 3 ? 2.5 : 2.8,
      children: children,
    );
  }
}
