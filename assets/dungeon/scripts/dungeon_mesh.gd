@tool
extends Node3D

@export var grid_map_path : NodePath
@onready var grid_map : GridMap = get_node(grid_map_path)

@export var start : bool = false : set = set_start
func set_start(val : bool) -> void:
	if Engine.is_editor_hint():
		create_dungeon()

var dungeon_cell_scene : PackedScene = preload("res://scenes/dungeon/dungeon_cell.tscn")

var directions : Dictionary = {
	"up" : Vector3i.FORWARD,
	"down" : Vector3i.BACK,
	"left" : Vector3i.LEFT,
	"right" : Vector3i.RIGHT
}


func handle_none(cell : Node3D, dir : String):
	cell.call("remove_door_" + dir)

func handle_00(cell : Node3D, dir : String):
	cell.call("remove_wall_" + dir)
	cell.call("remove_door_" + dir)
func handle_01(cell : Node3D, dir : String):
	cell.call("remove_door_" + dir)
func handle_02(cell : Node3D, dir : String):
	cell.call("remove_wall_" + dir)
	cell.call("remove_door_" + dir)
func handle_10(cell : Node3D, dir : String):
	cell.call("remove_door_" + dir)
func handle_11(cell : Node3D, dir : String):
	cell.call("remove_wall_" + dir)
	cell.call("remove_door_" + dir)
func handle_12(cell : Node3D, dir : String):
	cell.call("remove_wall_" + dir)
	cell.call("remove_door_" + dir)
func handle_20(cell : Node3D, dir : String):
	cell.call("remove_wall_" + dir)
	cell.call("remove_door_" + dir)
func handle_21(cell : Node3D, dir : String):
	cell.call("remove_wall_" + dir)
func handle_22(cell : Node3D, dir : String):
	cell.call("remove_wall_" + dir)
	cell.call("remove_door_" + dir)


func create_dungeon():
	for c in get_children():
		remove_child(c)
		c.queue_free()
	
	for cell in grid_map.get_used_cells():
		var cell_index : int = grid_map.get_cell_item(cell)
		if cell_index <= 2 \
		&& cell_index >= 0:
			var dungeon_cell : Node3D = dungeon_cell_scene.instantiate()
			dungeon_cell.position = Vector3(cell) * 2 + Vector3(1, 0, 1)
			add_child(dungeon_cell)
			dungeon_cell.set_owner(owner)
			for i in 4:
				var cell_n : Vector3i = cell + directions.values()[i]
				var cell_n_index : int = grid_map.get_cell_item(cell_n)
				if cell_n_index == -1 \
				|| cell_n_index == 3:
					handle_none(dungeon_cell, directions.keys()[i])
				else:
					var key : String = str(cell_index) + str(cell_n_index)
					call("handle_" + key, dungeon_cell, directions.keys()[i])
