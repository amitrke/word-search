import 'package:flutter/material.dart';

class WordLinePainter extends CustomPainter {
  final Map<String, List<Map<String, int>>> foundWordPaths;
  final double cellSize;
  final int gridSize;

  WordLinePainter({
    required this.foundWordPaths,
    required this.cellSize,
    required this.gridSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Define colors for found words (cycle through different colors)
    final colors = [
      Colors.green.withValues(alpha: 0.6),
      Colors.blue.withValues(alpha: 0.6),
      Colors.purple.withValues(alpha: 0.6),
      Colors.orange.withValues(alpha: 0.6),
      Colors.red.withValues(alpha: 0.6),
      Colors.teal.withValues(alpha: 0.6),
    ];

    int colorIndex = 0;

    // Draw a line for each found word
    for (final entry in foundWordPaths.entries) {
      final path = entry.value;
      if (path.isEmpty) continue;

      // Set color for this word
      paint.color = colors[colorIndex % colors.length];
      colorIndex++;

      // Get start and end positions
      final startCell = path.first;
      final endCell = path.last;

      // Calculate center positions of the cells
      final startX = (startCell['col']! + 0.5) * cellSize;
      final startY = (startCell['row']! + 0.5) * cellSize;
      final endX = (endCell['col']! + 0.5) * cellSize;
      final endY = (endCell['row']! + 0.5) * cellSize;

      // Draw line from start to end
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );

      // Draw circles at start and end for better visibility
      final circlePaint = Paint()
        ..color = paint.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(startX, startY), 6, circlePaint);
      canvas.drawCircle(Offset(endX, endY), 6, circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant WordLinePainter oldDelegate) {
    return foundWordPaths != oldDelegate.foundWordPaths ||
        cellSize != oldDelegate.cellSize;
  }
}
