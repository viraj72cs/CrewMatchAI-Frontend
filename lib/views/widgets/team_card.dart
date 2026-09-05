import 'package:flutter/material.dart';
import '../../models/api_models.dart';
import '../../theme/app_theme.dart';

class TeamCard extends StatelessWidget {
  final RecommendationResult recommendation;
  final VoidCallback onConfirmBooking;
  final VoidCallback onViewAlternatives;

  const TeamCard({
    super.key,
    required this.recommendation,
    required this.onConfirmBooking,
    required this.onViewAlternatives,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.15),
            blurRadius: 16,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.stars_rounded,
                    color: AppTheme.primaryLight, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "✨ Recommended Team",
                      style: TextStyle(
                        color: AppTheme.textDarkPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Intelligently matched by Gemini LLM",
                      style: TextStyle(
                        color: AppTheme.primaryLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Budget Breakdown Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF13102B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBudgetItem(
                  "Total Cost",
                  "₹${recommendation.totalCost.toStringAsFixed(0)}",
                  AppTheme.primaryLight,
                ),
                Container(height: 24, width: 1, color: Colors.white24),
                _buildBudgetItem(
                  "Budget",
                  "₹${recommendation.budget.toStringAsFixed(0)}",
                  AppTheme.textDarkSecondary,
                ),
                Container(height: 24, width: 1, color: Colors.white24),
                _buildBudgetItem(
                  "Savings",
                  "₹${recommendation.budgetRemaining.toStringAsFixed(0)}",
                  AppTheme.success,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Team Member List
          const Text(
            "Selected Team Members:",
            style: TextStyle(
              color: AppTheme.textDarkSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          ...recommendation.recommendedTeam.map((member) => _buildCrewRow(member)),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onViewAlternatives,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryLight,
                    side: BorderSide(color: AppTheme.primary.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("⚡ Alternatives"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: onConfirmBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("✅ Confirm & Book"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: AppTheme.textDarkSecondary, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildCrewRow(RecommendedCrewMember member) {
    IconData iconData = _getRoleIcon(member.role);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF241F47),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primary.withOpacity(0.3),
            child: Icon(iconData, size: 16, color: AppTheme.primaryLight),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      member.name,
                      style: const TextStyle(
                        color: AppTheme.textDarkPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "₹${member.hourlyRate.toStringAsFixed(0)}/hr",
                      style: const TextStyle(
                        color: AppTheme.primaryLight,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Text(
                  member.role,
                  style: const TextStyle(
                    color: AppTheme.textDarkSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  member.reason,
                  style: TextStyle(
                    color: AppTheme.textDarkSecondary.withOpacity(0.8),
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'photographer':
        return Icons.camera_alt_rounded;
      case 'videographer':
        return Icons.videocam_rounded;
      case 'decorator':
        return Icons.palette_rounded;
      case 'anchor':
        return Icons.mic_rounded;
      case 'security':
        return Icons.security_rounded;
      case 'sound engineer':
        return Icons.speaker_group_rounded;
      default:
        return Icons.person_rounded;
    }
  }
}
