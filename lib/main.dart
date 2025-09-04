import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const BankingHubApp());
}

class OllamaService {
  static const String baseUrl = 'http://localhost:11434';
  static const String defaultModel = 'llama3.2';

  static Future<String> generateResponse(String prompt, {String? model}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': model ?? defaultModel,
          'prompt': prompt,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? 'No response received';
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to Ollama: $e');
    }
  }

  static Future<List<String>> getAvailableModels() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/tags'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = data['models'] as List<dynamic>? ?? [];
        return models.map((model) => model['name'] as String).toList();
      } else {
        return [defaultModel];
      }
    } catch (e) {
      return [defaultModel];
    }
  }

  static Future<bool> isServerAvailable() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/version'),
       // timeout: const Duration(seconds: 5),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

class BankingHubApp extends StatelessWidget {
  const BankingHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Banking Hub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const BankingHubScreen(),
    );
  }
}

class BankingHubScreen extends StatefulWidget {
  const BankingHubScreen({super.key});

  @override
  State<BankingHubScreen> createState() => _BankingHubScreenState();
}

class _BankingHubScreenState extends State<BankingHubScreen> {
  List<String> selectedActions = [ "Cheking Account ***1234 \n \$14,250.50","Zelle", "Transfer",  "Check Deposit"];
  final List<String> allActions = [
    "Cheking Account ***1234 \n \$14,250.50",
    "Zelle",
    "Transfer", 
    "Loan Access",
    "Check Deposit",
    "Notification Alert",
    "More",
    "Profile"
  ];

  void _showEditModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => EditActionsModal(
        allActions: allActions,
        selectedActions: selectedActions,
        onSelectionChanged: (newSelection) {
          setState(() {
            selectedActions = newSelection;
          });
        },
      ),
    );
  }

  void _showChatModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const FullScreenChatModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          Icon(Icons.swap_vertical_circle_sharp, color: Colors.black),
          SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Net Wealth Section
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'NET WEALTH',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$45,200',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Actions Header with Edit Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quick Actions',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: _showEditModal,
                        child: const Text('Edit'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Action Tiles
                  ...selectedActions.map((action) => ActionTile(
                    title: action,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Tapped $action')),
                      );
                    },
                  )),
                ],
              ),
            ),
          ),
          
          // Chat Section at Bottom
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'How can I assist you?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _showChatModal,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Type a message...',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ),
                        Icon(Icons.mic, color: Colors.grey[500], size: 20),
                        const SizedBox(width: 8),
                        Icon(Icons.send, color: Colors.grey[500], size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 26),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActionTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const ActionTile({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 1,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconForAction(title),
                    color: Colors.blue[700],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForAction(String action) {
    switch (action) {
      case 'Zelle':
        return Icons.send_rounded;
      case 'Transfer':
        return Icons.swap_horiz;
      case 'Loan Access':
        return Icons.account_balance;
      case 'Check Deposit':
        return Icons.camera_alt;
      case 'Notification Alert':
        return Icons.notifications;
      case 'More':
        return Icons.more_horiz;
      case 'Profile':
        return Icons.person;
      default:
        return Icons.circle;
    }
  }
}

class EditActionsModal extends StatefulWidget {
  final List<String> allActions;
  final List<String> selectedActions;
  final Function(List<String>) onSelectionChanged;

  const EditActionsModal({
    super.key,
    required this.allActions,
    required this.selectedActions,
    required this.onSelectionChanged,
  });

  @override
  State<EditActionsModal> createState() => _EditActionsModalState();
}

class _EditActionsModalState extends State<EditActionsModal> {
  late List<String> tempSelection;

  @override
  void initState() {
    super.initState();
    tempSelection = List.from(widget.selectedActions);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Quick Actions',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.onSelectionChanged(tempSelection);
                        Navigator.pop(context);
                      },
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: widget.allActions.length,
                  itemBuilder: (context, index) {
                    final action = widget.allActions[index];
                    final isSelected = tempSelection.contains(action);
                    
                    return CheckboxListTile(
                      title: Text(action),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            if (!tempSelection.contains(action)) {
                              tempSelection.add(action);
                            }
                          } else {
                            tempSelection.remove(action);
                          }
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

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

      final bankingContext = "You are a helpful banking assistant. Provide concise, professional answers about banking services, account management, transfers, and financial questions. Keep responses under 100 words.";
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