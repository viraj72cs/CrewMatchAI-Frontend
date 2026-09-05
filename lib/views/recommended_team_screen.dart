import 'package:flutter/material.dart';
import '../models/api_models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'booking_confirm_screen.dart';
import 'widgets/alternatives_sheet.dart';

class RecommendedTeamScreen extends StatelessWidget {
  final RecommendationResult recommendation;
  final String sessionId;

  const RecommendedTeamScreen({
    super.key,
    required this.recommendation,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("✨ Recommended Team"),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => AlternativesSheet(recommendation: recommendation),
              );
            },
            icon: const Icon(Icons.bolt_rounded, color: AppTheme.primaryLight),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtitle
            const Text(
              "Best match for your event",
              style: TextStyle(
                color: AppTheme.textDarkSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),

            // Budget Pill Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBudgetCol("Total Estimated", "₹${recommendation.totalCost.toStringAsFixed(0)}", AppTheme.primaryLight),
                  Container(height: 30, width: 1, color: Colors.white24),
                  _buildBudgetCol("Budget", "₹${recommendation.budget.toStringAsFixed(0)}", AppTheme.textDarkSecondary),
                  Container(height: 30, width: 1, color: Colors.white24),
                  _buildBudgetCol("Remaining", "₹${recommendation.budgetRemaining.toStringAsFixed(0)}", AppTheme.success),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Team Cards
            ...recommendation.recommendedTeam.map((member) => _buildMemberCard(context, member)),

            const SizedBox(height: 24),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingConfirmScreen(
                        recommendation: recommendation,
                        sessionId: sessionId,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.success,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text("✅ Book This Team"),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => AlternativesSheet(recommendation: recommendation),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryLight,
                  side: BorderSide(color: AppTheme.primary.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.compare_arrows_rounded),
                label: const Text("View Alternatives & Backups"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textDarkSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildMemberCard(BuildContext context, RecommendedCrewMember member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E2A50)),
      ),
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
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "₹${member.hourlyRate.toStringAsFixed(0)}/hr",
                  style: const TextStyle(
                    color: AppTheme.primaryLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            member.role,
            style: const TextStyle(
              color: AppTheme.textDarkSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF241F47),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: AppTheme.primaryLight),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Why: ${member.reason}",
                    style: const TextStyle(
                      color: AppTheme.textDarkSecondary,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
