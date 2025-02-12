extends CharacterBody3D

class_name Ring

@export var camera: Camera3D
@export var static_camera: Camera3D
var player_model_manager: PlayerModelManager
var enlarged_timer: Timer
var mouse_offset: Vector3 = Vector3.ZERO
var is_mouse_pressed: bool = false
@export var speed: float = 0.1
@export var inner_radius: float
@export var outer_radius: float
@export var enlarged_inner_radius: float
@export var enlarged_outer_radius: float
var vertical_lines: VerticalLinesContainer
var background_ring: BackgroundRing
var enlarged: bool = false
var movement_enabled: bool = false
var near_miss_time: float = 0
var is_near_missing_left: int = 0
var is_near_missing_right: int = 0
var left_emitter: GPUParticles3D
var right_emitter: GPUParticles3D
var near_miss_label: NearMissLabel
var current_line_origin: Vector3
var speedup : float = 1
signal add_coins(coins: int)
signal trigger_gameover

var bg_moving_thread: Thread
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	vertical_lines = get_tree().get_first_node_in_group("VerticalLines")
	background_ring = get_tree().get_first_node_in_group("BackgroundRing")
	player_model_manager = get_node("PlayerModelManager")
	right_emitter = $CollisionShape3D7/NearMissRight/CollisionShape3D/GPUParticles3D
	left_emitter = $CollisionShape3D8/NearMissLeft/CollisionShape3D2/GPUParticles3D3
	near_miss_label = $NearMissLabel
	set("position", Vector3.ZERO) # Replace with function body.
	enlarged_timer = get_node("EnlargedTimer")
	camera.set_speed(speed)
	
func _process(delta: float) -> void:
	#camera.global_position.z = global_position.z + 3.8
	if(movement_enabled):
		var dropPlane  = Plane(Vector3(0, 0, 1), 0)
		var position3D = dropPlane.intersects_ray(
								 static_camera.project_ray_origin(get_viewport().get_mouse_position()),
								 static_camera.project_ray_normal(get_viewport().get_mouse_position()))
		update_position(position3D)
		vertical_lines.update_position(global_position)
		background_ring.update_position(global_position)
		
	if (is_near_missing_left > 0 or is_near_missing_right > 0) and movement_enabled:
		near_miss_time += delta
		GlobalVariables.AudioManagerInstance.play_near_miss()
	else:
		if !movement_enabled:
			GlobalVariables.AudioManagerInstance.stop_near_miss()
			near_miss_time = 0
		if near_miss_time >= 2:
			var coins = int((near_miss_time+0.5)*1.7)
			near_miss_label.set_text(str(coins))
			near_miss_label.show_label()
			add_coins.emit(coins)
		near_miss_time = 0
		GlobalVariables.AudioManagerInstance.stop_near_miss()
		
	
	
func enlarge():
	if enlarged:
		return
	enlarged = true
	
	var model = get_node("Model") as Node3D
	var torus: MeshInstance3D = model.get_node("Torus")
	var mesh: TorusMesh
	if torus != null:
		mesh = torus.mesh
	$AnimationPlayer.play("enlarge")
	
	var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_ELASTIC)
	if torus != null:
		tw.tween_property(mesh, "inner_radius", enlarged_inner_radius, 1)
		tw.tween_property(mesh, "outer_radius", enlarged_outer_radius, 1)
	else:
		tw.tween_property(model,"scale",Vector3(1.8,1.8,1.8),1)
	enlarged_timer.start()
	$ShrinkWarningTimer.start()
func shrink():
	enlarged = false
	var model = get_node("Model") as Node3D
	var torus: MeshInstance3D = model.get_node("Torus")
	var mesh: TorusMesh
	if torus != null:
		mesh = torus.mesh
	$AnimationPlayer.play("shrink")
	var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_ELASTIC)
	if torus != null:
		tw.tween_property(mesh, "inner_radius", 0.25, 1)
		tw.tween_property(mesh, "outer_radius", 0.195, 1)
	else:
		tw.tween_property(model,"scale",Vector3(1,1,1),1)
		
	
func shrink_warning():
	if !enlarged:
		return
	var model = get_node("Model") as Node3D
	var torus: MeshInstance3D = model.get_node("Torus")
	var mesh: TorusMesh
	if torus != null:
		mesh = torus.mesh
		
	var tw = create_tween().set_parallel(false).set_trans(Tween.TRANS_EXPO)
	if torus != null:
		tw.tween_property(mesh, "inner_radius", 0.3, 0.15)
		tw.tween_property(mesh, "inner_radius", enlarged_inner_radius, 0.15)
		tw.tween_interval(1.6)
		tw.tween_property(mesh, "inner_radius", 0.3, 0.3)
		tw.tween_property(mesh, "inner_radius", enlarged_inner_radius, 0.3)
	
	
