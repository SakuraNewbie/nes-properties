import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_message.dart';
import '../models/property.dart';
import '../../core/network/api_service.dart';
import '../../core/constants/app_constants.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;
  String? _error;
  ChatSession? _currentSession;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;
  String? get error => _error;
  ChatSession? get currentSession => _currentSession;

  final ApiService _apiService = ApiService.instance;

  ChatProvider() {
    _initializeChat();
  }

  // Initialize chat with welcome message
  void _initializeChat() {
    if (_messages.isEmpty) {
      final welcomeMessage = ChatResponses.createWelcomeMessage();
      _messages.add(welcomeMessage);
      notifyListeners();
    }
  }

  // Send a message
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      content: content.trim(),
      sender: 'user',
      type: MessageType.text,
      timestamp: DateTime.now(),
    );

    _addMessage(userMessage);

    // Show typing indicator
    _setTyping(true);
    final loadingMessage = ChatResponses.createLoadingMessage();
    _addMessage(loadingMessage);

    try {
      // Send message to API
      final response = await _apiService.sendChatMessage(content);

      // Remove loading message
      _removeMessage(loadingMessage.id);

      // Create bot response message
      ChatMessage botMessage;

      if (response.properties != null && response.properties!.isNotEmpty) {
        // Property list response
        botMessage = ChatResponses.createPropertyListMessage(response.properties!);
      } else {
        // Regular text response
        botMessage = ChatMessage(
          id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
          content: response.response,
          sender: 'bot',
          type: MessageType.text,
          timestamp: DateTime.now(),
          suggestions: response.suggestions ?? _getContextualSuggestions(content),
        );
      }

      _addMessage(botMessage);

    } catch (e) {
      // Remove loading message
      _removeMessage(loadingMessage.id);

      // Add error message
      final errorMessage = ChatResponses.createErrorMessage(e.toString());
      _addMessage(errorMessage);
      _setError(e.toString());
    } finally {
      _setTyping(false);
    }
  }

  // Send quick reply
  Future<void> sendQuickReply(String reply) async {
    await sendMessage(reply);
  }

  // Handle property selection from chat
  void selectPropertyFromChat(Property property) {
    final message = ChatMessage(
      id: 'property_${DateTime.now().millisecondsSinceEpoch}',
      content: 'Here are the details for ${property.title}:',
      sender: 'bot',
      type: MessageType.propertyCard,
      timestamp: DateTime.now(),
      properties: [property],
      suggestions: [
        'View virtual tour',
        'Contact owner',
        'Save to favorites',
        'Find similar properties',
        'Schedule viewing'
      ],
    );

    _addMessage(message);
  }

  // Add message to chat
  void _addMessage(ChatMessage message) {
    _messages.add(message);
    _saveMessagesToStorage();
    notifyListeners();
  }

  // Remove message from chat
  void _removeMessage(String messageId) {
    _messages.removeWhere((message) => message.id == messageId);
    _saveMessagesToStorage();
    notifyListeners();
  }

  // Update message
  void _updateMessage(String messageId, ChatMessage updatedMessage) {
    final index = _messages.indexWhere((message) => message.id == messageId);
    if (index != -1) {
      _messages[index] = updatedMessage;
      _saveMessagesToStorage();
      notifyListeners();
    }
  }

  // Clear chat history
  void clearChat() {
    _messages.clear();
    _initializeChat();
    _clearMessagesFromStorage();
  }

  // Start new conversation
  void startNewConversation() {
    clearChat();
  }

  // Get contextual suggestions based on user input
  List<String> _getContextualSuggestions(String userInput) {
    final input = userInput.toLowerCase();
    
    if (input.contains('price') || input.contains('budget') || input.contains('cheap')) {
      return [
        'Show budget properties',
        'Filter by price range',
        'Properties under RM 1000',
        'Most expensive properties'
      ];
    } else if (input.contains('student') || input.contains('university') || input.contains('usas')) {
      return [
        'Student accommodations',
        'Properties near USAS',
        'Shared housing options',
        'Furnished properties'
      ];
    } else if (input.contains('woman') || input.contains('female') || input.contains('girl')) {
      return [
        'Female only properties',
        'Safe neighborhoods',
        'Women-friendly amenities',
        'Security features'
      ];
    } else if (input.contains('tour') || input.contains('view') || input.contains('see')) {
      return [
        'Virtual tours available',
        'Schedule property viewing',
        '360° property views',
        'Photo galleries'
      ];
    } else {
      return AppConstants.quickReplies;
    }
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set typing state
  void _setTyping(bool typing) {
    _isTyping = typing;
    notifyListeners();
  }

  // Set error state
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Save messages to local storage
  Future<void> _saveMessagesToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = _messages.map((message) => message.toJson()).toList();
      await prefs.setString('chat_messages', messagesJson.toString());
    } catch (e) {
      debugPrint('Failed to save messages to storage: $e');
    }
  }

  // Load messages from local storage
  Future<void> _loadMessagesFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesString = prefs.getString('chat_messages');
      
      if (messagesString != null) {
        // Parse and restore messages
        // This is simplified - in production, you'd want proper JSON parsing
        // For now, we'll start fresh each time
      }
    } catch (e) {
      debugPrint('Failed to load messages from storage: $e');
    }
  }

  // Clear messages from local storage
  Future<void> _clearMessagesFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('chat_messages');
    } catch (e) {
      debugPrint('Failed to clear messages from storage: $e');
    }
  }

  // Get message history for analysis
  List<ChatMessage> getMessageHistory({int? limit}) {
    if (limit != null && limit < _messages.length) {
      return _messages.skip(_messages.length - limit).toList();
    }
    return List.from(_messages);
  }

  // Get user messages only
  List<ChatMessage> getUserMessages() {
    return _messages.where((message) => message.isFromUser).toList();
  }

  // Get bot messages only
  List<ChatMessage> getBotMessages() {
    return _messages.where((message) => message.isFromBot).toList();
  }

  // Search messages
  List<ChatMessage> searchMessages(String query) {
    final searchQuery = query.toLowerCase();
    return _messages.where((message) =>
      message.content.toLowerCase().contains(searchQuery)
    ).toList();
  }

  // Get conversation statistics
  Map<String, dynamic> getConversationStats() {
    final userMessageCount = getUserMessages().length;
    final botMessageCount = getBotMessages().length;
    final totalMessages = _messages.length;
    
    return {
      'totalMessages': totalMessages,
      'userMessages': userMessageCount,
      'botMessages': botMessageCount,
      'conversationStarted': _messages.isNotEmpty ? _messages.first.timestamp : null,
      'lastActivity': _messages.isNotEmpty ? _messages.last.timestamp : null,
    };
  }

  // Export conversation
  String exportConversation() {
    final buffer = StringBuffer();
    buffer.writeln('NES Properties Chat Conversation');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('=====================================\n');

    for (final message in _messages) {
      final timestamp = message.timestamp.toString().substring(0, 19);
      final sender = message.isFromUser ? 'You' : 'NES Assistant';
      buffer.writeln('[$timestamp] $sender:');
      buffer.writeln(message.content);
      buffer.writeln();
    }

    return buffer.toString();
  }

  // Check if chat is empty (only welcome message)
  bool get isEmpty {
    return _messages.length <= 1;
  }

  // Check if last message was from user
  bool get waitingForResponse {
    if (_messages.isEmpty) return false;
    return _messages.last.isFromUser;
  }

  // Get last user message
  ChatMessage? get lastUserMessage {
    final userMessages = getUserMessages();
    return userMessages.isNotEmpty ? userMessages.last : null;
  }

  // Get suggested follow-up questions
  List<String> getSuggestedQuestions() {
    if (isEmpty) {
      return AppConstants.quickReplies;
    }

    final lastBotMessage = getBotMessages().lastOrNull;
    if (lastBotMessage?.suggestions != null) {
      return lastBotMessage!.suggestions!;
    }

    return AppConstants.quickReplies.take(4).toList();
  }
}

// Extension for list operations
extension ChatMessageListExtension on List<ChatMessage> {
  ChatMessage? get lastOrNull {
    return isNotEmpty ? last : null;
  }
}