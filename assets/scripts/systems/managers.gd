extends Node

var weapon_manager : WeaponManager
var game_manager : GameManager


func _ready() -> void:
	call_deferred("find_managers")


func find_managers() -> void:
	weapon_manager = get_tree().get_first_node_in_group("weapon_manager")
	game_manager = get_tree().get_first_node_in_group("game_manager")
