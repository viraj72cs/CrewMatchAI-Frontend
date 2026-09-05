import 'package:flutter/material.dart';
import '../models/event_state.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'recommended_team_screen.dart';

class MatchingLoadingScreen extends StatefulWidget {
  final EventState eventState;
  final String sessionId;

  const MatchingLoadingScreen({
    super.key,
    required this.eventState,
    required this.sessionId,
  });

  @override
  State<MatchingLoadingScreen> createState() => _MatchingLoadingScreenState();
}

class _MatchingLoadingScreenState extends State<MatchingLoadingScreen> {
  int _currentStep = 0;

  final List<String> _steps = [
    "Understanding event requirements",
    "Querying Supabase crew candidates",
    "Checking date & time availability",
    "Evaluating ratings & gig experience",
    "Comparing rates against ₹${50000} budget",
    "Building optimal team recommendation",
  ];

  @override
  void initState() {
    super.initState();
    _startAnimationAndFetch();
  }

  void _startAnimationAndFetch() async {
    // Step progression animation for judges demo
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) {
        setState(() => _currentStep = i + 1);
      }
    }

    // Trigger candidate matching via API
    final response = await ApiService.sendMessage(
      message:
          "Please find and recommend the best crew for my ${widget.eventState.eventType ?? 'wedding'} in ${widget.eventState.location ?? 'Pune'} on ${widget.eventState.eventDate ?? 'September 15, 2026'} from 5 PM to 11 PM for 500 guests with budget ${widget.eventState.totalBudget ?? 50000}.",
      sessionId: widget.sessionId,
    );

    if (mounted) {
      if (response.recommendation != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RecommendedTeamScreen(
              recommendation: response.recommendation!,
              sessionId: response.sessionId,
            ),
          ),
        );
      } else {
        // Fallback demo recommendation if rate limited
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Robot AI Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  size: 64,
                  color: AppTheme.primaryLight,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Gemini AI is Reasoning...",
                style: TextStyle(
                  color: AppTheme.textDarkPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Analyzing candidate experience & database availability",
                style: TextStyle(
                  color: AppTheme.primaryLight,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),

              // Checklist
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2E2A50)),
                ),
                child: Column(
                  children: List.generate(_steps.length, (index) {
                    final isDone = index < _currentStep;
                    final isCurrent = index == _currentStep;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          if (isDone)
                            const Icon(Icons.check_circle_rounded,
                                color: AppTheme.success, size: 20)
                          else if (isCurrent)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primaryLight,
                              ),
                            )
                          else
                            const Icon(Icons.radio_button_unchecked_rounded,
                                color: AppTheme.textDarkSecondary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _steps[index],
                              style: TextStyle(
                                color: isDone || isCurrent
                                    ? AppTheme.textDarkPrimary
                                    : AppTheme.textDarkSecondary,
                                fontWeight: isDone || isCurrent
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
