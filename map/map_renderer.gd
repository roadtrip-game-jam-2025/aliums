extends Node2D

class Road extends Node2D:
  var start_pos: Vector2
  var end_pos: Vector2
  var width: float = 2.0
  var color: Color = Color.GREEN
  var path_points: Array = []
  var highlighted: bool = false

  func _init(start: Vector2, end: Vector2, path: Array = []) -> void:
    start_pos = start
    end_pos = end
    path_points = path

  func _draw() -> void:
    var current_color = Color.RED if highlighted else color
    if path_points.is_empty():
      draw_line(start_pos, end_pos, current_color, width)
    else:
      for i in range(path_points.size() - 1):
        draw_line(path_points[i], path_points[i + 1], current_color, width)

  func set_highlighted(value: bool) -> void:
    highlighted = value
    queue_redraw()

class SmoothestPath:
  var astar = AStar2D.new()
  var map_generator
  var map_width: int
  const ELEVATION_WEIGHT = 2.0  # Weight factor for elevation changes

  func _init(map_gen) -> void:
    map_generator = map_gen
    map_width = map_gen.map_width
    _build_graph()

  func _build_graph() -> void:
    # Add all walkable points as nodes
    for y in range(-map_width/2, map_width/2):
      for x in range(-map_width/2, map_width/2):
        if map_generator.altitude_value(x, y) == map_generator.TileType.LAND:
          var point_id = _get_point_id(Vector2i(x, y))
          astar.add_point(point_id, Vector2(x, y))

    # Connect neighboring nodes
    for y in range(-map_width/2, map_width/2):
      for x in range(-map_width/2, map_width/2):
        if not astar.has_point(_get_point_id(Vector2i(x, y))):
          continue

        # Connect to neighbors (8-directional)
        for dx in [-1, 0, 1]:
          for dy in [-1, 0, 1]:
            if dx == 0 and dy == 0:
              continue

            var neighbor = Vector2i(x + dx, y + dy)
            if _is_valid_point(neighbor):
              var neighbor_id = _get_point_id(neighbor)
              if astar.has_point(neighbor_id):
                astar.connect_points(_get_point_id(Vector2i(x, y)), neighbor_id, true)

  func _get_point_id(pos: Vector2i) -> int:
    # Convert 2D coordinates to unique ID
    return (pos.y + map_width/2) * map_width + (pos.x + map_width/2)

  func _is_valid_point(pos: Vector2i) -> bool:
    return pos.x >= -map_width/2 and pos.x < map_width/2 and \
         pos.y >= -map_width/2 and pos.y < map_width/2

  func _compute_cost(from_pos: Vector2i, to_pos: Vector2i) -> float:
    # Base cost is the distance
    var distance_cost = from_pos.distance_to(to_pos)

    # Add elevation change cost
    var elevation_from = map_generator.get_altitude(from_pos.x, from_pos.y)
    var elevation_to = map_generator.get_altitude(to_pos.x, to_pos.y)
    var elevation_cost = abs(elevation_to - elevation_from) * ELEVATION_WEIGHT

    return distance_cost + elevation_cost

  func get_path(from_pos: Vector2i, to_pos: Vector2i) -> Array:
    var from_id = _get_point_id(from_pos)
    var to_id = _get_point_id(to_pos)

    if not astar.has_point(from_id) or not astar.has_point(to_id):
      return []

    # Update weights based on elevation
    for id in astar.get_point_ids():
      var pos = astar.get_point_position(id)
      for connection in astar.get_point_connections(id):
        var neighbor_pos = astar.get_point_position(connection)
        var cost = _compute_cost(Vector2i(pos.x, pos.y), Vector2i(neighbor_pos.x, neighbor_pos.y))
        astar.set_point_weight_scale(connection, cost)

    return astar.get_point_path(from_id, to_id)

const TILE_WIDTH = 16

@onready var tile_map: TileMapLayer = $TileMapLayer
@onready var camera: Camera2D = $Camera2D
@onready var map_gen = $MapGenerator
@export var noise: FastNoiseLite

var dragging = false
var drag_start_pos = Vector2()
var pins: Array[Node2D] = []
var roads: Array[Node2D] = []
var pin_to_roads: Dictionary = {}

