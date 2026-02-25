import 'package:flutter/material.dart';
import '../../../core/colors.dart';

class CategoryRow extends StatelessWidget {
  const CategoryRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          CategoryItem(
            color: Color(0xFF2ECC71),
            icon: Icons.local_gas_station,
            label: "Fuel",
          ),
          CategoryItem(
            color: Color(0xFF9B59B6),
            icon: Icons.fastfood,
            label: "Food",
          ),
          CategoryItem(
            color: Color(0xFF3498DB),
            icon: Icons.shopping_cart,
            label: "Shopping",
          ),
          CategoryItem(
            color: Color(0xFF8D6E63),
            icon: Icons.receipt_long,
            label: "Bills",
          ),
          CategoryItem(
            color: Color(0xFFE91E63),
            icon: Icons.more_horiz,
            label: "Other",
          ),
        ],
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;

  const CategoryItem({
    super.key,
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
