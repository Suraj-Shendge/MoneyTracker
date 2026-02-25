import 'dart:math';
import 'package:flutter/material.dart';
import 'expense_card.dart';
import 'lending_card.dart';

class FinanceCardStack extends StatefulWidget {
  final double totalExpense;

  const FinanceCardStack({super.key, required this.totalExpense});

  @override
  State<FinanceCardStack> createState() => _FinanceCardStackState();
}

class _FinanceCardStackState extends State<FinanceCardStack>
    with SingleTickerProviderStateMixin {
  double dragX = 0;
  double dragY = 0;

  int activeIndex = 0;

  late AnimationController controller;
  late Animation<double> animation;

  final List<String> cards = ["expense", "lending"];

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  void resetPosition() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    animation = Tween<double>(begin: dragX, end: 0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    )..addListener(() {
        setState(() {
          dragX = animation.value;
          dragY = 0;
        });
      });

    controller.forward();
  }

  void completeSwipe() {
    setState(() {
      activeIndex = (activeIndex + 1) % cards.length;
      dragX = 0;
      dragY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double rotation = dragX / screenWidth * 0.2;
    double backgroundScale =
        0.94 + (dragX.abs() / screenWidth).clamp(0, 1) * 0.06;

    return SizedBox(
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.scale(
            scale: backgroundScale,
            child: SizedBox(
              width: screenWidth - 32,
              child: activeIndex == 0
                  ? const LendingCard()
                  : ExpenseCard(totalExpense: widget.totalExpense),
            ),
          ),
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                dragX += details.delta.dx;
                dragY += details.delta.dy * 0.2;
              });
            },
            onPanEnd: (details) {
              if (dragX.abs() > 120) {
                completeSwipe();
              } else {
                resetPosition();
              }
            },
            child: Transform.translate(
              offset: Offset(dragX, dragY),
              child: Transform.rotate(
                angle: rotation,
                child: SizedBox(
                  width: screenWidth - 32,
                  child: activeIndex == 0
                      ? ExpenseCard(totalExpense: widget.totalExpense)
                      : const LendingCard(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
