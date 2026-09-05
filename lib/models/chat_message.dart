import 'api_models.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String> extractedChips;
  final RecommendationResult? recommendation;
  final BookingResult? bookingResult;
  final bool isThinking;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.extractedChips = const [],
    this.recommendation,
    this.bookingResult,
    this.isThinking = false,
  }) : timestamp = timestamp ?? DateTime.now();
}
