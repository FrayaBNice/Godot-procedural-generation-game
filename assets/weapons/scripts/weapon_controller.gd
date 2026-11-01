class_name WeaponController extends Node

@export var player : CharacterBody3D
@export var camera : CameraEffects
@export var weapon_model_parent : Node3D
@export var weapon_state_chart : StateChart

@export_group("Strafe Tilt")
@export var strafe_tilt_scale : float = 0.3
@export var strafe_tilt_max : float = 0.08
@export var strafe_tilt_stiffness : float = 80.0
@export var strafe_tilt_damping : float = 10.0

@export_group("Weapon Bob")
@export var weapon_bob : bool = true
@export var bob_amplitude : Vector2 = Vector2(0.02, 0.012)
@export var bob_max_speed : float = 10.0
@export var bob_stiffness : float = 60.0
@export var bob_damping : float = 10.0

var current_weapon : Weapon
var current_weapon_model : Node3D
var can_fire_next : bool = true
var fire_rate_timer : float = 0.0

var base_weapon_position : Vector3
var base_weapon_rotation : Vector3

var _strafe_tilt : float = 0.0
var _strafe_tilt_vel : float = 0.0

var _bob_x : float = 0.0
var _bob_y : float = 0.0
var _bob_x_velocity : float = 0.0
var _bob_y_velocity : float = 0.0

func _ready() -> void:
	if current_weapon:
		spawn_weapon_model()


func _process(delta: float) -> void:
	if fire_rate_timer > 0:
		fire_rate_timer -= delta
		if fire_rate_timer <= 0:
			can_fire_next = true
	
	_apply_offsets(delta)


func spawn_weapon_model():
	if current_weapon_model:
		current_weapon_model.queue_free()
	
	if current_weapon.weapon_model:
		current_weapon_model = current_weapon.weapon_model.instantiate()
		weapon_model_parent.add_child(current_weapon_model)
		current_weapon_model.position = current_weapon.weapon_position
		
		base_weapon_position = current_weapon.weapon_position
		base_weapon_rotation = Vector3.ZERO
		
		_bob_x = 0.0
		_bob_y = 0.0
		_bob_x_velocity = 0.0
		_bob_y_velocity = 0.0

func can_fire() -> bool:
	var weapon_data = Managers.weapon_manager.weapons[Managers.weapon_manager.current_slot]
	return weapon_data.ammo > 0 and can_fire_next


func fire_weapon() -> void:
	if can_fire():
		Managers.weapon_manager.use_ammo(Managers.weapon_manager.current_slot)
		
		can_fire_next = false
		fire_rate_timer = 1.0 / current_weapon.fire_rate
		
		if current_weapon.is_hitscan:
			_perform_hitscan()
		else:
			_spawn_projectile()


func _perform_hitscan() -> void:
	if not camera:
		print("No camera assigned!")
		return
	
	var space_state = camera.get_world_3d().direct_space_state
	var from = camera.global_position
	var accuracy_spread = (100 - current_weapon.accuracy) / 1000.0
	
	for i in current_weapon.pellet_count:
		var forward = -camera.global_transform.basis.z
		var accuracy_x = randf_range(-accuracy_spread, accuracy_spread)
		var accuracy_y = randf_range(-accuracy_spread, accuracy_spread)
		var direction = forward + Vector3(accuracy_x, accuracy_y, 0) * camera.global_transform.basis
		
		if current_weapon.pellet_count > 1:
			var spread_x = randf_range(-current_weapon.spread_angle, current_weapon.spread_angle)
			var spread_y = randf_range(-current_weapon.spread_angle, current_weapon.spread_angle)
			direction += Vector3(spread_x, spread_y / 2, 0) * camera.global_transform.basis
		
		var to = from + direction * current_weapon.range
		
		var query = PhysicsRayQueryParameters3D.create(from, to)
		var result = space_state.intersect_ray(query)
		
		if result:
			print("Hit: ", result.collider.name, " at ", result.position)
			_spawn_impact_marker(result.position)
			_apply_damage_to_target(result.collider)


