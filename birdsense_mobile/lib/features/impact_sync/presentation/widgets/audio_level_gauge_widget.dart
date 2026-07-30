import 'package:flutter/material.dart';

class AudioLevelGaugeWidget extends StatelessWidget {
  final double decibels; // De -120 à 0

  const AudioLevelGaugeWidget({
    Key? key,
    required this.decibels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Normaliser de -80 (0%) à 0 (100%)
    final normalized = ((decibels + 80) / 80).clamp(0.0, 1.0);
    
    Color barColor;
    if (normalized < 0.4) {
      barColor = Colors.green;
    } else if (normalized < 0.7) {
      barColor = Colors.orange;
    } else {
      barColor = Colors.red;
    }

    return Container(
      width: 20,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          FractionallySizedBox(
            heightFactor: normalized,
            child: Container(
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const Positioned(
            bottom: 4,
            child: Icon(Icons.mic, size: 12, color: Colors.white70),
          )
        ],
      ),
    );
  }
}
