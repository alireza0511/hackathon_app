import 'package:flutter/material.dart';
import 'package:hackathon_app/ollama_service.dart';
import 'package:hackathon_app/navigation_models.dart';
import 'package:hackathon_app/intent_resolver.dart';
import 'package:hackathon_app/deep_link_launcher.dart';

class FullScreenChatModal extends StatefulWidget {
  const FullScreenChatModal({super.key});

  @override
  State<FullScreenChatModal> createState() => _FullScreenChatModalState();
}

class _FullScreenChatModalState extends State<FullScreenChatModal> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hello! I'm your banking assistant. How can I help you today?", 
      isUser: false,
      quickReplies: [
        const QuickReply(text: 'Send Money', intent: 'zelle_payment'),
        const QuickReply(text: 'Check Balance', intent: 'account_balance'),
        const QuickReply(text: 'Transfer Funds', intent: 'transfer_funds'),
        const QuickReply(text: 'Pay Bills', intent: 'bill_payment'),
      ],
    ),
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

  Future<void> _sendMessage([String? overrideMessage]) async {
    final userMessage = overrideMessage ?? _messageController.text.trim();
    if (userMessage.isEmpty) return;

    if (overrideMessage == null) {
      _messageController.clear();
    }

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

      // Resolve intent using the new system
      final navigationResult = IntentResolver.routeFor(message: userMessage);
      
      final bankingContext = """You are a helpful banking assistant. Provide concise, professional answers about banking services, account management, transfers, and financial questions. Keep responses under 100 words.
      
Available banking services: Zelle transfers, account transfers, mobile deposits, loans, bill payments, account management, and card services.

${navigationResult.displayText != null ? 'Context: ${navigationResult.displayText}' : ''}""";

      final fullPrompt = "$bankingContext\n\nUser question: $userMessage\n\nResponse:";

      final response = await OllamaService.generateResponse(fullPrompt);

      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: response,
            isUser: false,
            navigationResult: navigationResult,
            quickReplies: navigationResult.quickReplies,
          ));
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

  void _handleQuickReply(QuickReply quickReply) {
    // For quick replies, we resolve the intent directly
    final navigationResult = IntentResolver.resolveIntent(intent: quickReply.intent, params: quickReply.params);
    
    setState(() {
      _messages.add(ChatMessage(text: quickReply.text, isUser: true));
      _messages.add(ChatMessage(
        text: navigationResult.displayText ?? "I can help you with that.",
        isUser: false,
        navigationResult: navigationResult,
      ));
    });
  }

  Future<void> _handleNavigationTap(NavigationResult navigationResult) async {
    // Launch the deep link
    final result = await navigationResult.launch();
    
    String feedbackMessage;
    switch (result.result) {
      case LaunchResult.success:
        feedbackMessage = "Opening the app now...";
        break;
      case LaunchResult.fallbackUsed:
        feedbackMessage = "Opening in your browser...";
        break;
      case LaunchResult.failed:
        feedbackMessage = "Sorry, I couldn't open that right now. You can try visiting our website or calling customer support.";
        break;
    }

    if (mounted) {
      setState(() {
        _messages.add(ChatMessage(
          text: feedbackMessage,
          isUser: false,
        ));
      });
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
                return ChatBubble(
                  message: message,
                  onQuickReply: _handleQuickReply,
                  onNavigationTap: _handleNavigationTap,
                );
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
  final NavigationResult? navigationResult;
  final List<QuickReply>? quickReplies;

  ChatMessage({
    required this.text, 
    required this.isUser,
    this.navigationResult,
    this.quickReplies,
  });
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final Function(QuickReply)? onQuickReply;
  final Function(NavigationResult)? onNavigationTap;

  const ChatBubble({
    super.key, 
    required this.message,
    this.onQuickReply,
    this.onNavigationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: message.isUser 
            ? CrossAxisAlignment.end 
            : CrossAxisAlignment.start,
        children: [
          // Main chat bubble
          Row(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          color: message.isUser ? Colors.white : Colors.black,
                        ),
                      ),
                      // CTA Button for navigation
                      if (message.navigationResult != null && 
                          !message.isUser && 
                          message.navigationResult!.intent != 'ambiguous' &&
                          message.navigationResult!.intent != 'no_route') ...[
                        const SizedBox(height: 12),
                        _buildCTAButton(context),
                      ],
                    ],
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
          // Quick reply chips
          if (!message.isUser && 
              (message.quickReplies?.isNotEmpty == true || 
               message.navigationResult?.quickReplies?.isNotEmpty == true)) ...[
            const SizedBox(height: 8),
            _buildQuickReplies(context),
          ],
        ],
      ),
    );
  }

  Widget _buildCTAButton(BuildContext context) {
    final navResult = message.navigationResult!;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => onNavigationTap?.call(navResult),
        icon: const Icon(Icons.launch, size: 16),
        label: Text(_getButtonText(navResult)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  Widget _buildQuickReplies(BuildContext context) {
    final quickReplies = message.quickReplies ?? message.navigationResult?.quickReplies ?? [];
    
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: quickReplies.map((reply) => _buildQuickReplyChip(reply)).toList(),
      ),
    );
  }

  Widget _buildQuickReplyChip(QuickReply reply) {
    return ActionChip(
      label: Text(
        reply.text,
        style: const TextStyle(fontSize: 13),
      ),
      backgroundColor: Colors.blue[50],
      side: BorderSide(color: Colors.blue[200]!, width: 1),
      onPressed: () => onQuickReply?.call(reply),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      labelPadding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      // Accessibility
      tooltip: 'Select ${reply.text}',
    );
  }

  String _getButtonText(NavigationResult navResult) {
    // Extract button text from navigation map or use default
    switch (navResult.intent) {
      case 'zelle_payment': return 'Open Zelle';
      case 'transfer_funds': return 'Transfer Funds';
      case 'check_deposit': return 'Deposit Check';
      case 'account_balance': return 'View Balance';
      case 'bill_payment': return 'Pay Bills';
      case 'loan_access': return 'View Loans';
      case 'card_management': return 'Manage Cards';
      case 'alerts_settings': return 'Alert Settings';
      case 'profile_management': return 'Edit Profile';
      case 'transaction_history': return 'View Transactions';
      case 'customer_support': return 'Get Support';
      default: return 'Open';
    }
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