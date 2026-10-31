class_name Dungeon extends Node3D

@export var dungeon_generation : DungeonGeneration

func _ready() -> void:
	dungeon_generation.set_rooms(true)
	dungeon_generation.set_connect(true)
