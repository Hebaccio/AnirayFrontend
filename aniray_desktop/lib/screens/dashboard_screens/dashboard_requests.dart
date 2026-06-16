import 'package:flutter/material.dart';

class DashboardRequestsScreen extends StatefulWidget {
  const DashboardRequestsScreen({super.key, required this.title});

  final String title;

  @override
  State<DashboardRequestsScreen> createState() =>
      _DashboardRequestsScreenState();
}

class _DashboardRequestsScreenState extends State<DashboardRequestsScreen> {
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
              "Dashboard Requests thgriuoghfdg",
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
