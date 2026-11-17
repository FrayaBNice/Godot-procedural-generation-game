class_name GameManager extends Node

@export var dungeon_generation : DungeonGeneration


func _ready() -> void:
	add_to_group("game_manager")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("dev_quit"):
		get_tree().quit()
	if event.is_action_pressed("dev_reload"):
		get_tree().reload_current_scene()


func _load_new_floor() -> void:
	
	dungeon_generation.generate()
	#dungeon_generation.visualize_elevators()
