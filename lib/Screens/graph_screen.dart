import 'package:flutter/material.dart';
import 'package:lab2/Models/graph_edge.dart';
import 'package:lab2/Models/graph_node.dart';
import 'package:lab2/Widget/graph_view.dart';

class GraphScreen extends StatelessWidget {
  const GraphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nodes = [
      GraphNode(
        id: 'A',
        label: 'Library',
        position: const Offset(100, 100),
      ),
      GraphNode(
        id: 'B',
        label: 'Cafe',
        position: const Offset(300, 120),
      ),
      GraphNode(
        id: 'C',
        label: 'Lab',
        position: const Offset(220, 280),
      ),
      GraphNode(
        id: 'D',
        label: 'Park',
        position: const Offset(450, 250),
      ),
    ];

    final edges = [
      GraphEdge(from: 'A', to: 'B'),
      GraphEdge(from: 'A', to: 'C', isHighlighted: true),
      GraphEdge(from: 'B', to: 'D'),
      GraphEdge(from: 'C', to: 'D'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Graph View'),
      ),
      body: Center(
        child: GraphView(
          nodes: nodes,
          edges: edges,
        ),
      ),
    );
  }
}