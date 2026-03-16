class GraphEdge {
  final String from;
  final String to;
  final bool isHighlighted;

  GraphEdge({
    required this.from,
    required this.to,
    this.isHighlighted = false,
  });
}