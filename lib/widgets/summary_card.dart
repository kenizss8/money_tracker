import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: <Color>[color, Color.lerp(color, Colors.white, 0.4) ?? color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white.withValues(alpha: 0.22),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
