import 'package:flutter/material.dart';

class DashboardOrdersScreen extends StatefulWidget {
  const DashboardOrdersScreen({super.key, required this.title});

  final String title;

  @override
  State<DashboardOrdersScreen> createState() => _DashboardOrdersScreenState();
}

class _DashboardOrdersScreenState extends State<DashboardOrdersScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF08111F),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Dashboard Orders thgriuoghfdg",
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
