extends StaticBody3D
 

func _on_health_component_died() -> void:
	print(name, "destroyed")
	queue_free()
