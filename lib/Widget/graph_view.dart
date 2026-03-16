import 'package:flutter/material.dart';
import 'package:lab2/Models/graph_edge.dart';
import 'package:lab2/Models/graph_node.dart';
import 'package:lab2/Widget/graph_painter.dart';

class GraphView extends StatefulWidget {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final Set<String> selectedNodeIds;
  final Offset? pendingNodePosition;
  final String? pendingNodeLabel;
  final ValueChanged<String>? onNodeTap;
  final ValueChanged<Offset>? onCanvasTap;

  const GraphView({
    super.key,
    required this.nodes,
    required this.edges,
    this.selectedNodeIds = const <String>{},
    this.pendingNodePosition,
    this.pendingNodeLabel,
    this.onNodeTap,
    this.onCanvasTap,
  });

  @override
  State<GraphView> createState() => GraphViewState();
}

class GraphViewState extends State<GraphView> {
  static const double nodeRadius = 24;

  final double size = 4000;
  final TransformationController _transformationController =
      TransformationController();

  Size _viewportSize = Size.zero;
  bool _didSetInitialPosition = false;

  void resetToCenter({double scale = 1}) {
    if (_viewportSize == Size.zero) {
      return;
    }

    final targetSceneCenter = _calculateGraphCenter();
    final dx = (_viewportSize.width / 2) - (targetSceneCenter.dx * scale);
    final dy = (_viewportSize.height / 2) - (targetSceneCenter.dy * scale);

    _transformationController.value = Matrix4.identity()
      ..translate(dx, dy)
      ..scale(scale);
  }

  Offset _calculateGraphCenter() {
    if (widget.nodes.isEmpty) {
      return Offset(size / 2, size / 2);
    }

    double minX = widget.nodes.first.position.dx;
    double maxX = widget.nodes.first.position.dx;
    double minY = widget.nodes.first.position.dy;
    double maxY = widget.nodes.first.position.dy;

    for (final node in widget.nodes.skip(1)) {
      minX = node.position.dx < minX ? node.position.dx : minX;
      maxX = node.position.dx > maxX ? node.position.dx : maxX;
      minY = node.position.dy < minY ? node.position.dy : minY;
      maxY = node.position.dy > maxY ? node.position.dy : maxY;
    }

    return Offset((minX + maxX) / 2, (minY + maxY) / 2);
  }

  Offset getViewportCenterInScene() {
    if (_viewportSize == Size.zero) {
      return Offset(size / 2, size / 2);
    }

    return _transformationController.toScene(
      Offset(_viewportSize.width / 2, _viewportSize.height / 2),
    );
  }

  void _handleTapUp(TapUpDetails details) {
    final scenePoint = _transformationController.toScene(details.localPosition);

    for (final node in widget.nodes) {
      if ((scenePoint - node.position).distance <= nodeRadius) {
        widget.onNodeTap?.call(node.id);
        return;
      }
    }

    widget.onCanvasTap?.call(scenePoint);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _viewportSize = constraints.biggest;

        if (!_didSetInitialPosition && _viewportSize != Size.zero) {
          _didSetInitialPosition = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              resetToCenter();
            }
          });
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: _handleTapUp,
          child: InteractiveViewer(
            transformationController: _transformationController,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            minScale: 0.5,
            maxScale: 3,
            child: SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                size: Size(size, size),
                painter: GraphPainter(
                  nodes: widget.nodes,
                  edges: widget.edges,
                  selectedNodeIds: widget.selectedNodeIds,
                  pendingNodePosition: widget.pendingNodePosition,
                  pendingNodeLabel: widget.pendingNodeLabel,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
