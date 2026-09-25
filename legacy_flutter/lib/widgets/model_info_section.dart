import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ModelInfoSection extends StatefulWidget {
  const ModelInfoSection({Key? key}) : super(key: key);

  @override
  State<ModelInfoSection> createState() => _ModelInfoSectionState();
}

class _ModelInfoSectionState extends State<ModelInfoSection> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderResting, width: 1),
        boxShadow: AppColors.cardShadow,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          onExpansionChanged: (expanded) {
            setState(() {
              isExpanded = expanded;
            });
          },
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.analytics_rounded,
              color: AppColors.primaryNavy,
              size: 22,
            ),
          ),
          title: const Text(
            "Machine Learning Model Architecture & Metrics",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          subtitle: const Text(
            "Overview of default prediction objectives, training dataset & performance",
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
          trailing: AnimatedRotation(
            turns: isExpanded ? 0.5 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.primaryNavy,
              size: 26,
            ),
          ),
          children: [
            const Divider(color: Color(0xFFE2E8F0), height: 1),
            const SizedBox(height: 16),

            // Objective Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "🎯 Core Objective",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "The primary objective of this AI model is to predict high-risk loan applicants before disbursement. By detecting subtle non-linear correlations across financial profiles, the model mitigates Non-Performing Assets (NPAs) and minimizes financial institution default losses.",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF334155),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Key Metrics Grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricBadge("255,347", "Dataset Records", Icons.storage_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricBadge("0.754", "ROC-AUC Score", Icons.legend_toggle_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricBadge("16", "Mapped Features", Icons.tune_rounded),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text(
              "Top Predictor Weights (Feature Importance)",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFeatureChip("Interest Rate (24.8%)", true),
                _buildFeatureChip("DTI Ratio (19.2%)", true),
                _buildFeatureChip("Credit Score (18.5%)", true),
                _buildFeatureChip("Income (12.1%)", false),
                _buildFeatureChip("Months Employed (9.4%)", false),
                _buildFeatureChip("Has Co-Signer (8.2%)", false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBadge(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryNavy),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label, bool isHighImportance) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isHighImportance ? AppColors.primaryNavy : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isHighImportance ? Colors.white : const Color(0xFF334155),
        ),
      ),
    );
  }
}
