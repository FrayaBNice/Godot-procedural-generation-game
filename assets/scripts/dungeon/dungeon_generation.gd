@tool
class_name DungeonGeneration extends CSGCombiner3D

@export var create_rooms : bool = false : set = set_rooms
@export var create_hallways : bool = false : set = set_connect
@export var delete : bool = false : set = set_delete
@export_category("Dungeon Settings")
@export var size : int = 40
@export var room_amount : int = 10
@export var min_room_size : int = 10
@export var max_room_size : int = 20
@export var mesh_resolution : int = 8
@export var material : StandardMaterial3D

var dungeon : Array
var connections : Array
var dungeon_connections : Array


func set_rooms(val : bool) -> void:
	generate_rooms()

func set_connect(val : bool) -> void:
	connect_rooms()

func set_delete(val : bool) -> void:
	delete_dungeon()


func generate_rooms():
	print("rooms")
	for i in range(room_amount):
		var rand_position = Vector3(randi_range(-size, size), 0, randi_range(-size, size))
		
		if can_place(rand_position):
			var box = CSGMesh3D.new()
			box.mesh = BoxMesh.new()
			box.scale = Vector3(randi_range(min_room_size, max_room_size), 3, randi_range(min_room_size, max_room_size))
			box.mesh.subdivide_width = box.scale.x / mesh_resolution
			box.mesh.subdivide_depth = box.scale.z / mesh_resolution
			box.mesh.subdivide_height = box.scale.y / mesh_resolution
			box.position = rand_position
			box.material = material
			box.flip_faces = true
			
			add_child(box)
			dungeon.append(box)
			dungeon_connections.append(box)

func generate_hallways(room1, room2):
	print("hallways")
	var direction1 = room2.position.x - room1.position.x
	var direction2 = room2.position.z - room1.position.z
	
	var box1 = CSGMesh3D.new()
	box1.mesh = BoxMesh.new()
	box1.scale = Vector3(abs(direction1) + 3, 3, 3)
	box1.mesh.subdivide_width = box1.scale.x / mesh_resolution
	box1.mesh.subdivide_depth = box1.scale.z / mesh_resolution
	box1.mesh.subdivide_height = box1.scale.y / mesh_resolution
	box1.position = room1.position + Vector3(direction1 / 2, 0, 0)
	box1.material = material
	box1.flip_faces = true
	
	add_child(box1)
	connections.append(box1)
	
	var box2 = CSGMesh3D.new()
	box2.mesh = BoxMesh.new()
	box2.scale = Vector3(3, 3, abs(direction2) + 3)
	box2.mesh.subdivide_width = box2.scale.x / mesh_resolution
	box2.mesh.subdivide_depth = box2.scale.z / mesh_resolution
	box2.mesh.subdivide_height = box2.scale.y / mesh_resolution
	box2.position = room2.position - Vector3(0, 0, direction2 / 2)
	box2.material = material
	box2.flip_faces = true
	
	add_child(box2)
	connections.append(box2)

func delete_dungeon():
	print("delete")
	for i in dungeon:
		i.queue_free()
	dungeon.clear()
	
	for i in connections:
		i.queue_free()
	connections.clear()
	
	for i in dungeon_connections:
		i.queue_free()
	dungeon_connections.clear()


func can_place(position):
	if not dungeon:
		return true
	
	else:
		for d in dungeon:
			var distance = position.distance_to(d.position)
			
			if distance < max_room_size:
				return false
		return true

func connect_rooms():
	while dungeon_connections.size() > 2:
		var room1 = dungeon_connections[randi_range(0,dungeon_connections.size()-1)]
		var room2 = dungeon_connections[randi_range(0,dungeon_connections.size()-1)]
		
		while room1 == room2:
			room2 = dungeon_connections[randi_range(0,dungeon_connections.size()-1)]
		
		generate_hallways(room1, room2)
		dungeon_connections.erase(room1)
	
	if dungeon_connections.size() == 2:
		var room1 = dungeon_connections[0]
		var room2 = dungeon_connections[1]
		generate_hallways(room1, room2)
