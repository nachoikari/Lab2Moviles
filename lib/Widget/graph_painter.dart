
import 'package:flutter/material.dart';
import 'package:lab2/Models/graph_edge.dart';
import 'package:lab2/Models/graph_node.dart';

class GraphPainter extends CustomPainter {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;

  GraphPainter({
    required this.nodes,
    required this.edges,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final normalLinePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    final highlightedLinePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4;

    final nodePaint = Paint()..color = Colors.blue;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final nodeMap = {
      for (final node in nodes) node.id: node,
    };

    for (final edge in edges) {
      final fromNode = nodeMap[edge.from];
      final toNode = nodeMap[edge.to];

      if (fromNode == null || toNode == null) {
        continue;
      }

      canvas.drawLine(
        fromNode.position,
        toNode.position,
        edge.isHighlighted ? highlightedLinePaint : normalLinePaint,
      );
    }

    for (final node in nodes) {
      canvas.drawCircle(node.position, 24, nodePaint);

      textPainter.text = TextSpan(
        text: node.label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
        ),
      );

      textPainter.layout();

      final textOffset = Offset(
        node.position.dx - (textPainter.width / 2),
        node.position.dy + 30,
      );

      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant GraphPainter oldDelegate) {
    return oldDelegate.nodes != nodes || oldDelegate.edges != edges;
  }
}