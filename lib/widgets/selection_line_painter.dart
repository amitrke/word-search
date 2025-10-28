import 'package:flutter/material.dart';

class SelectionLinePainter extends CustomPainter {
  final List<Map<String, int>> selectedPath;
  final double cellSize;

  SelectionLinePainter({
    required this.selectedPath,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (selectedPath.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.7)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Get start and end cells
    final firstCell = selectedPath.first;
    final lastCell = selectedPath.last;

    final startX = (firstCell['col']! + 0.5) * cellSize;
    final startY = (firstCell['row']! + 0.5) * cellSize;
    final endX = (lastCell['col']! + 0.5) * cellSize;
    final endY = (lastCell['row']! + 0.5) * cellSize;

    // Draw straight line from start to end
    canvas.drawLine(
      Offset(startX, startY),
      Offset(endX, endY),
      paint,
    );

    // Draw circles at start and end for better visibility
    final circlePaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    // Start circle
    canvas.drawCircle(Offset(startX, startY), 8, circlePaint);

    // End circle (only if different from start)
    if (selectedPath.length > 1) {
      canvas.drawCircle(Offset(endX, endY), 8, circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant SelectionLinePainter oldDelegate) {
    return selectedPath != oldDelegate.selectedPath;
  }
}