func update_position(mouse_position: Vector3) -> Vector3:
	if(!movement_enabled):
		return Vector3.ZERO
	# Update is_mouse_pressed based on the left mouse button state.
	is_mouse_pressed = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

	if is_mouse_pressed:
		# If the mouse was just pressed, calculate the offset.
		if mouse_offset == Vector3.ZERO:
			mouse_offset = position - mouse_position
		
		# Target position is the mouse position with the stored offset.
		var target_position = mouse_position + mouse_offset
		target_position = Vector3(target_position.x,target_position.y,global_position.z-speed*5)
		var distance = target_position.distance_to(position)
		#print(str(speedup))
		var x_axis_speed = speed * distance * speedup
		var direction: Vector3 = (target_position - position).normalized()
		direction = Vector3(direction.x*x_axis_speed*10,direction.y,direction.z)
		velocity = (direction * x_axis_speed )
		move_and_slide()
		
		#position = Vector3(position.x, 0, camera.position.z - 3.9)
	else:
		# Reset the offset when the mouse is not pressed.
		reset_offset()
		var target_position = Vector3(global_position.x,0,global_position.z-speed*5)
		var distance = target_position.distance_to(position)
		var z_axis_speed = speed * distance * speedup
		var direction = (target_position - position).normalized() #z is the only thing that has value
		velocity = (direction * z_axis_speed)
		move_and_slide()
 
	return position

	
func reset_position(origin: Vector3 = Vector3.ZERO) -> void:
	disable_collisions()
	shrink()
	reset_offset()
	var tw = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	var target_pos: Vector3
	if origin == Vector3.INF:
		camera.reset_position(position.z)
		target_pos = Vector3(0, position.y, position.z)
	else:
		camera.reset_position(origin.z)
		target_pos = Vector3(origin.x, origin.y, origin.z)
	
	tw.tween_property(self, "position", target_pos, 1)
	await tw.finished

func ride_power_up(endpoints: Array):
	enlarge()
	movement_enabled = false
	var tw = create_tween().set_parallel(false).set_trans(Tween.TRANS_LINEAR)
	var count = endpoints.size()
	for endpoint in endpoints:
		if(endpoint.z>global_position.z):
			continue
		if count == 1:
			print("easing")
			tw.tween_callback(shrink)
			tw.tween_property(self,"global_position",endpoint,2.2)
			break
		tw.tween_property(self,"global_position",endpoint,0.7)
		count -= 1
	tw.tween_callback(func():movement_enabled=true)
	
func reset_offset():
	mouse_offset = Vector3.ZERO
	
func play_start_animation() -> void:
	$AnimationPlayer.set_current_animation("playing")

func _on_enlarged_timer_timeout() -> void:
	shrink() # Replace with function body.
	
func enable_collisions() -> void:
	set_deferred("collision_layer", 1)
	$CentralRail.set_deferred("monitorable",true)
	$CentralRail.set_deferred("monitoring",true)
	
func disable_collisions() -> void:
	$CentralRail.set_deferred("monitorable",false)
	$CentralRail.set_deferred("monitoring",false)
	
	set_deferred("collision_layer", 0)

func _on_shrink_warning_timer_timeout() -> void:
	shrink_warning()

func enable_movement():
	movement_enabled = true
	
func disable_movement():
	movement_enabled = false
	reset_offset()
	GlobalVariables.AudioManagerInstance.stop_near_miss()
	check_near_miss_emit()


func _on_near_miss_left_area_entered(_area: Area3D) -> void:
	is_near_missing_left += 1
	check_near_miss_emit()

func _on_near_miss_left_area_exited(_area: Area3D) -> void:
	is_near_missing_left -= 1
	check_near_miss_emit()
	

func _on_near_miss_right_area_entered(_area: Area3D) -> void:
	is_near_missing_right += 1
	check_near_miss_emit()
	

func _on_near_miss_right_area_exited(_area: Area3D) -> void:
	is_near_missing_right -= 1
	check_near_miss_emit()
	
	
func check_near_miss_emit() -> void:
	
		
	if is_near_missing_left > 0:
		left_emitter.emitting = true
	else:
		left_emitter.emitting = false
		
	if is_near_missing_right > 0:
		right_emitter.emitting = true
	else:
		right_emitter.emitting = false
		
	if !movement_enabled:
		left_emitter.emitting = false
		right_emitter.emitting = false


func _on_central_rail_exited_line() -> void:
	trigger_gameover.emit()
	
func get_current_line_origin() -> Vector3:
	return current_line_origin


func _on_central_rail_new_line(pos: Vector3) -> void:
	current_line_origin = pos

func increment_speedup(_speed: float) -> void:
	speedup += _speed
	print(str(speedup))
	camera.set_speed(speed*speedup)
func reset_speed() -> void:
	speedup = 1
	camera.set_speed(speed*speedup)
func get_speedup() -> float:
	return speedup
