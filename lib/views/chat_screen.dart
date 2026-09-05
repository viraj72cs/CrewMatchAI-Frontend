import 'package:flutter/material.dart';
import '../models/api_models.dart';
import '../models/chat_message.dart';
import '../models/event_state.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'event_summary_screen.dart';

import 'widgets/message_bubble.dart';
import 'widgets/team_card.dart';
import 'widgets/booking_success_card.dart';
import 'widgets/alternatives_sheet.dart';
import 'booking_confirm_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  
  String? _sessionId;
  bool _isLoading = false;
  EventState _eventState = EventState();
  RecommendationResult? _currentRecommendation;
  BookingResult? _currentBookingResult;

  @override
  void initState() {
    super.initState();
    _addInitialGreeting();
  }

  void _addInitialGreeting() {
    _messages.add(
      ChatMessage(
        text: "Hi! 👋 I'm your AI Event Planner.\nTell me about your event and I'll help you find and match the perfect crew.",
        isUser: false,
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    final userMessageText = text.trim();
    _controller.clear();

    setState(() {
      _messages.add(ChatMessage(text: userMessageText, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    // Show AI thinking step checklist
    _messages.add(ChatMessage(text: "", isUser: false, isThinking: true));

    // Call FastAPI backend
    final response = await ApiService.sendMessage(
      message: userMessageText,
      sessionId: _sessionId,
    );

    setState(() {
      _messages.removeWhere((m) => m.isThinking);
      _sessionId = response.sessionId;
      _isLoading = false;

      // Extract details if present
      _extractDataFromText(userMessageText);

      if (response.recommendation != null) {
        _currentRecommendation = response.recommendation;
      }

      if (response.bookingResult != null) {
        _currentBookingResult = response.bookingResult;
      }

      // Add AI response text
      _messages.add(
        ChatMessage(
          text: response.message,
          isUser: false,
          extractedChips: _getExtractedChips(),
          recommendation: response.recommendation,
          bookingResult: response.bookingResult,
        ),
      );
    });

    _scrollToBottom();
  }

  void _extractDataFromText(String text) {
    final lower = text.toLowerCase();

    // Event Type
    if (lower.contains("wedding") || lower.contains("marriage") || lower.contains("shaadi")) {
      _eventState.eventType = "Wedding";
    } else if (lower.contains("corporate") || lower.contains("conference") || lower.contains("summit")) {
      _eventState.eventType = "Corporate";
    } else if (lower.contains("birthday") || lower.contains("bday")) {
      _eventState.eventType = "Birthday";
    } else if (lower.contains("concert") || lower.contains("festival") || lower.contains("party")) {
      _eventState.eventType = "Party";
    }

    // Location
    if (lower.contains("pune")) {
      _eventState.location = "Pune";
    } else if (lower.contains("mumbai")) {
      _eventState.location = "Mumbai";
    } else if (lower.contains("bengaluru") || lower.contains("bangalore")) {
      _eventState.location = "Bengaluru";
    } else if (lower.contains("delhi")) {
      _eventState.location = "Delhi";
    } else {
      final locMatch = RegExp(r'\b(?:in|at)\s+([A-Z][a-z]+)\b').firstMatch(text);
      if (locMatch != null) {
        _eventState.location = locMatch.group(1);
      }
    }

    // Dynamic Guest Count
    final guestMatch = RegExp(r'(\d{1,5})\s*(?:guests?|people|attendees|pax|members)?', caseSensitive: false).firstMatch(text);
    if (guestMatch != null) {
      final val = int.tryParse(guestMatch.group(1)!);
      if (val != null && val >= 10 && val <= 10000) {
        _eventState.guestCount = val;
      }
    }

    // Dynamic Budget (e.g. 50000, 50k, 50,000, 1.5 lakh)
    final kMatch = RegExp(r'(\d+(?:\.\d+)?)\s*k\b', caseSensitive: false).firstMatch(text);
    final lakhMatch = RegExp(r'(\d+(?:\.\d+)?)\s*(?:lakh|lac)\b', caseSensitive: false).firstMatch(text);
    final budgetMatch = RegExp(r'(?:budget|₹|inr|rs\.?)\s*:?\s*(\d[\d,]*)', caseSensitive: false).firstMatch(text);

    if (kMatch != null) {
      _eventState.totalBudget = (double.tryParse(kMatch.group(1)!) ?? 50) * 1000;
    } else if (lakhMatch != null) {
      _eventState.totalBudget = (double.tryParse(lakhMatch.group(1)!) ?? 1) * 100000;
    } else if (budgetMatch != null) {
      final clean = budgetMatch.group(1)!.replaceAll(',', '');
      final val = double.tryParse(clean);
      if (val != null && val >= 1000) _eventState.totalBudget = val;
    } else {
      final numMatch = RegExp(r'\b(\d{4,7})\b').firstMatch(text);
      if (numMatch != null) {
        final val = double.tryParse(numMatch.group(1)!);
        if (val != null && val >= 5000) _eventState.totalBudget = val;
      }
    }

    // Date extraction
    final dateMatch = RegExp(r'\b(\d{1,2}(?:st|nd|rd|th)?\s+(?:jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|jun(?:e)?|jul(?:y)?|aug(?:ust)?|sep(?:tember)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)(?:\s+\d{4})?)\b', caseSensitive: false).firstMatch(text);
    if (dateMatch != null) {
      _eventState.eventDate = dateMatch.group(1);
    } else if (lower.contains("tomorrow")) {
      _eventState.eventDate = "Tomorrow";
    }
  }

  List<String> _getExtractedChips() {
    List<String> chips = [];
    if (_eventState.eventType != null) chips.add("💍 ${_eventState.eventType}");
    if (_eventState.eventDate != null) chips.add("📅 ${_eventState.eventDate}");
    if (_eventState.location != null) chips.add("📍 ${_eventState.location}");
    if (_eventState.guestCount != null) chips.add("👥 ${_eventState.guestCount} guests");
    if (_eventState.totalBudget != null) chips.add("💰 ₹${_eventState.totalBudget?.toStringAsFixed(0)}");
    return chips;
  }

  void _showModelSelectorDialog() {
    String tempSelectedModel = ApiService.selectedModel;
    final controller = TextEditingController(text: ApiService.baseUrl);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.darkCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.tune_rounded, color: AppTheme.primaryLight),
              SizedBox(width: 8),
              Text("Model & Connection", style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Active Gemini AI Model:",
                style: TextStyle(color: AppTheme.textDarkSecondary, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF13102B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: tempSelectedModel,
                    dropdownColor: AppTheme.darkCard,
                    isExpanded: true,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    items: const [
                      DropdownMenuItem(
                        value: "gemini-3.5-flash",
                        child: Text("⚡ Gemini 3.5 Flash (Default - Fast)"),
                      ),
                      DropdownMenuItem(
                        value: "gemini-3.6-flash",
                        child: Text("🌟 Gemini 3.6 Flash (Deep Reasoning)"),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => tempSelectedModel = val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Backend Server IP:",
                style: TextStyle(color: AppTheme.textDarkSecondary, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF13102B),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: AppTheme.textDarkSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  ApiService.setBaseUrl(controller.text.trim());
                }
                setState(() {
                  ApiService.selectedModel = tempSelectedModel;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Active Model: ${ApiService.selectedModel}")),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              child: const Text("Apply Changes"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("🤖 AI Event Planner", style: TextStyle(fontSize: 18)),
            Row(
              children: [
                const Icon(Icons.circle, color: AppTheme.success, size: 8),
                const SizedBox(width: 4),
                Text(
                  "Online • ${ApiService.selectedModel}",
                  style: const TextStyle(color: AppTheme.primaryLight, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showModelSelectorDialog,
            icon: const Icon(Icons.tune_rounded, color: AppTheme.primaryLight),
            tooltip: "Switch Model / Server IP",
          ),
          if (_eventState.isComplete)
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventSummaryScreen(
                      eventState: _eventState,
                      sessionId: _sessionId ?? '',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.verified_rounded, color: AppTheme.success, size: 18),
              label: const Text("Summary", style: TextStyle(color: AppTheme.success)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Completion Progress Bar
          if (_eventState.completionProgress > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppTheme.darkCard,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Event Extraction Progress",
                        style: const TextStyle(
                          color: AppTheme.textDarkSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "${(_eventState.completionProgress * 100).toInt()}%",
                        style: const TextStyle(
                          color: AppTheme.primaryLight,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _eventState.completionProgress,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),

          // Chat Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];

                return Column(
                  children: [
                    MessageBubble(message: msg),

                    // Render Team Card if Recommendation is attached
                    if (msg.recommendation != null)
                      TeamCard(
                        recommendation: msg.recommendation!,
                        onConfirmBooking: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingConfirmScreen(
                                recommendation: msg.recommendation!,
                                sessionId: _sessionId ?? '',
                              ),
                            ),
                          );
                        },
                        onViewAlternatives: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => AlternativesSheet(
                              recommendation: msg.recommendation!,
                            ),
                          );
                        },
                      ),

                    // Render Success Card if Booking Result is attached
                    if (msg.bookingResult != null)
                      BookingSuccessCard(bookingResult: msg.bookingResult!),
                  ],
                );
              },
            ),
          ),

          // Quick Selection Pills
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildQuickPill("❤️ Wedding", "I am planning a wedding"),
                _buildQuickPill("💼 Corporate", "I am planning a corporate event"),
                _buildQuickPill("📷 Need Photographer", "I need 1 photographer for 15 Sep in Pune"),
                _buildQuickPill("🎨 Need Decorator", "I need 1 decorator for 15 Sep in Pune"),
                _buildQuickPill("🛡️ Need Security", "I need 2 security staff"),
              ],
            ),
          ),

          // Input Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppTheme.darkCard,
              border: Border(top: BorderSide(color: Color(0xFF2E2A50))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: "Describe your event or ask for crew...",
                      hintStyle: const TextStyle(color: AppTheme.textDarkSecondary),
                      filled: true,
                      fillColor: const Color(0xFF13102B),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    onPressed: () => _sendMessage(_controller.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPill(String label, String textToSend) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ActionChip(
        label: Text(
          label,
          style: const TextStyle(
            color: AppTheme.primaryLight,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.darkCard,
        side: BorderSide(color: AppTheme.primary.withOpacity(0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () => _sendMessage(textToSend),
      ),
    );
  }
}
