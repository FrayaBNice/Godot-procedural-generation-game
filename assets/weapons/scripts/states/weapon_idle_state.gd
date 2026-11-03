extends WeaponState

func _on_idle_state_processing(delta: float) -> void:
	if not weapon_controller:
		return
	
	if Input.is_action_just_pressed("shoot") and weapon_controller.can_fire():
		weapon_controller.weapon_state_chart.send_event("onFiring")
	
	if not weapon_controller.has_ammo():
		weapon_controller.weapon_state_chart.send_event("onEmpty")
