import 'package:flutter/material.dart';
import '../models/api_models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'booking_success_screen.dart';

class BookingConfirmScreen extends StatefulWidget {
  final RecommendationResult recommendation;
  final String sessionId;

  const BookingConfirmScreen({
    super.key,
    required this.recommendation,
    required this.sessionId,
  });

  @override
  State<BookingConfirmScreen> createState() => _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen> {
  bool _isBooking = false;

  void _confirmAndBook() async {
    setState(() => _isBooking = true);

    // Call API to book team
    final response = await ApiService.sendMessage(
      message: "Yes, book them.",
      sessionId: widget.sessionId,
    );

    if (mounted) {
      setState(() => _isBooking = false);

      if (response.bookingResult != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => BookingSuccessScreen(
              bookingResult: response.bookingResult!,
              totalCost: widget.recommendation.totalCost,
            ),
          ),
          (route) => route.isFirst,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm Booking"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Badge Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2E2A50)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppTheme.primary,
                    child: Icon(Icons.event_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Wedding Event",
                        style: TextStyle(
                          color: AppTheme.textDarkPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "15 September 2026 • Pune • 5 PM – 11 PM",
                        style: TextStyle(
                          color: AppTheme.textDarkSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "Team Summary",
              style: TextStyle(
                color: AppTheme.textDarkPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ...widget.recommendation.recommendedTeam.map((m) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2E2A50)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${m.role}: ${m.name}",
                          style: const TextStyle(
                              color: AppTheme.textDarkPrimary,
                              fontWeight: FontWeight.bold)),
                      Text("₹${m.estimatedCost.toStringAsFixed(0)}",
                          style: const TextStyle(
                              color: AppTheme.primaryLight,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),

            const Divider(height: 32, color: Colors.white24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Agreed Rate:",
                    style: TextStyle(
                        color: AppTheme.textDarkSecondary, fontSize: 16)),
                Text("₹${widget.recommendation.totalCost.toStringAsFixed(0)}",
                    style: const TextStyle(
                        color: AppTheme.success,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 32),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isBooking ? null : _confirmAndBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.success,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isBooking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text("✅ Confirm & Write to Supabase"),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textDarkSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("← Change Team"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
