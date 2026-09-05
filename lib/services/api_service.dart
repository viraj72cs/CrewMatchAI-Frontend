import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/api_models.dart';

class ApiService {
  // Defaults to live Render production backend.
  static String baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://crewmatchai.onrender.com',
  );

  /// Helper to dynamically update API base URL at runtime if needed.
  static void setBaseUrl(String url) {
    baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  // Currently active model (defaults to gemini-3.6-flash)
  static String selectedModel = "gemini-3.6-flash";

  static Future<ChatResponse> sendMessage({
    required String message,
    String? sessionId,
    String? modelName,
  }) async {
    final url = Uri.parse("$baseUrl/chat");

    final body = jsonEncode({
      "message": message,
      if (sessionId != null && sessionId.isNotEmpty) "session_id": sessionId,
      "model_name": modelName ?? selectedModel,
    });

    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: body,
          )
          .timeout(const Duration(minutes: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ChatResponse.fromJson(data);
      } else {
        return ChatResponse(
          success: false,
          sessionId: sessionId ?? '',
          state: 'error',
          message: "The server is currently busy (Status ${response.statusCode}). Please try again in a moment.",
        );
      }
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      String userMessage = "Unable to connect to CrewMatch AI backend. Please ensure the backend server is active.";

      if (errStr.contains("timeout")) {
        userMessage = "The request timed out while generating your crew recommendations. Please try again!";
      } else if (errStr.contains("connection refused") || errStr.contains("socketexception")) {
        userMessage = "Could not connect to the backend server. Please verify your connection or port forwarding.";
      }

      return ChatResponse(
        success: false,
        sessionId: sessionId ?? '',
        state: 'error',
        message: userMessage,
      );
    }
  }

  static Future<BookingResult?> bookTeam(String sessionId) async {
    final url = Uri.parse("$baseUrl/book-team/$sessionId");

    try {
      final response = await http.post(url).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return BookingResult.fromJson(data);
      }
    } catch (e) {
      print("Booking error: $e");
    }
    return null;
  }

  static Future<Map<String, dynamic>?> cancelBooking(String bookingId) async {
    final url = Uri.parse("$baseUrl/cancel");

    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"booking_id": bookingId}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Cancel error: $e");
    }
    return null;
  }
}
