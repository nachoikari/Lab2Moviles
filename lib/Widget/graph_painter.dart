import 'package:flutter/material.dart';
import 'package:lab2/Models/graph_edge.dart';
import 'package:lab2/Models/graph_node.dart';

class GraphPainter extends CustomPainter {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final Set<String> selectedNodeIds;
  final Offset? pendingNodePosition;
  final String? pendingNodeLabel;

  GraphPainter({
    required this.nodes,
    required this.edges,
    this.selectedNodeIds = const <String>{},
    this.pendingNodePosition,
    this.pendingNodeLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final normalLinePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    final highlightedLinePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    final normalNodePaint = Paint()..color = Colors.blue;
    final selectedNodePaint = Paint()..color = Colors.green;
    final pendingNodePaint = Paint()..color = Colors.green.withOpacity(0.35);
    final pendingOutlinePaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final nodeMap = {for (final node in nodes) node.id: node};

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
      canvas.drawCircle(
        node.position,
        24,
        selectedNodeIds.contains(node.id) ? selectedNodePaint : normalNodePaint,
      );

      textPainter.text = TextSpan(
        text: node.label,
        style: const TextStyle(color: Colors.black, fontSize: 14),
      );

      textPainter.layout();

      final textOffset = Offset(
        node.position.dx - (textPainter.width / 2),
        node.position.dy + 30,
      );

      textPainter.paint(canvas, textOffset);
    }

    if (pendingNodePosition != null) {
      canvas.drawCircle(pendingNodePosition!, 24, pendingNodePaint);
      canvas.drawCircle(pendingNodePosition!, 24, pendingOutlinePaint);

      if (pendingNodeLabel != null && pendingNodeLabel!.isNotEmpty) {
        textPainter.text = TextSpan(
          text: pendingNodeLabel!,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        );

        textPainter.layout();

        final previewTextOffset = Offset(
          pendingNodePosition!.dx - (textPainter.width / 2),
          pendingNodePosition!.dy + 30,
        );

        textPainter.paint(canvas, previewTextOffset);
      }
    }
  }

  @override
  bool shouldRepaint(covariant GraphPainter oldDelegate) {
    return oldDelegate.nodes != nodes ||
        oldDelegate.edges != edges ||
        oldDelegate.selectedNodeIds != selectedNodeIds ||
        oldDelegate.pendingNodePosition != pendingNodePosition ||
        oldDelegate.pendingNodeLabel != pendingNodeLabel;
  }
}
