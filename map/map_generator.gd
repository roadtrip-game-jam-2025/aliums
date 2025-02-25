extends Node2D

@export var altitude_noise: FastNoiseLite

enum TileType { LAND, SEA }

const TILE_SIZE = 5
@export var sea_level = 0.01
@export var center_weight = 1.0
@export var map_width = 128
@export var minimum_land_ratio = 0.5
@export var max_attempts = 100
@export var points_of_interest_count = 30
@export var max_road_length: float = 20.0

var generated_map: Dictionary = {}
var tiles: Dictionary = {}
var points_of_interest: Array[Vector2i] = []
var roads: Dictionary = {}

func _ready() -> void:
  altitude_noise.seed = randi_range(0,2048)

func generate_continent() -> void:
  for m in range(map_width):
    for n in range(map_width):
      var x = n - map_width / 2.0
      var y = m - map_width / 2.0
      var value = altitude_value(x, y)
      tiles[Vector2i(int(x), int(y))] = value

func altitude_value(x: float, y: float) -> TileType:
    var value = altitude_noise.get_noise_2d(x, y)
    var center = Vector2(0,0)
    var distance = sqrt((x-center.x)*(x-center.x) + (y-center.y)*(y-center.y))
    value *= exp(-center_weight * distance / (map_width * 0.5))

    if value >= sea_level:
        return TileType.LAND

    return TileType.SEA

func get_altitude(x: float, y: float) -> float:
    var value = altitude_noise.get_noise_2d(x, y)
    var center = Vector2(0,0)
    var distance = sqrt((x-center.x)*(x-center.x) + (y-center.y)*(y-center.y))
    return value * exp(-center_weight * distance / (map_width * 0.5))

func generate_terrain() -> void:
  for _i in range(max_attempts):
    altitude_noise.seed = randi_range(0,2048)
    tiles = {}
    generate_continent()
    var continent = largest_connected_land_component()
    tiles = {}
    for pos in continent.keys():
      tiles[pos] = TileType.LAND
    if continent.keys().size() > minimum_land_ratio * map_width * map_width:
      generated_map = tiles
      return
  assert(generated_map.keys().size() > 0, "Failed to generate terrain")

@export var repel_iterations: int = 10
@export var repel_strength: float = 1.0

func _repel_points(points: Array[Vector2i]) -> Array[Vector2i]:
  var repelled_points = points.duplicate()

  for _iter in range(repel_iterations):
    var forces = []
    forces.resize(points_of_interest.size())

    # Calculate repulsion forces
    for i in range(repelled_points.size()):
      forces[i] = Vector2.ZERO
      for j in range(repelled_points.size()):
        if i == j:
          continue

        var diff = Vector2(repelled_points[i] - repelled_points[j])
        var dist = diff.length()
        if dist < 0.0001:
          diff = Vector2(randf_range(-1,1), randf_range(-1,1))
          dist = diff.length()

        forces[i] += diff.normalized() * repel_strength / (dist * dist)

    # Apply forces
    for i in range(repelled_points.size()):
      var new_pos = repelled_points[i] + Vector2i(forces[i])
      # Keep points on land
      if generated_map.has(new_pos):
        repelled_points[i] = new_pos

  return repelled_points

func generate_points_of_interest() -> void:
  points_of_interest.clear()
  for _i in range(points_of_interest_count):
    var random_pos = generated_map.keys().pick_random()
    points_of_interest.append(random_pos)

  points_of_interest = _repel_points(points_of_interest)

var edges: Array[Dictionary] = []

func generate_roads() -> void:
    roads.clear()
    edges.clear()

    var points_v2 = points_of_interest.map(func(p): return Vector2(p))

    var delaunay = Geometry2D.triangulate_delaunay(points_v2)
    if delaunay.is_empty():
        return

    # First collect all edges with their weights
    for i in range(0, delaunay.size(), 3):
        var p1 = Vector2i(points_v2[delaunay[i]])
        var p2 = Vector2i(points_v2[delaunay[i + 1]])
        var p3 = Vector2i(points_v2[delaunay[i + 2]])

        for pair in [[p1, p2], [p2, p3], [p3, p1]]:
            var distance = Vector2(pair[0] - pair[1]).length()
            edges.append({"from": pair[0], "to": pair[1], "weight": distance})
            edges.append({"from": pair[1], "to": pair[0], "weight": distance})

    # Sort edges by weight for Kruskal's algorithm
    edges.sort_custom(func(a, b): return a["weight"] < b["weight"])

    for edge in edges:
        var from = edge["from"]
        var to = edge["to"]
        if not roads.has(from):
            roads[from] = []
        if not to in roads[from]:
            roads[from].append(to)
        if not roads.has(to):
            roads[to] = []
        if not from in roads[to]:
            roads[to].append(from)
            roads[edge["to"]].append(edge["from"])
    var mst = minimum_spanning_roads()

    print("total nodes in MST: ", mst.size())

    for edge in edges:
      if edge["weight"] > max_road_length:
        roads[edge["from"]].erase(edge["to"])
        roads[edge["to"]].erase(edge["from"])

    # Re-add MST edges
    for edge in mst:
      if not roads.has(edge["from"]):
        roads[edge["from"]] = []
      if not edge["to"] in roads[edge["from"]]:
        roads[edge["from"]].append(edge["to"])
      if not roads.has(edge["to"]):
        roads[edge["to"]] = []
      if not edge["from"] in roads[edge["to"]]:
        roads[edge["to"]].append(edge["from"])

func find_set(parent, x):
  if parent[x] != x:
    parent[x] = find_set(parent, parent[x])
  return parent[x]

func union_sets(parent, x, y):
  parent[find_set(parent, x)] = find_set(parent, y)

func minimum_spanning_roads() -> Array:
    var mst = []
    var parent = {}

    # Initialize disjoint sets
    for edge in edges:
        parent[edge["from"]] = edge["from"]
        parent[edge["to"]] = edge["to"]

    # Process edges in ascending order of weight
    for edge in edges:
        var from_root = find_set(parent, edge["from"])
        var to_root = find_set(parent, edge["to"])

        # If adding this edge doesn't create a cycle
        if from_root != to_root:
            mst.append(edge)
            union_sets(parent, edge["from"], edge["to"])

    return mst

func generate_map() -> void:
  generate_terrain()
  generate_points_of_interest()
  generate_roads()
  queue_redraw()

func largest_connected_land_component() -> Dictionary:
    var visited = {}
    var cur_component = {}
    var max_component = {}

    for pos in tiles.keys():
        if pos in visited or tiles[pos] != TileType.LAND:
            continue

        var stack = [pos]
        cur_component = {}

        while not stack.is_empty():
            var current = stack.pop_back()
            if current in visited:
                continue

            visited[current] = true
            cur_component[current] = tiles[current]
            # Check adjacent tiles (up, down, left, right)
            var neighbors = [
                Vector2i(current.x, current.y - 1),
                Vector2i(current.x, current.y + 1),
                Vector2i(current.x - 1, current.y),
                Vector2i(current.x + 1, current.y)
            ]

            for neighbor in neighbors:
                if neighbor in tiles and tiles[neighbor] == TileType.LAND and not neighbor in visited:
                    stack.push_back(neighbor)

        if cur_component.keys().size() > max_component.keys().size():
          max_component = cur_component

    return max_component
