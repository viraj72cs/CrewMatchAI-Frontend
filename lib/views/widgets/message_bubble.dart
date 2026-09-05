import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import '../../theme/app_theme.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isThinking) {
      return _buildThinkingBubble(context);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      child: Column(
        crossAxisAlignment:
            message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!message.isUser) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primary,
                  child: const Icon(Icons.smart_toy_rounded,
                      size: 18, color: Colors.white),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? AppTheme.primary
                        : (message.text.toLowerCase().contains("unable to connect") ||
                                message.text.toLowerCase().contains("timed out") ||
                                message.text.toLowerCase().contains("could not connect") ||
                                message.text.toLowerCase().contains("busy"))
                            ? Colors.red.withOpacity(0.12)
                            : AppTheme.darkCard,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                      bottomRight: Radius.circular(message.isUser ? 4 : 16),
                    ),
                    border: message.isUser
                        ? null
                        : Border.all(
                            color: (message.text.toLowerCase().contains("unable to connect") ||
                                    message.text.toLowerCase().contains("timed out") ||
                                    message.text.toLowerCase().contains("could not connect") ||
                                    message.text.toLowerCase().contains("busy"))
                                ? Colors.redAccent.withOpacity(0.5)
                                : const Color(0xFF2E2A50)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!message.isUser &&
                          (message.text.toLowerCase().contains("unable to connect") ||
                              message.text.toLowerCase().contains("timed out") ||
                              message.text.toLowerCase().contains("could not connect") ||
                              message.text.toLowerCase().contains("busy"))) ...[
                        const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: message.isUser
                                ? Colors.white
                                : (message.text.toLowerCase().contains("unable to connect") ||
                                        message.text.toLowerCase().contains("timed out") ||
                                        message.text.toLowerCase().contains("could not connect") ||
                                        message.text.toLowerCase().contains("busy"))
                                    ? const Color(0xFFFF8A8A)
                                    : AppTheme.textDarkPrimary,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (message.isUser) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primaryLight,
                  child: const Icon(Icons.person_rounded,
                      size: 18, color: Colors.white),
                ),
              ],
            ],
          ),

          // Render Extracted Data Chips (if available)
          if (message.extractedChips.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 40.0),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: message.extractedChips
                    .map(
                      (chip) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primarySurface.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.primaryLight.withOpacity(0.4)),
                        ),
                        child: Text(
                          chip,
                          style: const TextStyle(
                            color: AppTheme.primaryLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThinkingBubble(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primary,
            child: const Icon(Icons.smart_toy_rounded,
                size: 18, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primaryLight,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Finding your best crew...",
                      style: TextStyle(
                        color: AppTheme.primaryLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildCheckItem("Understanding event requirements"),
                _buildCheckItem("Checking crew availability in Supabase"),
                _buildCheckItem("Reviewing ratings & completed gigs"),
                _buildCheckItem("Comparing hourly rates vs budget"),
                _buildCheckItem("Building best matching team"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              size: 14, color: AppTheme.success),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textDarkSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
