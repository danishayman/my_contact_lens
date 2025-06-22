import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'dart:async';

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
    final remaining = expiryDate.difference(DateTime.now()).inDays;
    // Return 0 if the remaining days is negative
    return remaining > 0 ? remaining : 0;
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

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  Lens? leftLens;
  Lens? rightLens;
  int stocksRemaining = 0;
  String selectedEye = 'left'; // Track which eye is being edited

  // Animation controllers
  late AnimationController _leftWaveController;
  late AnimationController _rightWaveController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _factController;

  // Animations
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _factAnimation;

  int _currentFactIndex = 0;
  Timer? _factTimer;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _leftWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _rightWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Pulse animation for the add button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotate animation for the edit icon
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.elasticOut),
    );

    // Fact transition animation
    _factController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _factAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _factController, curve: Curves.easeInOut),
    );

    // Change fact every 10 seconds
    _factTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _changeRandomFact();
    });
  }

  void _changeRandomFact() {
    _factController.reset();
    _factController.forward().then((_) {
      setState(() {
        int newIndex;
        do {
          newIndex = Random().nextInt(facts.length);
        } while (newIndex == _currentFactIndex);
        _currentFactIndex = newIndex;
      });
    });
  }

  @override
  void dispose() {
    _leftWaveController.dispose();
    _rightWaveController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _factController.dispose();
    _factTimer?.cancel();
    super.dispose();
  }

  // Random facts about contact lenses
  final List<String> facts = [
    "The solution from the day before loses its disinfectant and preservative properties and will not work as it should if not changed daily (even if the lenses have not been worn).",
    "In the early 60s, two Czechoslovakian researchers designed the first hydrogel contact lenses: the soft ones.",
    "Daily disposable lenses are the healthiest option as they reduce the risk of eye infections.",
    "Contact lenses should never be stored in water, as this can lead to serious eye infections.",
    "The first contact lens was made of glass in the late 1800s.",
    "Over 45 million Americans wear contact lenses.",
    "The average human blink lasts about 1/10th of a second.",
    "Contact lenses can be tinted to change eye color or improve vision for color blindness.",
    "Leonardo da Vinci first sketched the concept of contact lenses in 1508.",
  ];

  String get randomFact {
    return facts[_currentFactIndex];
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
              // Animated greeting
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: const Text(
                  'Hi',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              // Lens status card with animation
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 30 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
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
                            AnimatedBuilder(
                              animation: _rotateAnimation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _rotateAnimation.value,
                                  child: IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.grey),
                                    onPressed: () {
                                      _rotateController.reset();
                                      _rotateController.forward();
                                      _showAddLensDialog();
                                    },
                                  ),
                                );
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
              ),

              const SizedBox(height: 20),

              // Did you know section with fade animation
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 40 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Column(
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
                    AnimatedBuilder(
                      animation: _factAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _factAnimation.value,
                          child: Text(
                            randomFact,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white70),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Stocks section with animation
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 50 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
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
                          TweenAnimationBuilder(
                            tween: IntTween(begin: 0, end: stocksRemaining),
                            duration: const Duration(milliseconds: 1000),
                            builder: (context, int value, child) {
                              return Text(
                                '$value',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                          const Text(
                            'Lenses Left',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Add new lenses button with pulse animation
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 60 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: ElevatedButton(
                        onPressed: () {
                          _showAddLensDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 5,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline),
                            SizedBox(width: 10),
                            Text(
                              'Add New Lens',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEyeStatus(String eye, Lens? lens) {
    final isLeft = eye == 'Left';
    final controller = isLeft ? _leftWaveController : _rightWaveController;

    // Calculate fill percentage based on days remaining
    double fillPercentage = 0.0;
    if (lens != null) {
      // Calculate percentage of days remaining out of total duration
      fillPercentage = lens.daysRemaining / lens.durationDays;
      // Clamp between 0 and 1
      fillPercentage = fillPercentage.clamp(0.0, 1.0);
    }

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
            child: lens != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: AnimatedBuilder(
                      animation: controller,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: WavePainter(
                            controller.value,
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.5),
                            fillPercentage,
                          ),
                          child: Container(),
                        );
                      },
                    ),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  // Method to show the add lens dialog with animation
  void _showAddLensDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: Dialog(
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
            // Title with animation
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 400),
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Add New Lens',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Eye selector with animation
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAnimatedLensSelector(
                      'Left\nLens', selectedEye == 'left', (isSelected) {
                    if (isSelected) {
                      setState(() {
                        selectedEye = 'left';
                        selectedDate = leftOpenDate;
                        selectedType = leftType;
                      });
                    }
                  }),
                  _buildAnimatedLensSelector(
                      'Right\nLens', selectedEye == 'right', (isSelected) {
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
            ),

            const SizedBox(height: 20),

            // Open Date label with animation
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: const Text(
                'Open Date',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 10),

            // Month selection with animation
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Column(
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
            ),

            const SizedBox(height: 15),

            // Day selection with animation
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Column(
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
                          _buildDayButton(day, selectedDate, (selectedDay) {
                            setState(() {
                              if (selectedEye == 'left') {
                                leftOpenDate = DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDay,
                                );
                                selectedDate = leftOpenDate;
                              } else {
                                rightOpenDate = DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDay,
                                );
                                selectedDate = rightOpenDate;
                              }
                            });
                          }),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Type label with animation
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: const Text(
                'Type',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 10),

            // Type dropdown with animation
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: _buildTypeDropdown(
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
            ),

            const SizedBox(height: 20),

            // Buttons with animation
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1100),
              curve: Curves.easeOutCubic,
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      _saveLenses(
                        leftOpenDate,
                        rightOpenDate,
                        leftType,
                        rightType,
                      );
                      Navigator.pop(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Text(
                        'Save',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Animated lens selector with hover effect
  Widget _buildAnimatedLensSelector(
    String label,
    bool isSelected,
    Function(bool) onSelected,
  ) {
    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTap: () => onSelected(true),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.withOpacity(0.3),
                width: 1.5,
              ),
            ),
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
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 5),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
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
          ),
        );
      },
    );
  }

  // Animated day button with ripple effect
  Widget _buildDayButton(
      int day, DateTime selectedDate, Function(int) onDaySelected) {
    final bool isSelected = selectedDate.day == day;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.8, end: 1.0),
        duration: const Duration(milliseconds: 200),
        builder: (context, double value, child) {
          return Transform.scale(
            scale: isSelected ? value : 1.0,
            child: child,
          );
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onDaySelected(day),
            borderRadius: BorderRadius.circular(18),
            splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            highlightColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Ink(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
              ),
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
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
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              title: const Text('Remove Lenses'),
              content: const Text(
                'Are you sure you want to remove the current lenses?',
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
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
          ),
        );
      },
    );
  }
}

