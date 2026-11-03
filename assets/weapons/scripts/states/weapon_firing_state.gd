extends WeaponState


func _on_firing_state_entered() -> void:
	if not weapon_controller:
		return
		
	weapon_controller.fire_weapon()

func _on_firing_state_physics_processing(delta: float) -> void:
	if not weapon_controller:
		return
	
	if not weapon_controller.has_ammo():
		weapon_controller.weapon_state_chart.send_event("onEmpty")
		return
	
	if weapon_controller.current_weapon.is_automatic:
		if Input.is_action_pressed("shoot"):
			if weapon_controller.can_fire():
				weapon_controller.fire_weapon()
		else:
			weapon_controller.weapon_state_chart.send_event("onIdle")
	else:
		weapon_controller.weapon_state_chart.send_event("onIdle")
