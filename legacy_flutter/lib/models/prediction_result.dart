class PredictionResult {
  final bool isApproved; // true = Low Default Risk (Approved), false = High Default Risk (Declined)
  final int defaultClass; // 0 = No Default, 1 = Default Likely
  final String defaultPredictionText; // "NO" or "YES"
  final double defaultProbability; // Sigmoid output probability P(Y=1) in %
  final String title;
  final String subtitle;
  final String riskTier; // Low Risk, High Default Risk
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
