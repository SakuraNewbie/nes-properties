class ChatMessage {
  final String id;
  final String content;
  final String sender; // 'user' or 'bot'
  final MessageType type;
  final DateTime timestamp;
  final List<String>? suggestions;
  final List<Property>? properties;
  final bool isTyping;

  ChatMessage({
    required this.id,
    required this.content,
    required this.sender,
    required this.type,
    required this.timestamp,
    this.suggestions,
    this.properties,
    this.isTyping = false,
  });

  bool get isFromUser => sender == 'user';
  bool get isFromBot => sender == 'bot';

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      sender: json['sender'] ?? 'bot',
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => MessageType.text,
      ),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      suggestions: json['suggestions'] != null 
          ? List<String>.from(json['suggestions'])
          : null,
      properties: json['properties'] != null 
          ? (json['properties'] as List)
              .map((p) => Property.fromJson(p))
              .toList()
          : null,
      isTyping: json['isTyping'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sender': sender,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'suggestions': suggestions,
      'properties': properties?.map((p) => p.toJson()).toList(),
      'isTyping': isTyping,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? content,
    String? sender,
    MessageType? type,
    DateTime? timestamp,
    List<String>? suggestions,
    List<Property>? properties,
    bool? isTyping,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      suggestions: suggestions ?? this.suggestions,
      properties: properties ?? this.properties,
      isTyping: isTyping ?? this.isTyping,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChatMessage(id: $id, sender: $sender, type: $type, content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content})';
  }
}

enum MessageType {
  text,
  propertyList,
  propertyCard,
  suggestions,
  error,
  loading,
  welcome
}

class ChatSession {
  final String id;
  final String userId;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime lastActivity;
  final bool isActive;

  ChatSession({
    required this.id,
    required this.userId,
    required this.messages,
    required this.createdAt,
    required this.lastActivity,
    this.isActive = true,
  });

  ChatMessage? get lastMessage {
    return messages.isNotEmpty ? messages.last : null;
  }

  int get messageCount => messages.length;

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      messages: (json['messages'] as List<dynamic>?)
          ?.map((msg) => ChatMessage.fromJson(msg))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastActivity: DateTime.parse(json['lastActivity'] ?? DateTime.now().toIso8601String()),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastActivity': lastActivity.toIso8601String(),
      'isActive': isActive,
    };
  }

  ChatSession copyWith({
    String? id,
    String? userId,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? lastActivity,
    bool? isActive,
  }) {
    return ChatSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      lastActivity: lastActivity ?? this.lastActivity,
      isActive: isActive ?? this.isActive,
    );
  }

  ChatSession addMessage(ChatMessage message) {
    return copyWith(
      messages: [...messages, message],
      lastActivity: DateTime.now(),
    );
  }

  ChatSession removeMessage(String messageId) {
    return copyWith(
      messages: messages.where((msg) => msg.id != messageId).toList(),
      lastActivity: DateTime.now(),
    );
  }

  ChatSession updateMessage(String messageId, ChatMessage updatedMessage) {
    return copyWith(
      messages: messages.map((msg) => 
        msg.id == messageId ? updatedMessage : msg
      ).toList(),
      lastActivity: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChatSession(id: $id, userId: $userId, messageCount: $messageCount, lastActivity: $lastActivity)';
  }
}

// Utility class for predefined chat responses
class ChatResponses {
  static const String welcomeMessage = "👋 Hi! I'm your NES Properties assistant. How can I help you today?";
  
  static const List<String> defaultSuggestions = [
    "Show all properties",
    "Student accommodations",
    "Properties for women only",
    "Properties near USAS",
    "Budget friendly options",
    "View virtual tours",
  ];

  static const Map<String, String> quickResponses = {
    'greeting': "Hello! I'm here to help you find the perfect property.",
    'help': "I can help you search for properties, view virtual tours, and answer questions about our listings.",
    'goodbye': "Thank you for using NES Properties! Have a great day!",
    'error': "I'm sorry, I didn't understand that. Could you please rephrase your question?",
    'no_results': "I couldn't find any properties matching your criteria. Would you like to try a different search?",
  };

  static ChatMessage createWelcomeMessage() {
    return ChatMessage(
      id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
      content: welcomeMessage,
      sender: 'bot',
      type: MessageType.welcome,
      timestamp: DateTime.now(),
      suggestions: defaultSuggestions,
    );
  }

  static ChatMessage createErrorMessage(String error) {
    return ChatMessage(
      id: 'error_${DateTime.now().millisecondsSinceEpoch}',
      content: "I apologize, but I encountered an error: $error",
      sender: 'bot',
      type: MessageType.error,
      timestamp: DateTime.now(),
      suggestions: ['Try again', 'Show all properties', 'Contact support'],
    );
  }

  static ChatMessage createLoadingMessage() {
    return ChatMessage(
      id: 'loading_${DateTime.now().millisecondsSinceEpoch}',
      content: "Let me search for that...",
      sender: 'bot',
      type: MessageType.loading,
      timestamp: DateTime.now(),
      isTyping: true,
    );
  }

  static ChatMessage createPropertyListMessage(List<Property> properties) {
    final count = properties.length;
    String content;
    
    if (count == 0) {
      content = "I couldn't find any properties matching your criteria.";
    } else if (count == 1) {
      content = "I found 1 property that matches your search:";
    } else {
      content = "I found $count properties that match your search:";
    }

    return ChatMessage(
      id: 'property_list_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      sender: 'bot',
      type: MessageType.propertyList,
      timestamp: DateTime.now(),
      properties: properties,
      suggestions: count > 0 
          ? ['View details', 'Virtual tour', 'Contact owner', 'Save to favorites']
          : ['Show all properties', 'Change search criteria', 'Browse by type'],
    );
  }
}