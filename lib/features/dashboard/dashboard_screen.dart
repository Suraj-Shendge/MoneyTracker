import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/colors.dart';
import '../../data/database_service.dart';
import '../../data/models/expense_model.dart';

enum RangeType { today, month, custom }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  RangeType selectedRange = RangeType.month;

  DateTime? customStart;
  DateTime? customEnd;

  double totalExpense = 0;
  List<Expense> expenses = [];

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    DateTime now = DateTime.now();
    DateTime start;
    DateTime end = now;

    if (selectedRange == RangeType.today) {
      start = DateTime(now.year, now.month, now.day);
    } else if (selectedRange == RangeType.month) {
      start = DateTime(now.year, now.month, 1);
    } else {
      start = customStart ?? now;
      end = customEnd ?? now;
    }

    final data = await DatabaseService.instance
        .getExpensesByDateRange(start, end);

    double sum = 0;
    for (var e in data) {
      sum += e.amount;
    }

    setState(() {
      expenses = data;
      totalExpense = sum;
    });
  }

  Future<void> pickCustomRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.emerald,
              onPrimary: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (range != null) {
      customStart = range.start;
      customEnd = range.end;
      selectedRange = RangeType.custom;
      loadExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            buildHeader(),
            buildRangeSelector(),
            Expanded(child: buildExpenseList()),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.deepEmerald,
            AppColors.gold,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Total Expenses",
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(
              "₹ ${NumberFormat('#,##0').format(totalExpense)}",
              key: ValueKey(totalExpense),
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRangeSelector() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          rangeButton("Today", RangeType.today),
          rangeButton("This Month", RangeType.month),
          rangeButton("Custom", RangeType.custom),
        ],
      ),
    );
  }

  Widget rangeButton(String label, RangeType type) {
    final isSelected = selectedRange == type;

    return GestureDetector(
      onTap: () {
        if (type == RangeType.custom) {
          pickCustomRange();
        } else {
          setState(() {
            selectedRange = type;
          });
          loadExpenses();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.card : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.emerald),
        ),
        child: Text(label),
      ),
    );
  }

  Widget buildExpenseList() {
    if (expenses.isEmpty) {
      return const Center(
        child: Text("No expenses found"),
      );
    }

    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final e = expenses[index];
        return ListTile(
          title: Text(e.merchant),
          subtitle: Text(e.category),
          trailing: Text("₹ ${e.amount.toStringAsFixed(0)}"),
        );
      },
    );
  }
}
