@tool
extends Node3D

@export var grid_map_path : NodePath
@onready var grid_map : GridMap = get_node(grid_map_path)

@export var start : bool = false : set = set_start
func set_start(val : bool) -> void:
	create_entities()

var enities_cell_scene : PackedScene = preload("res://scenes/dungeon/dungeon_entities_cell.tscn")

func create_entities():
	for c in get_children():
		remove_child(c)
		c.queue_free()
		
		for cell in grid_map.get_used_cells():
			var cell_index : int = grid_map.get_cell_item(cell)
			if cell_index <= 7 \
			and cell_index >= 4:
				pass
