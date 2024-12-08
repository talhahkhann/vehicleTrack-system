// controllers/chat_controller.dart
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:vehitrack/MainScreen/AI%20Integration/models/ChatModel.dart';

class ChatController {
  static const apiKey = "AIzaSyCc0kgL044WnPJ2F7kavQiGqONGoYIjg7w";
  final GenerativeModel model =
      GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

  final TextEditingController userInput = TextEditingController();
  final List<Message> messages = [];
  bool isTyping = false;

  /// List of keywords to identify security-related questions
  final List<String> securityKeywords = [
    'security',
    'safety',
    'protection',
    'data breach',
    'encryption',
    'cyber',
    'hack',
    'firewall',
    'privacy',
    'threat',
  ];

  Future<void> sendMessage(Function updateView) async {
    final messageText = userInput.text;
    if (messageText.isEmpty) return;

    // Add user message to the list
    messages
        .add(Message(isUser: true, message: messageText, date: DateTime.now()));

    // Clear the input field
    userInput.clear();

    // Update the view
    updateView();

    // Display "typing..." indicator
    isTyping = true;
    messages.add(
        Message(isUser: false, message: "Typing...", date: DateTime.now()));
    updateView();

    // Check if the message contains security-related keywords
    if (_isSecurityRelated(messageText)) {
      try {
        // Generate AI response
        final contextMessage =
            "The response will only be generated for security-related queries.";
        final response = await model.generateContent(
            [Content.text("$contextMessage User asked: $messageText")]);
        final aiMessage = response.text ?? "";

        // Replace "typing..." with the actual response
        messages[messages.length - 1] =
            Message(isUser: false, message: aiMessage, date: DateTime.now());
      } catch (e) {
        // Handle errors (e.g., no response from the server)
        messages[messages.length - 1] = Message(
          isUser: false,
          message: "Error: Unable to retrieve a response.",
          date: DateTime.now(),
        );
      }
    } else {
      // Replace "typing..." with a static response for unrelated queries
      messages[messages.length - 1] = Message(
        isUser: false,
        message: "Sorry, I can only assist with security-related questions.",
        date: DateTime.now(),
      );
    }

    // Remove typing indicator
    isTyping = false;

    // Update the view after receiving the response
    updateView();
  }

  /// Check if the user's message is related to security
  bool _isSecurityRelated(String message) {
    final lowerCaseMessage = message.toLowerCase();
    return securityKeywords
        .any((keyword) => lowerCaseMessage.contains(keyword));
  }
}
