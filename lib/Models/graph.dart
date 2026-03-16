import 'package:lab2/Models/graph_node.dart';

class Graph {
  final Map<String, GraphNode> _nodes = {};
  final Map<String, List<String>> _adjacencyList = {};

  void addNode(GraphNode node) {
    _nodes[node.id] = node;
    _adjacencyList.putIfAbsent(node.id, () => []);
  }

  void addConnection(String fromId, String toId) {
    if (!_nodes.containsKey(fromId) || !_nodes.containsKey(toId)) {
      throw Exception('Both nodes must exist before creating a connection.');
    }

    _adjacencyList[fromId]!.add(toId);
    _adjacencyList[toId]!.add(fromId);
  }

  bool hasDirectConnection(String fromId, String toId) {
    return _adjacencyList[fromId]?.contains(toId) ?? false;
  }

  List<String> getConnections(String nodeId) {
    return _adjacencyList[nodeId] ?? [];
  }

  List<List<String>> getAllPaths(String startId, String endId) {
    List<List<String>> paths = [];
    List<String> currentPath = [];
    Set<String> visited = {};

    void dfs(String current) {
      visited.add(current);
      currentPath.add(current);

      if (current == endId) {
        paths.add(List.from(currentPath));
      } else {
        for (final neighbor in _adjacencyList[current] ?? []) {
          if (!visited.contains(neighbor)) {
            dfs(neighbor);
          }
        }
      }

      currentPath.removeLast();
      visited.remove(current);
    }

    if (_nodes.containsKey(startId) && _nodes.containsKey(endId)) {
      dfs(startId);
    }

    return paths;
  }

  List<String> getShortestPath(String startId, String endId) {
    if (!_nodes.containsKey(startId) || !_nodes.containsKey(endId)) {
      return [];
    }

    final queue = <String>[startId];
    final visited = <String>{startId};
    final previous = <String, String?>{startId: null};

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);

      if (current == endId) {
        break;
      }

      for (final neighbor in _adjacencyList[current] ?? []) {
        if (!visited.contains(neighbor)) {
          visited.add(neighbor);
          previous[neighbor] = current;
          queue.add(neighbor);
        }
      }
    }

    if (!previous.containsKey(endId)) {
      return [];
    }

    final path = <String>[];
    String? current = endId;

    while (current != null) {
      path.add(current);
      current = previous[current];
    }

    return path.reversed.toList();
  }
}