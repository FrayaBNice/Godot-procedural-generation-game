class_name Weapon extends Resource

@export var weapon_name : String = "Pistol"
@export var damage : float = 25.0
@export var max_ammo : int = 12
@export var range : float = 25.0
@export var is_hitscan : bool = true
@export var weapon_model : PackedScene
@export var projectile_scene : PackedScene
@export var weapon_position : Vector3 = Vector3 (0.0, -0.2, -0.3)