func _spawn_impact_marker(position : Vector3) -> void:
	var marker = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(0.1, 0.1, 0.1)
	marker.mesh = box
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.RED
	marker.set_surface_override_material(0, material)
	
	get_tree().current_scene.add_child(marker)
	marker.global_position = position
	
	get_tree().create_timer(2.0).timeout.connect(marker.queue_free)


func _spawn_projectile() -> void:
	if not current_weapon.projectile_scene:
		print("No projectile scene assigned!")
		return
	
	if not camera:
		print("No camera assigned!")
		return
	
	var projectile = current_weapon.projectile_scene.instantiate() as Rocket
	get_tree().current_scene.add_child(projectile)
	
	projectile.global_position = camera.global_position
	
	var forward = -camera.global_transform.basis.z
	var velocity = forward * current_weapon.projectile_speed
	
	projectile.setup(velocity, current_weapon.damage)


func switch_weapon(weapon_data : WeaponData) -> void:
	current_weapon = weapon_data.weapon
	
	if current_weapon_model:
		current_weapon_model.queue_free()
	
	spawn_weapon_model()
	
	weapon_state_chart.send_event("onIdle")
	
	print(current_weapon.weapon_name)


func has_ammo() -> bool:
	var weapon_data = Managers.weapon_manager.weapons[Managers.weapon_manager.current_slot]
	return weapon_data.ammo > 0


func _apply_damage_to_target(target : Node3D) -> void:
	var health_component = target.get_node_or_null("HealthComponent")
	
	if health_component and health_component.has_method("take_damage"):
		health_component.take_damage(current_weapon.damage, owner)


func _update_strafe_tilt(delta : float) -> float:
	if not player or not camera:
		return 0.0
	
	var local_velocity = camera.global_transform.basis.inverse() * player.velocity
	
	var xz = Vector2(local_velocity.x, local_velocity.z)
	var xz_speed = xz.length()
	
	var lateral_fraction = abs(xz.x) / xz_speed if xz_speed > 0.1 else 0.0
	
	var tilt_target = clamp(
		-local_velocity.x * lateral_fraction * strafe_tilt_scale, -strafe_tilt_max, strafe_tilt_max
	)
	
	var result = SpringUtil.apply(
		_strafe_tilt,
		_strafe_tilt_vel,
		tilt_target,
		strafe_tilt_stiffness,
		strafe_tilt_damping,
		delta
	)
	_strafe_tilt = result.x
	_strafe_tilt_vel = result.y
	
	return _strafe_tilt


func _update_bob(delta : float) -> Vector3:
	if not current_weapon_model or not camera or not player:
		return Vector3.ZERO
	
	var phase := camera.get_bob_phase()
	var speed := Vector2(player.velocity.x, player.velocity.z).length()
	
	var target_x := 0.0
	var target_y := 0.0
	
	if speed > 0.1:
		var speed_factor = clamp(speed / bob_max_speed, 0.0, 1.0)
		var angle := phase * TAU
		
		target_x = sin(angle) * bob_amplitude.x * speed_factor
		target_y = sin(angle * 2.0) * bob_amplitude.y * speed_factor
	
	var result_x := SpringUtil.apply(_bob_x, _bob_x_velocity, target_x, bob_stiffness, bob_damping, delta)
	_bob_x = result_x.x
	_bob_x_velocity = result_x.y
	
	var result_y := SpringUtil.apply(_bob_y, _bob_y_velocity, target_y, bob_stiffness, bob_damping, delta)
	_bob_y = result_y.x
	_bob_y_velocity = result_y.y
	
	return Vector3(_bob_x, _bob_y, 0.0)


func _apply_offsets(delta) -> void:
	var bob_offset = _update_bob(delta) if weapon_bob else Vector3.ZERO
	
	var strafe_tilt = Vector3(0.0, _update_strafe_tilt(delta) / 2 + PI, _update_strafe_tilt(delta))
	
	current_weapon_model.position = base_weapon_position + bob_offset
	
	current_weapon_model.rotation = base_weapon_rotation + strafe_tilt
