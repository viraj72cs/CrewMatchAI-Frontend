import 'package:flutter/material.dart';
import '../models/event_state.dart';
import '../theme/app_theme.dart';
import 'matching_loading_screen.dart';

class EventSummaryScreen extends StatelessWidget {
  final EventState eventState;
  final String sessionId;

  const EventSummaryScreen({
    super.key,
    required this.eventState,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Summary"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lavender Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2B2554),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryLight.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _getEventEmoji(eventState.eventType),
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        eventState.eventType ?? "Event",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Here is what I understood from your conversation.",
                    style: TextStyle(
                      color: AppTheme.primaryLight,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Event Details",
              style: TextStyle(
                color: AppTheme.textDarkPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Event Details Grid
            _buildDetailCard(
              icon: Icons.calendar_today_rounded,
              label: "Date",
              value: eventState.eventDate ?? "15 September 2026",
            ),
            const SizedBox(height: 10),
            _buildDetailCard(
              icon: Icons.access_time_rounded,
              label: "Time",
              value: "${eventState.startTime ?? '5:00 PM'} – ${eventState.endTime ?? '11:00 PM'}",
            ),
            const SizedBox(height: 10),
            _buildDetailCard(
              icon: Icons.location_on_rounded,
              label: "Location",
              value: eventState.location ?? "Pune",
            ),
            const SizedBox(height: 10),
            _buildDetailCard(
              icon: Icons.people_alt_rounded,
              label: "Guests",
              value: "${eventState.guestCount ?? 500} people",
            ),
            const SizedBox(height: 10),
            _buildDetailCard(
              icon: Icons.account_balance_wallet_rounded,
              label: "Total Budget",
              value: "₹${eventState.totalBudget?.toStringAsFixed(0) ?? '50,000'}",
            ),

            const SizedBox(height: 24),
            const Text(
              "Required Crew",
              style: TextStyle(
                color: AppTheme.textDarkPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildCrewRoleCard("📷 Photographer", 1),
            _buildCrewRoleCard("🎨 Decorator", 1),
            _buildCrewRoleCard("🎤 Anchor", 1),
            _buildCrewRoleCard("🛡️ Security Personnel", 2),

            const SizedBox(height: 30),

            // Confirmation Actions
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MatchingLoadingScreen(
                        eventState: eventState,
                        sessionId: sessionId,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text("✨ Looks Good — Find My Crew"),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textDarkSecondary,
                  side: const BorderSide(color: Color(0xFF2E2A50)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Edit Details"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E2A50)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryLight, size: 22),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textDarkSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textDarkPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCrewRoleCard(String title, int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E2A50)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textDarkPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "×$count",
              style: const TextStyle(
                color: AppTheme.primaryLight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getEventEmoji(String? type) {
    switch (type?.toLowerCase()) {
      case 'wedding':
        return '❤️';
      case 'corporate':
        return '💼';
      case 'concert':
        return '🎵';
      case 'festival':
        return '🎉';
      default:
        return '✨';
    }
  }
}
