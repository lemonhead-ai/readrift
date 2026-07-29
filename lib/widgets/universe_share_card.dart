import 'package:flutter/material.dart';
import 'package:readrift/theme.dart';

class UniverseShareCard extends StatelessWidget {
  final String username;
  final int streak;
  final String bookTitle;
  final int minutesRead;

  const UniverseShareCard({
    super.key,
    required this.username,
    required this.streak,
    required this.bookTitle,
    required this.minutesRead,
  });

  String _getPersona() {
    if (streak >= 10) return "Universal Voyager";
    if (streak >= 5) return "Nebula Reader";
    return "Stellar Initiate";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        color: AppColors.oledBlack,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.accentOrange.withAlpha(80), width: 2),
      ),
      child: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentOrange.withAlpha(30),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "READRIFT",
                      style: TextStyle(
                        color: AppColors.accentOrange,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        fontSize: 14,
                      ),
                    ),
                    const Icon(Icons.auto_awesome_rounded, color: AppColors.accentOrange, size: 20),
                  ],
                ),
                const Spacer(),
                Text(
                  username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getPersona(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    _buildStat("STREAK", "$streak", Icons.local_fire_department_rounded),
                    const SizedBox(width: 24),
                    _buildStat("MINUTES", "$minutesRead", Icons.timer_rounded),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.book_rounded, color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bookTitle,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.accentOrange, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
