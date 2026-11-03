class_name SimpleEnemy extends Enemy

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D
@onready var state_chart : StateChart = $StateChart
@onready var health_component : HealthComponent = $HealthComponent
@onready var mesh_instance : MeshInstance3D = $MeshInstance3D

@export var follow_speed : float = 3.0
@export var melee_range : float = 2.0

var target : Node3D

func _ready() -> void:
	super._ready()
	
	target = get_tree().get_first_node_in_group("player")
	
	health_component.died.connect(_on_died)
	nav_agent.velocity_computed.connect(_on_velocity_computed)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 20.0 * delta
	
	move_and_slide()


func on_triggered() -> void:
	state_chart.send_event("toFollow")


func _on_died() -> void:
	queue_free()


func _on_velocity_computed(safe_velocity : Vector3) -> void:
	velocity.x = safe_velocity.x
	velocity.z = safe_velocity.z


func _on_follow_state_physics_processing(delta: float) -> void:
	if not target:
		return
	
	nav_agent.target_position = target.global_position
	
	var distance = global_position.distance_to(target.global_position)
	if distance <= melee_range:
		state_chart.send_event("toAttack")
		return
	
	if nav_agent.is_navigation_finished():
		nav_agent.velocity = Vector3.ZERO
		return
	
	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized()
	
	nav_agent.velocity = direction * follow_speed
	
	if direction.length() > 0.01:
		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, 5.0 * delta)


func _on_detection_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		on_triggered()

func attack() -> void:
	velocity = Vector3.ZERO
	nav_agent.velocity = Vector3.ZERO
	
	if target:
		var direction = (target.global_position - global_position).normalized()
		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = target_rotation
	
	print("attacking")
	mesh_instance.get_active_material(0).albedo_color = Color(0.0, 1.0, 0.0, 1.0)
	await get_tree().create_timer(0.5).timeout
	mesh_instance.get_active_material(0).albedo_color = Color(1.0, 0.0, 0.0, 1.0)
	await get_tree().create_timer(0.1).timeout
	
	if target:
		var distance = global_position.distance_to(target.global_position)
		if distance <= melee_range:
			state_chart.send_event("toAttack")
		else:
			state_chart.send_event("toFollow")


func _on_attack_state_entered() -> void:
	attack()
