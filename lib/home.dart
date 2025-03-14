import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class Lens {
  final String eye; // 'left' or 'right'
  final DateTime openDate;
  final String type;
  final int durationDays;

  Lens({
    required this.eye,
    required this.openDate,
    required this.type,
    required this.durationDays,
  });

  int get daysRemaining {
    final expiryDate = openDate.add(Duration(days: durationDays));
    return expiryDate.difference(DateTime.now()).inDays;
  }

  DateTime get expiryDate {
    return openDate.add(Duration(days: durationDays));
  }

  String get formattedExpiryDate {
    return DateFormat('M/d/yy').format(expiryDate);
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Lens? leftLens;
  Lens? rightLens;
  int stocksRemaining = 0;
  String selectedEye = 'left'; // Track which eye is being edited

  // Random facts about contact lenses
  final List<String> facts = [
    "The solution from the day before loses its disinfectant and preservative properties and will not work as it should if not changed daily (even if the lenses have not been worn).",
    "In the early 60s, two Czechoslovakian researchers designed the first hydrogel contact lenses: the soft ones.",
    "Daily disposable lenses are the healthiest option as they reduce the risk of eye infections.",
    "Contact lenses should never be stored in water, as this can lead to serious eye infections.",
    "The first contact lens was made of glass in the late 1800s.",
  ];

  String get randomFact {
    return facts[Random().nextInt(facts.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hi',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Lens status card
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildEyeStatus('Left', leftLens),
                        const SizedBox(width: 20),
                        _buildEyeStatus('Right', rightLens),
                      ],
                    ),
                    if (leftLens != null || rightLens != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.grey),
                            onPressed: () {
                              _showAddLensDialog();
                            },
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text(
                              'REMOVE',
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () {
                              _showRemoveDialog();
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Did you know section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Did you know?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    randomFact,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Stocks section
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Stocks',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$stocksRemaining',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Lenses Left',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Add new lenses button
              ElevatedButton(
                onPressed: () {
                  _showAddLensDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Add New Lens',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEyeStatus(String eye, Lens? lens) {
    return Expanded(
      child: Column(
        children: [
          Text(eye, style: const TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 10),
          Text(
            lens?.daysRemaining.toString() ?? '0',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          Text(
            lens?.formattedExpiryDate ?? '-/-/-',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Container(
            height: 70,
            width: 30,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Container(
                height: lens != null ? 50 : 0,
                width: 20,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to show the add lens dialog
  void _showAddLensDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildAddLensForm(context),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddLensForm(BuildContext dialogContext) {
    final DateTime now = DateTime.now();
    DateTime leftOpenDate = leftLens?.openDate ?? now;
    DateTime rightOpenDate = rightLens?.openDate ?? now;
    String leftType = leftLens?.type ?? 'Monthly';
    String rightType = rightLens?.type ?? 'Monthly';

    // Use the current selected eye to determine which date to show
    DateTime selectedDate =
        selectedEye == 'left' ? leftOpenDate : rightOpenDate;
    String selectedType = selectedEye == 'left' ? leftType : rightType;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Add New Lens',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLensSelector('Left\nLens', selectedEye == 'left',
                    (isSelected) {
                  if (isSelected) {
                    setState(() {
                      selectedEye = 'left';
                      selectedDate = leftOpenDate;
                      selectedType = leftType;
                    });
                  }
                }),
                _buildLensSelector('Right\nLens', selectedEye == 'right',
                    (isSelected) {
                  if (isSelected) {
                    setState(() {
                      selectedEye = 'right';
                      selectedDate = rightOpenDate;
                      selectedType = rightType;
                    });
                  }
                }),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Open Date',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 10),

            // Month selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Month',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 5),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int i = 0; i < 12; i++)
                        _buildMonthButton(
                          DateFormat('MMM').format(DateTime(2023, i + 1)),
                          selectedDate.month == i + 1,
                          () {
                            setState(() {
                              if (selectedEye == 'left') {
                                leftOpenDate = DateTime(
                                  selectedDate.year,
                                  i + 1,
                                  selectedDate.day >
                                          DateUtils.getDaysInMonth(
                                              selectedDate.year, i + 1)
                                      ? DateUtils.getDaysInMonth(
                                          selectedDate.year, i + 1)
                                      : selectedDate.day,
                                );
                                selectedDate = leftOpenDate;
                              } else {
                                rightOpenDate = DateTime(
                                  selectedDate.year,
                                  i + 1,
                                  selectedDate.day >
                                          DateUtils.getDaysInMonth(
                                              selectedDate.year, i + 1)
                                      ? DateUtils.getDaysInMonth(
                                          selectedDate.year, i + 1)
                                      : selectedDate.day,
                                );
                                selectedDate = rightOpenDate;
                              }
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Day selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 5),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int day = 1;
                          day <=
                              DateUtils.getDaysInMonth(
                                  selectedDate.year, selectedDate.month);
                          day++)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: selectedDate.day == day
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  if (selectedEye == 'left') {
                                    leftOpenDate = DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      day,
                                    );
                                    selectedDate = leftOpenDate;
                                  } else {
                                    rightOpenDate = DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      day,
                                    );
                                    selectedDate = rightOpenDate;
                                  }
                                });
                              },
                              child: Text(
                                day.toString(),
                                style: TextStyle(
                                  color: selectedDate.day == day
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text(
              'Type',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            _buildTypeDropdown(
              selectedEye == 'left' ? leftType : rightType,
              (value) {
                setState(() {
                  if (selectedEye == 'left') {
                    leftType = value!;
                  } else {
                    rightType = value!;
                  }
                });
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () {
                    _saveLenses(
                      leftOpenDate,
                      rightOpenDate,
                      leftType,
                      rightType,
                    );
                    Navigator.pop(dialogContext);
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildLensSelector(
    String label,
    bool isSelected,
    Function(bool) onSelected,
  ) {
    return GestureDetector(
      onTap: () =>
          onSelected(true),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthButton(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeDropdown(String value, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        dropdownColor: Theme.of(context).colorScheme.surface,
        underline: const SizedBox(),
        onChanged: onChanged,
        items: const [
          DropdownMenuItem(value: 'Daily', child: Text('Daily')),
          DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
          DropdownMenuItem(value: 'Bi-weekly', child: Text('Bi-weekly')),
          DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
          DropdownMenuItem(value: 'Bi-Monthly', child: Text('Bi-Monthly')),
        ],
      ),
    );
  }

  void _saveLenses(
    DateTime leftDate,
    DateTime rightDate,
    String leftType,
    String rightType,
  ) {
    // Convert lens type to duration in days
    int getDuration(String type) {
      switch (type) {
        case 'Daily':
          return 1;
        case 'Weekly':
          return 7;
        case 'Bi-weekly':
          return 14;
        case 'Monthly':
          return 30;
        case 'Bi-Monthly':
          return 60;
        default:
          return 30;
      }
    }

    setState(() {
      leftLens = Lens(
        eye: 'left',
        openDate: leftDate,
        type: leftType,
        durationDays: getDuration(leftType),
      );

      rightLens = Lens(
        eye: 'right',
        openDate: rightDate,
        type: rightType,
        durationDays: getDuration(rightType),
      );
    });
  }

  void _showRemoveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Lenses'),
        content: const Text(
          'Are you sure you want to remove the current lenses?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                leftLens = null;
                rightLens = null;
              });
              Navigator.pop(context);
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
