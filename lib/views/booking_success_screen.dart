import 'package:flutter/material.dart';
import '../models/api_models.dart';
import '../theme/app_theme.dart';

class BookingSuccessScreen extends StatelessWidget {
  final BookingResult bookingResult;
  final double totalCost;

  const BookingSuccessScreen({
    super.key,
    required this.bookingResult,
    required this.totalCost,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppTheme.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    size: 64, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text(
                "🎉 Your Crew is Booked!",
                style: TextStyle(
                  color: AppTheme.textDarkPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${bookingResult.totalBooked} crew members confirmed in Supabase",
                style: const TextStyle(
                  color: AppTheme.success,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),

              // Confirmed List Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.success.withOpacity(0.4)),
                ),
                child: Column(
                  children: [
                    ...bookingResult.bookings.map((b) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            children: [
                              const Icon(Icons.verified_rounded,
                                  color: AppTheme.success, size: 18),
                              const SizedBox(width: 10),
                              Text(
                                "${b.role}: ${b.name}",
                                style: const TextStyle(
                                  color: AppTheme.textDarkPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        )),
                    const Divider(height: 24, color: Colors.white24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Estimated Total:",
                            style: TextStyle(
                                color: AppTheme.textDarkSecondary,
                                fontSize: 14)),
                        Text("₹${totalCost.toStringAsFixed(0)}",
                            style: const TextStyle(
                                color: AppTheme.primaryLight,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Back to Home"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
