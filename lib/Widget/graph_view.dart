import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lab2/Models/graph_edge.dart';
import 'package:lab2/Models/graph_node.dart';
import 'package:lab2/Widget/graph_painter.dart';

class GraphView  extends StatelessWidget{
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;

  const GraphView({super.key,
    required this.nodes,
    required this.edges
  });

  @override
  Widget build(BuildContext context) {
    return(
      InteractiveViewer(
        boundaryMargin: EdgeInsets.all(50), 
        minScale: 0.5,
        maxScale: 3,
        child: CustomPaint(
          size: const Size(600, 600),
          painter: GraphPainter(nodes: nodes, edges: edges),
        ),
      )
    );


  }


}