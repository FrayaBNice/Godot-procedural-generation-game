class_name Elevator extends Node3D

@onready var triggerable : TriggerableComponent = $TriggerableComponent


func on_triggered() -> void:
	Managers.game_manager._load_new_floor()
	print("activated")


func get_target_name() -> String:
	return triggerable.targetname if triggerable else ""


func on_trigger(player) -> void:
	Managers.game_manager._load_new_floor()
	print("activated")
