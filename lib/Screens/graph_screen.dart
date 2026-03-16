import 'package:flutter/material.dart';
import 'package:lab2/Models/graph_edge.dart';
import 'package:lab2/Models/graph_node.dart';
import 'package:lab2/Widget/graph_view.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  final GlobalKey<GraphViewState> _graphViewKey = GlobalKey<GraphViewState>();

  late final List<GraphNode> _nodes;
  late final List<GraphEdge> _edges;

  bool _isCreatingNode = false;
  String? _pendingNodeLabel;
  Offset? _pendingNodePosition;
  Set<String> _selectedLinkIds = <String>{};

  @override
  void initState() {
    super.initState();

    _nodes = [
      GraphNode(id: 'A', label: 'Library', position: const Offset(100, 100)),
      GraphNode(id: 'B', label: 'Cafe', position: const Offset(300, 120)),
      GraphNode(id: 'C', label: 'Lab', position: const Offset(220, 280)),
      GraphNode(id: 'D', label: 'Park', position: const Offset(450, 250)),
    ];

    _edges = [
      GraphEdge(from: 'A', to: 'B'),
      GraphEdge(from: 'A', to: 'C', isHighlighted: true),
      GraphEdge(from: 'B', to: 'D'),
      GraphEdge(from: 'C', to: 'D'),
    ];
  }

  Future<void> _startNodeCreation() async {
    String draftLabel = '';

    final nodeLabel = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Nuevo grafo'),
          content: TextField(
            autofocus: false,
            decoration: const InputDecoration(
              labelText: 'Nombre del grafo',
              hintText: 'Ej. Aula 1',
            ),
            onChanged: (value) {
              draftLabel = value;
            },
            onSubmitted: (value) {
              Navigator.of(dialogContext).pop(value.trim());
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                FocusScope.of(dialogContext).unfocus();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                FocusScope.of(dialogContext).unfocus();
                Navigator.of(dialogContext).pop(draftLabel.trim());
              },
              child: const Text('Siguiente'),
            ),
          ],
        );
      },
    );

    if (!mounted || nodeLabel == null || nodeLabel.isEmpty) {
      return;
    }

    setState(() {
      _isCreatingNode = true;
      _pendingNodeLabel = nodeLabel;
      _pendingNodePosition = null;
      _selectedLinkIds = <String>{};
    });
  }

  void _toggleNodeSelection(String nodeId) {
    if (!_isCreatingNode) {
      return;
    }

    setState(() {
      final nextSelection = Set<String>.from(_selectedLinkIds);

      if (nextSelection.contains(nodeId)) {
        nextSelection.remove(nodeId);
      } else {
        nextSelection.add(nodeId);
      }

      _selectedLinkIds = nextSelection;
    });
  }

  void _selectPendingNodePosition(Offset position) {
    if (!_isCreatingNode) {
      return;
    }

    setState(() {
      _pendingNodePosition = position;
    });
  }

  void _confirmNodeCreation() {
    if (!_isCreatingNode ||
        _pendingNodeLabel == null ||
        _pendingNodePosition == null) {
      return;
    }

    final newId = 'N${_nodes.length + 1}';

    setState(() {
      _nodes.add(
        GraphNode(
          id: newId,
          label: _pendingNodeLabel!,
          position: _pendingNodePosition!,
        ),
      );

      for (final linkedNodeId in _selectedLinkIds) {
        final alreadyExists = _edges.any(
          (edge) =>
              (edge.from == newId && edge.to == linkedNodeId) ||
              (edge.from == linkedNodeId && edge.to == newId),
        );

        if (!alreadyExists) {
          _edges.add(GraphEdge(from: newId, to: linkedNodeId));
        }
      }

      _isCreatingNode = false;
      _pendingNodeLabel = null;
      _pendingNodePosition = null;
      _selectedLinkIds = <String>{};
    });
  }

  void _cancelNodeCreation() {
    setState(() {
      _isCreatingNode = false;
      _pendingNodeLabel = null;
      _pendingNodePosition = null;
      _selectedLinkIds = <String>{};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Graph View', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: GraphView(
              key: _graphViewKey,
              nodes: _nodes,
              edges: _edges,
              selectedNodeIds: _selectedLinkIds,
              pendingNodePosition: _pendingNodePosition,
              pendingNodeLabel: _pendingNodeLabel,
              onNodeTap: _toggleNodeSelection,
              onCanvasTap: _selectPendingNodePosition,
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.small(
                  heroTag: 'center_view',
                  onPressed: () => _graphViewKey.currentState?.resetToCenter(),
                  child: const Icon(Icons.center_focus_strong),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.small(
                  heroTag: 'create_graph',
                  onPressed: _startNodeCreation,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          if (_isCreatingNode)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nuevo grafo: ${_pendingNodeLabel ?? ''}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toca los nodos que quieras enlazar y luego toca un espacio vacío para elegir la posición.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _pendingNodePosition == null
                            ? 'Posición pendiente.'
                            : 'Posición seleccionada: '
                                  '(${_pendingNodePosition!.dx.toStringAsFixed(0)}, '
                                  '${_pendingNodePosition!.dy.toStringAsFixed(0)})',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _cancelNodeCreation,
                            child: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: _pendingNodePosition == null
                                ? null
                                : _confirmNodeCreation,
                            child: const Text('Confirmar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
