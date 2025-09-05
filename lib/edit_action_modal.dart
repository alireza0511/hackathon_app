import 'package:flutter/material.dart';

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