import 'package:flutter/material.dart';
import '../../../core/colors.dart';
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
  int activeIndex = 0;

  final List<String> cards = ["expense", "lending"];

  void switchCard() {
    setState(() {
      activeIndex = (activeIndex + 1) % cards.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: GestureDetector(
        onHorizontalDragEnd: (_) {
          switchCard();
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            buildCard(1),
            buildCard(0),
          ],
        ),
      ),
    );
  }

  Widget buildCard(int stackPosition) {
    int cardIndex =
        (activeIndex + stackPosition) % cards.length;

    bool isTop = stackPosition == 0;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      top: isTop ? 0 : 20,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 350),
        scale: isTop ? 1.0 : 0.94,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 350),
          opacity: isTop ? 1.0 : 0.85,
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 32,
            child: cardIndex == 0
                ? ExpenseCard(totalExpense: widget.totalExpense)
                : const LendingCard(),
          ),
        ),
      ),
    );
  }
}
