@tool
extends Node3D

@onready var grid_map: GridMap = $GridMap

@export var start : bool = false : set = set_start
func set_start(val : bool) -> void:
	if Engine.is_editor_hint():
		generate()

@export var border_size : int = 20 : set = set_border_size
func set_border_size(val : int) -> void:
	border_size = val
	if Engine.is_editor_hint():
		visualize_border()

@export_multiline var custom_seed : String = "" : set = set_seed
func set_seed(val : String) -> void:
	custom_seed = val
	seed(val.hash())

@export_range(0, 1) var survival_chance : float = 0.25
@export var room_amount : int = 4
@export var room_margin : int = 1
@export var room_recursion : int = 15
@export var min_room_size : int = 2
@export var max_room_size : int = 4

var room_tiles : Array[PackedVector3Array] = []
var room_positions : PackedVector3Array = []

func visualize_border():
	grid_map.clear()
	
	for i in range(-1, border_size + 1):
		grid_map.set_cell_item(Vector3i(i, 0, -1), 3)
		grid_map.set_cell_item(Vector3i(i, 0, border_size), 3)
		grid_map.set_cell_item(Vector3i(border_size, 0, i), 3)
		grid_map.set_cell_item(Vector3i(-1, 0, i), 3)


func generate():
	room_tiles.clear()
	room_positions.clear()
	if custom_seed : set_seed(custom_seed)
	
	visualize_border()
	
	for i in room_amount:
		make_room(room_recursion)
	
	var packed_v2_pos : PackedVector2Array = []
	var del_graph : AStar2D = AStar2D.new()
	var mst_graph : AStar2D = AStar2D.new()
	
	for p in room_positions:
		packed_v2_pos.append(Vector2(p.x, p.z))
		del_graph.add_point(del_graph.get_available_point_id(),Vector2(p.x, p.z))
		mst_graph.add_point(mst_graph.get_available_point_id(),Vector2(p.x, p.z))
	
	var delaunay : Array = Array(Geometry2D.triangulate_delaunay(packed_v2_pos))
	
	for i in delaunay.size() / 3:
		var point1 : int = delaunay.pop_front()
		var point2 : int = delaunay.pop_front()
		var point3 : int = delaunay.pop_front()
		del_graph.connect_points(point1, point2)
		del_graph.connect_points(point2, point3)
		del_graph.connect_points(point1, point3)
	
	var visited_points : PackedFloat32Array = []
	visited_points.append(randi() % room_positions.size())
	while visited_points.size() != mst_graph.get_point_count():
		var possible_connections : Array[PackedInt32Array] = []
		for vp in visited_points:
			for c in del_graph.get_point_connections(vp):
				if ! visited_points.has(c):
					var connection : PackedInt32Array = [vp, c]
					possible_connections.append(connection)
					
		var rand_connection : PackedInt32Array = possible_connections.pick_random()
		for pc in possible_connections:
			if packed_v2_pos[pc[0]].distance_squared_to(packed_v2_pos[pc[1]]) <\
			packed_v2_pos[rand_connection[0]].distance_squared_to(packed_v2_pos[rand_connection[1]]):
				rand_connection = pc
			
		visited_points.append(rand_connection[1])
		mst_graph.connect_points(rand_connection[0], rand_connection[1])
		del_graph.disconnect_points(rand_connection[0], rand_connection[1])
	
	var hallway_graph : AStar2D = mst_graph
		
	for p in del_graph.get_point_ids():
		for c in del_graph.get_point_connections(p):
			if c > p:
				var kill : float = randf()
				if survival_chance > kill:
					hallway_graph.connect_points(p, c)
						
		create_hallways(hallway_graph)


func make_room(recursion : int):
	if ! recursion > 0:
		return
		
	var width : int = randi_range(min_room_size, max_room_size)
	var height : int = randi_range(min_room_size, max_room_size)
	
	var starting_pos : Vector3i
	starting_pos.x = randi_range(0, border_size - width)
	starting_pos.z = randi_range(0, border_size - height)
	
	for r in range(-room_margin, height + room_margin):
		for c in range(-room_margin, width + room_margin):
			var pos : Vector3i = starting_pos + Vector3i(c, 0, r)
			if grid_map.get_cell_item(pos) == 0:
				make_room(recursion-1)
				return
	
	var room : PackedVector3Array = []
	for r in height:
		for c in width:
			var pos : Vector3i = starting_pos + Vector3i(c, 0, r)
			grid_map.set_cell_item(pos, 0)
			room.append(pos)
	room_tiles.append(room)
	
	var avg_x : float = starting_pos.x + (float(width) / 2)
	var avg_z : float = starting_pos.z + (float(height) / 2)
	var pos : Vector3 = Vector3(avg_x, 0, avg_z)
	room_positions.append(pos)

func create_hallways(hallway_graph : AStar2D):
	var hallways : Array[PackedVector3Array] = []
	
	for p in hallway_graph.get_point_ids():
		for c in hallway_graph.get_point_connections(p):
			if c > p:
				var room_from : PackedVector3Array = room_tiles[p]
				var room_to : PackedVector3Array = room_tiles[c]
				var tile_from : Vector3 = room_from[0]
				var tile_to : Vector3 = room_to[0]
				for t in room_from:
					if t.distance_squared_to(room_positions[c]) <\
					tile_from.distance_squared_to(room_positions[c]):
						tile_from = t
				for t in room_to:
					if t.distance_squared_to(room_positions[p]) <\
					tile_to.distance_squared_to(room_positions[p]):
						tile_to = t
				var hallway : PackedVector3Array = [tile_from, tile_to]
				hallways.append(hallway)
				grid_map.set_cell_item(tile_from,2)
				grid_map.set_cell_item(tile_to,2)
	
	var astar : AStarGrid2D = AStarGrid2D.new()
	astar.size = Vector2i.ONE * border_size
	astar.update()
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	
	for t in grid_map.get_used_cells_by_item(0):
		astar.set_point_solid(Vector2i(t.x, t.z))
	
	for h in hallways:
		var pos_from : Vector2i = Vector2i(h[0].x, h[0].z)
		var pos_to : Vector2i = Vector2i(h[1].x, h[1].z)
		var hall : PackedVector2Array = astar.get_point_path(pos_from, pos_to)
		
		for t in hall:
			var pos : Vector3i = Vector3i(t.x, 0, t.y)
			if grid_map.get_cell_item(pos) < 0:
				grid_map.set_cell_item(pos, 1)
