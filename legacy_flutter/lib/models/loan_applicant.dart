import 'dart:math';
import 'prediction_result.dart';

class LoanApplicant {
  // Numeric Inputs
  int age;
  double income;
  double loanAmount;
  int creditScore;
  int monthsEmployed;
  int numCreditLines;
  double interestRate;
  int loanTerm;
  double dtiRatio;

  // Dropdown Selections
  String education;
  String employmentType;
  String maritalStatus;
  String loanPurpose;

  // Boolean Switches
  bool hasMortgage;
  bool hasDependents;
  bool hasCoSigner;

  LoanApplicant({
    this.age = 38,
    this.income = 82000.0,
    this.loanAmount = 28000.0,
    this.creditScore = 740,
    this.monthsEmployed = 60,
    this.numCreditLines = 4,
    this.interestRate = 9.5,
    this.loanTerm = 36,
    this.dtiRatio = 0.28,
    this.education = "Bachelor's",
    this.employmentType = "Full-time",
    this.maritalStatus = "Married",
    this.loanPurpose = "Business",
    this.hasMortgage = true,
    this.hasDependents = false,
    this.hasCoSigner = true,
  });

  /// Evaluates binary classification using Logistic Regression formula derived from Loan Default Dataset.
  /// Sigmoid equation: P(Y=1|X) = 1 / (1 + e^-z)
  /// Decision Rule: P(Y=1) >= 0.50 => Class 1 (Default: YES), P(Y=1) < 0.50 => Class 0 (Default: NO)
  PredictionResult evaluateRisk() {
    double z = 0.0;

    // Logistic regression bias intercept calibrated to dataset baseline
    z -= 2.0;

    // 1. Credit Score Impact (300 - 900)
    double normCredit = (creditScore - 650) / 100.0;
    z -= normCredit * 0.85;

    // 2. Debt-to-Income (DTI) Ratio Impact
    z += (dtiRatio - 0.35) * 3.5;

    // 3. Interest Rate (%)
    z += (interestRate - 10.0) * 0.18;

    // 4. Loan-to-Income Ratio
    double ltiRatio = income > 0 ? (loanAmount / income) : 2.0;
    z += (ltiRatio - 0.4) * 1.6;

    // 5. Employment History & Status
    double yearsEmployed = monthsEmployed / 12.0;
    z -= min(yearsEmployed, 10.0) * 0.09;

    if (employmentType == 'Unemployed') {
      z += 1.8;
    } else if (employmentType == 'Part-time') {
      z += 0.7;
    } else if (employmentType == 'Self-employed') {
      z += 0.3;
    } else if (employmentType == 'Full-time') {
      z -= 0.35;
    }

    // 6. Education Level
    if (education == 'PhD') {
      z -= 0.45;
    } else if (education == "Master's") {
      z -= 0.35;
    } else if (education == "Bachelor's") {
      z -= 0.18;
    } else if (education == 'High School') {
      z += 0.25;
    }

    // 7. Collateral & Risk Mitigants
    if (hasCoSigner) z -= 0.70;
    if (hasMortgage) z -= 0.40;
    if (hasDependents) z += 0.20;

    // Calculate Logistic Sigmoid Probability P(Default = 1)
    double probability = 1.0 / (1.0 + exp(-z));
    double percentage = (probability * 100).clamp(0.1, 99.9);

    // Logistic Regression Classification Decision Boundary (Threshold = 50.0%)
    int defaultClass = percentage >= 50.0 ? 1 : 0;
    String defaultPredictionText = defaultClass == 1 ? "YES" : "NO";
    bool isApproved = defaultClass == 0;

    String riskTier = isApproved ? "Low Default Risk (Class 0)" : "High Default Risk (Class 1)";

    List<String> positives = [];
    List<String> risks = [];
    List<String> recommendations = [];

    if (creditScore >= 700) {
      positives.add("High Credit Score ($creditScore/900)");
    } else {
      risks.add("Low Credit Score ($creditScore/900)");
      recommendations.add("Increase credit score above 700 to reduce default risk.");
    }

    if (dtiRatio <= 0.35) {
      positives.add("Healthy Debt-to-Income Ratio (${(dtiRatio * 100).toStringAsFixed(0)}%)");
    } else {
      risks.add("High DTI Ratio (${(dtiRatio * 100).toStringAsFixed(0)}%)");
      recommendations.add("Reduce total debt obligations to bring DTI ratio under 35%.");
    }

    if (hasCoSigner) {
      positives.add("Co-Signer Guarantor Attached");
    } else {
      recommendations.add("Add a qualified Co-Signer to lower default classification.");
    }

    if (employmentType == 'Full-time' && monthsEmployed >= 24) {
      positives.add("Stable Employment History ($monthsEmployed months)");
    } else if (monthsEmployed < 12) {
      risks.add("Short Employment Duration ($monthsEmployed months)");
      recommendations.add("Build at least 12+ months of continuous employment.");
    }

    if (isApproved) {
      return PredictionResult(
        isApproved: true,
        defaultClass: 0,
        defaultPredictionText: "NO",
        defaultProbability: percentage,
        title: "Default Predicted: NO (Class 0)",
        subtitle: "Logistic Regression model predicts applicant will NOT default on loan repayment.",
        riskTier: riskTier,
        positiveFactors: positives.isNotEmpty ? positives : ["Balanced financial profile"],
        riskFactors: risks,
        recommendedActions: [
          "Loan Approved for disbursement under standard terms.",
          "Set up automatic recurring payments for timely repayment.",
        ],
      );
    } else {
      return PredictionResult(
        isApproved: false,
        defaultClass: 1,
        defaultPredictionText: "YES",
        defaultProbability: percentage,
        title: "Default Predicted: YES (Class 1)",
        subtitle: "Logistic Regression model predicts high likelihood of loan default.",
        riskTier: riskTier,
        positiveFactors: positives,
        riskFactors: risks.isNotEmpty ? risks : ["Multiple high-risk indicators detected"],
        recommendedActions: recommendations.isNotEmpty
            ? recommendations
            : [
                "Re-apply with a lower requested principal loan amount.",
                "Provide collateral assets or attach a qualified Co-Signer.",
              ],
      );
    }
  }
}
