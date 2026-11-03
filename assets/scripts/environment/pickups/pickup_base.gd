class_name PickupBase extends Area3D


func _ready() -> void:
	body_entered.connect(_on_pickup)


func _on_pickup(body : Node3D) -> void:
	if not body is PlayerController:
		return
	
	if can_pickup(body):
		apply_pickup(body)
		queue_free()


func can_pickup(player : PlayerController) -> bool:
	return true

func apply_pickup(player : PlayerController) -> void:
	pass
