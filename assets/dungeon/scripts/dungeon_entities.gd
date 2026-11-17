@tool
class_name DungeonEntities extends Node3D

@export var grid_map_path : NodePath
@onready var grid_map : GridMap = get_node(grid_map_path)

@export var start : bool = false : set = set_start
func set_start(_val : bool) -> void:
	create_entities()

var enities_cell_scene : PackedScene = preload("res://scenes/dungeon/dungeon_entities_cell.tscn")


func handle_none(_cell : Node3D):
	pass

func handle_0(cell : Node3D):
	cell.call("remove_pistol_ammo")
	cell.call("remove_shot_ammo")
	cell.call("remove_chain_ammo")
func handle_1(cell : Node3D):
	cell.call("remove_enemy")
	cell.call("remove_shot_ammo")
	cell.call("remove_chain_ammo")
func handle_2(cell : Node3D):
	cell.call("remove_pistol_ammo")
	cell.call("remove_enemy")
	cell.call("remove_chain_ammo")
func handle_3(cell : Node3D):
	cell.call("remove_pistol_ammo")
	cell.call("remove_shot_ammo")
	cell.call("remove_enemy")


func create_entities():
	for c in get_children():
		remove_child(c)
		c.queue_free()
		
	for cell in grid_map.get_used_cells():
		var cell_index : int = grid_map.get_cell_item(cell)
		if cell_index <= 7 \
		and cell_index >= 4:
			var dungeon_entities_cell : Node3D = enities_cell_scene.instantiate()
			dungeon_entities_cell.position = Vector3(cell) * 2 + Vector3(1, 0, 1)
			add_child(dungeon_entities_cell)
			dungeon_entities_cell.set_owner(owner)
			var key : String = str(cell_index - 4)
			call("handle_" + key, dungeon_entities_cell)
