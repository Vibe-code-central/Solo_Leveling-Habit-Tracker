import 'package:flutter/material.dart';
import 'package:solo_leveling/core/theme/app_theme.dart';
import 'package:solo_leveling/data/models/gate.dart';
import 'package:solo_leveling/presentation/screens/gates/gate_screen.dart';

class GateDialog extends StatelessWidget {
  final Gate gate;

  const GateDialog({super.key, required this.gate});

  @override
  Widget build(BuildContext context) {
    final isRedGate = gate.type == GateType.red;
    final primaryColor =
        isRedGate ? AppTheme.systemCrimson : AppTheme.systemCyan;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.systemNavy.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Text(
              gate.icon,
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'DUNGEON BREAK',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: primaryColor,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),

            // Divider
            Divider(color: primaryColor, thickness: 1),
            const SizedBox(height: 16),

            // Description
            Text(
              isRedGate
                  ? 'A Red Gate has appeared nearby!\nHigh mana reading.\nDanger Level: S-Rank'
                  : 'A dimensional rift has been detected.\nComplete the objective to close it.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 16,
                color: AppTheme.systemWhite,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!isRedGate)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'IGNORE',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GateScreen(gate: gate),
                      ),
                    );
                  },
                  child: Text(
                    'ENTER',
                    style: const TextStyle(
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
