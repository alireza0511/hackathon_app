import 'package:flutter/material.dart';
import 'package:hackathon_app/action_tile.dart';
import 'package:hackathon_app/edit_action_modal.dart';
import 'package:hackathon_app/full_screen_chat_modal.dart';

class SimpleHubScreen extends StatefulWidget {
  const SimpleHubScreen({super.key});

  @override
  State<SimpleHubScreen> createState() => _SimpleHubScreenState();
}

class _SimpleHubScreenState extends State<SimpleHubScreen> {
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





