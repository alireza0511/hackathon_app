import 'package:flutter/material.dart';
import 'package:hackathon_app/ollama_service.dart';

class FullScreenChatModal extends StatefulWidget {
  const FullScreenChatModal({super.key});

  @override
  State<FullScreenChatModal> createState() => _FullScreenChatModalState();
}

class _FullScreenChatModalState extends State<FullScreenChatModal> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(text: "Hello! I'm your banking assistant. How can I help you today?", isUser: false),
  ];
  bool _isLoading = false;
  bool _isOllamaConnected = false;

  @override
  void initState() {
    super.initState();
    _checkOllamaConnection();
  }

  Future<void> _checkOllamaConnection() async {
    final isConnected = await OllamaService.isServerAvailable();
    if (mounted) {
      setState(() {
        _isOllamaConnected = isConnected;
      });
      if (!isConnected) {
        _messages.add(ChatMessage(
          text: "⚠️ Ollama server is not available. Please make sure Ollama is running on localhost:11434",
          isUser: false,
        ));
      }
    }
  }

  Map<String, String> get _navigationMap => {
    'zelle': 'mobileapp://?destination=zelle',
    'transfer': 'mobileapp://?destination=transfer',
    'deposit': 'mobileapp://?destination=deposit',
    'loan': 'mobileapp://?destination=loan',
    'profile': 'mobileapp://?destination=profile',
    'account': 'mobileapp://?destination=account',
    'balance': 'mobileapp://?destination=balance',
    'payment': 'mobileapp://?destination=payment',
    'card': 'mobileapp://?destination=card',
    'settings': 'mobileapp://?destination=settings',
  };

  Map<String, List<String>> get _responsePatterns => {
    'zelle': ['zelle', 'send money', 'quick pay', 'person to person', 'p2p'],
    'transfer': ['transfer', 'move money', 'between accounts', 'internal transfer'],
    'deposit': ['deposit', 'add money', 'mobile deposit', 'check deposit'],
    'loan': ['loan', 'borrow', 'mortgage', 'credit', 'financing'],
    'profile': ['profile', 'personal info', 'update info', 'change details'],
    'account': ['account', 'account details', 'account info', 'my account'],
    'balance': ['balance', 'how much', 'account balance', 'current balance'],
    'payment': ['pay bill', 'payment', 'bill pay', 'pay bills'],
    'card': ['card', 'debit card', 'credit card', 'card settings'],
    'settings': ['settings', 'preferences', 'notifications', 'security'],
  };

  String? _determineNavigation(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    
    for (final entry in _responsePatterns.entries) {
      final destination = entry.key;
      final patterns = entry.value;
      
      for (final pattern in patterns) {
        if (lowerMessage.contains(pattern)) {
          return _navigationMap[destination];
        }
      }
    }
    
    return null;
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _isLoading = true;
    });

    try {
      if (!_isOllamaConnected) {
        await _checkOllamaConnection();
        if (!_isOllamaConnected) {
          throw Exception('Ollama server is not available');
        }
      }

      final navigationUrl = _determineNavigation(userMessage);
      
      final bankingContext = """You are a helpful banking assistant. Provide concise, professional answers about banking services, account management, transfers, and financial questions. Keep responses under 100 words.
      
Available banking services: Zelle transfers, account transfers, mobile deposits, loans, bill payments, account management, and card services.

${navigationUrl != null ? 'IMPORTANT: End your response with: "Would you like me to take you there? [Navigate]($navigationUrl)"' : ''}""";

      final fullPrompt = "$bankingContext\n\nUser question: $userMessage\n\nResponse:";

      final response = await OllamaService.generateResponse(fullPrompt);

      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(text: response, isUser: false));
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: "Sorry, I'm having trouble connecting to the AI service. Error: ${e.toString()}",
            isUser: false,
          ));
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              children: [
                const Text('Banking Assistant'),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isOllamaConnected ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return const LoadingBubble();
                }
                final message = _messages[index];
                return ChatBubble(message: message);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isLoading ? null : _sendMessage,
                    icon: _isLoading 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    style: IconButton.styleFrom(
                      backgroundColor: _isLoading ? Colors.grey : Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.support_agent, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? Colors.blue[600] 
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: message.isUser 
                      ? const Radius.circular(4) 
                      : const Radius.circular(16),
                  bottomLeft: !message.isUser 
                      ? const Radius.circular(4) 
                      : const Radius.circular(16),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[100],
              child: const Icon(Icons.person, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}

class LoadingBubble extends StatelessWidget {
  const LoadingBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.support_agent, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Thinking...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}