var focused_pin: Node2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  $MapGenerator.generate_map()
  redraw_map()
  camera.position = to_world_coords(Vector2i.ZERO)

func to_world_coords(pos: Vector2i) -> Vector2:
  return Vector2(pos.x * TILE_WIDTH, pos.y * TILE_WIDTH) + Vector2(map_gen.map_width * TILE_WIDTH / 2.0, map_gen.map_width * TILE_WIDTH / 2.0)

func _draw() -> void:
  pass

func _on_pin_hovered(pin: Node2D) -> void:
  focused_pin = pin
  var pin_coords = pin.get_map_coordinates()
  if pin_to_roads.has(pin_coords):
    for road in pin_to_roads[pin_coords]:
      road.set_highlighted(true)

func _on_pin_unhovered(pin: Node2D) -> void:
  focused_pin = null
  var pin_coords = pin.get_map_coordinates()
  if pin_to_roads.has(pin_coords):
    for road in pin_to_roads[pin_coords]:
      road.set_highlighted(false)

func _input(event: InputEvent) -> void:
  if event is InputEventMouseButton:
    if event.button_index == MOUSE_BUTTON_LEFT:
      if event.pressed:
        dragging = true
        drag_start_pos = event.position
      else:
        dragging = false
  elif event is InputEventMouseMotion and dragging:
    camera.position -= event.relative

func _process(_delta: float) -> void:
  if Input.is_action_just_pressed("ui_up"):
    $MapGenerator.generate_map()
    redraw_map()
    camera.position = Vector2((map_gen.map_width * TILE_WIDTH) / 2.0, (map_gen.map_width * TILE_WIDTH) / 2.0)
  if Input.is_action_just_pressed("ui_scroll_up"):
    camera.zoom += Vector2(0.1, 0.1)
  if Input.is_action_just_pressed("ui_scroll_down"):
    camera.zoom -= Vector2(0.1, 0.1)

func redraw_map() -> void:
  for pin in pins:
    pin.queue_free()
  pins.clear()

  for road in roads:
    road.queue_free()
  roads.clear()

  pin_to_roads.clear()

  queue_redraw()

  noise.seed = randi()
  for ay in range(0, map_gen.map_width):
    for ax in range(0, map_gen.map_width):
      var n = 0
      var x = ax - map_gen.map_width / 2.0
      var y = ay - map_gen.map_width / 2.0
      if map_gen.altitude_value(x-0.5, y-0.5) == map_gen.TileType.LAND:
        n += 1
      if map_gen.altitude_value(x+0.5, y-0.5) == map_gen.TileType.LAND:
        n += 2
      if map_gen.altitude_value(x+0.5, y+0.5) == map_gen.TileType.LAND:
        n += 4
      if map_gen.altitude_value(x-0.5, y+0.5) == map_gen.TileType.LAND:
        n += 8
      tile_map.set_cell(Vector2i(ax, ay), 1, Vector2i(n, 0))

  for pos in map_gen.points_of_interest:
    var map_x = pos.x + map_gen.map_width / 2
    var map_y = pos.y + map_gen.map_width / 2
    var pin = load("res://map/map_pin.tscn").instantiate()
    pin.position = Vector2(map_x * TILE_WIDTH, map_y * TILE_WIDTH)
    pin.set_map_coordinates(pos)
    add_child(pin)
    pins.append(pin)
    pin.hovered.connect(_on_pin_hovered)
    pin.unhovered.connect(_on_pin_unhovered)
    pin_to_roads[pos] = []

  var pathfinder = SmoothestPath.new(map_gen)
  var seen_edges: Dictionary = {}
  for src in map_gen.roads.keys():
    for dst in map_gen.roads[src]:
      if seen_edges.has({"from": src, "to": dst}) or seen_edges.has({"from": dst, "to": src}):
        continue
      seen_edges[{"from": src, "to": dst}] = true
      var path = pathfinder.get_path(src, dst)
      var world_path = []
      for point in path:
        world_path.append(to_world_coords(Vector2i(point.x, point.y)))

      var road = Road.new(to_world_coords(src), to_world_coords(dst), world_path)
      add_child(road)
      roads.append(road)
      pin_to_roads[src].append(road)
      pin_to_roads[dst].append(road)
