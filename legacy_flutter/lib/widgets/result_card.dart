import 'package:flutter/material.dart';

import '../models/prediction_result.dart';
import '../theme/app_theme.dart';

class PredictionResultCard extends StatelessWidget {
  final PredictionResult result;
  final VoidCallback onReset;

  const PredictionResultCard({
    Key? key,
    required this.result,
    required this.onReset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isApproved = result.isApproved;
    final String binaryOutput = result.defaultPredictionText; // "NO" or "YES"
    final int binaryClass = result.defaultClass; // 0 or 1

    final Color bgColor = isApproved ? AppColors.sageBg : AppColors.terracottaBg;
    final Color borderColor = isApproved ? AppColors.sageBorder : AppColors.terracottaBorder;
    final Color textColor = isApproved ? AppColors.sageText : AppColors.terracottaText;
    final Color iconColor = isApproved ? AppColors.sageIcon : AppColors.terracottaIcon;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Binary Output Banner Badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(
                  isApproved ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  size: 26,
                  color: iconColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "LOGISTIC REGRESSION CLASSIFICATION OUTPUT",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            "Will Default? ",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: iconColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "$binaryOutput (Class $binaryClass)",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Primary Result Title & Subtitle
          Text(
            isApproved ? "Loan Approved: Trustworthy Profile" : "Loan Declined: High Default Risk",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            result.subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),
          const Divider(color: Color(0xFFCBD5E1), height: 1),
          const SizedBox(height: 20),

          // Logistic Regression Probability Gauge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Sigmoid Default Probability P(Y=1)",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              Text(
                "${result.defaultProbability.toStringAsFixed(1)}%",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (result.defaultProbability / 100).clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(iconColor),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "0% (Class 0: No Default)",
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              Text(
                "Threshold: 50.0%",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
              ),
              Text(
                "100% (Class 1: Default)",
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Factor Analysis
          if (result.positiveFactors.isNotEmpty) ...[
            const Text(
              "Positive Low-Risk Indicators (Supports Class 0)",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF15803D),
              ),
            ),
            const SizedBox(height: 8),
            ...result.positiveFactors.map(
              (factor) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check, size: 16, color: Color(0xFF15803D)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        factor,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          if (result.riskFactors.isNotEmpty) ...[
            const Text(
              "High-Risk Predictors (Supports Class 1)",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFFC05621),
              ),
            ),
            const SizedBox(height: 8),
            ...result.riskFactors.map(
              (factor) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.priority_high_rounded, size: 16, color: Color(0xFFC05621)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        factor,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Actionable Recommendations
          const Text(
            "Model Feedback & Recommendations",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          ...result.recommendedActions.map(
            (action) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("• ", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  Expanded(
                    child: Text(
                      action,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text("Evaluate Another Applicant Profile"),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryNavy,
                side: const BorderSide(color: AppColors.primaryNavy, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