// Custom painter for the wave animation
class WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final Color secondColor;
  final double fillPercentage;

  WavePainter(
      this.animationValue, this.color, this.secondColor, this.fillPercentage);

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate the height of the fill
    final double fillHeight = size.height * (1 - fillPercentage);
    final double waveHeight = size.height * 0.05; // Height of the wave
    final double baseHeight = fillHeight - waveHeight;

    // Create the path for the first wave
    final path = Path();
    path.moveTo(0, baseHeight);

    // Draw the wave pattern
    for (int i = 0; i < size.width.toInt() + 2; i++) {
      final x = i.toDouble();
      final waveHeight1 =
          sin((animationValue * 360 - x) * pi / 180) * waveHeight;
      path.lineTo(x, baseHeight + waveHeight1);
    }

    // Complete the path to fill the bottom of the container
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Create the paint for the first wave
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw the first wave
    canvas.drawPath(path, paint);

    // Create the path for the second wave (offset slightly for a layered effect)
    final path2 = Path();
    path2.moveTo(0, baseHeight);

    // Draw the second wave pattern with a phase offset
    for (int i = 0; i < size.width.toInt() + 2; i++) {
      final x = i.toDouble();
      final waveHeight2 =
          sin((animationValue * 360 - x + 30) * pi / 180) * waveHeight;
      path2.lineTo(x, baseHeight + waveHeight2);
    }

    // Complete the second path
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    // Create the paint for the second wave
    final paint2 = Paint()
      ..color = secondColor
      ..style = PaintingStyle.fill;

    // Draw the second wave
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}
