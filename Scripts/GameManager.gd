extends Node
class_name GameManager

@export var menu_canvas: CanvasLayer
@export var menu: Menu
@export var game_over_menu: GameOverMenu
@export var score_label: Score
@export var coins_label: Label
@export var label: Label3D
@export var ring: Ring
@export var gpgs_controller: GPGSController
@export var player_model_manage: PlayerModelManager
@export var player_camera: PlayerCamera
@export var static_camera: Camera3D
@export var line_manager: LineManager
@export var vertical_lines: VerticalLinesContainer
@export var background_ring: BackgroundRing
@export var ad_manager: AdManager
@export var add_score_timer: Timer
@export var speed: float = 0.2
@export var game_started = false
@export var player_stats: PlayerStats 
var achievement_manager: AchievementManager

var _collisions = 0
var _collision_cooldown: bool = false
var game_time_elapsed = 0

var desired_ring_speed: float

var resetting_game = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MobileAds.initialize()
	achievement_manager = get_node("AchievementManager")
	achievement_manager.set_gpgs_controller(gpgs_controller)
	update_collisions()
	_add_score(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(Input.is_action_just_released("space")):
		start_game()
	if(Input.is_action_just_pressed("B")):
		ring.enlarge()
	if(Input.is_action_just_pressed("space")):
		ride_power_up()
	if(Input.is_action_just_pressed("left_arrow")):
		(get_tree().get_first_node_in_group("MessageManager") as MessageManager).push_message(2,"title","success")
		
	if(game_started):
		game_time_elapsed += delta

func update_collisions() -> void:
	_collisions+=1
	if(not game_started):
		return
	if(not _collision_cooldown and _collisions > 0):
		player_camera.super_shake()
	else:
		player_camera.shake()
		Input.vibrate_handheld(100,1)
		
func _on_line_manager_collided_with_player() -> void:
	if(not _collision_cooldown):
		_collision_cooldown = true
	var ccTimer = get_node("CollisionCooldownTimer") as Timer
	ccTimer.start()
	update_collisions()
	stop_game()
	
func start_game() -> void:
	ad_manager.load_interstitial_ad()
	game_time_elapsed = 0
	game_started = true
	ring.enable_movement()
	player_camera.set_moving(true)
	await menu.disable()

func stop_game() -> void:
	if(resetting_game):
		return
	resetting_game = true
	GlobalVariables.AudioManagerInstance.play_lose()
	(get_tree().get_first_node_in_group("PlayerStats") as PlayerStats).save_data()
	game_started = false
	ring.disable_movement()
	ring.disable_collisions()
	player_camera.set_moving(false)
	await menu.enable()
	menu.enable_buttons()
	achievement_manager.check_coins_achievement()
	achievement_manager.check_high_score_achievement()
	achievement_manager.check_time_achievement(game_time_elapsed)
	
	var score = player_stats.get_score()
	var high_score = player_stats.get_high_score()
	if(score > high_score):
		high_score = score
		player_stats.set_high_score(high_score)
		gpgs_controller.add_highscore_to_leaderboard(score)
		menu.show_highscore(high_score)
	else:
		menu.show_gameover()
	background_ring.reset_rotation()
	#game_started = false
	#await menu.enable()
	await game_over_menu.enable()
	ad_manager.play_video_ad()
	resetting_game = false

func continue_game() -> void:
	await ring.reset_position(ring.get_current_line_origin())
	ring.enable_collisions()
	desired_ring_speed = ring.get_speedup()
	ring.reset_speed()
	$SpeedUpTimer.wait_time = 0.05
	
func reset_game() -> void:
	line_manager.reset(ring.position)
	await ring.reset_position(Vector3.INF)
	ring.enable_collisions()
	ring.reset_speed()
	$SpeedUpTimer.wait_time=1
	desired_ring_speed=-1
	speed = 0.2

func _on_speed_up_timer_timeout() -> void:
	if(game_started):
		if(desired_ring_speed != -1 and desired_ring_speed<=ring.get_speedup()):
			$SpeedUpTimer.wait_time=1
		speedup()
	
func _add_score(score_to_add: int = 1) -> void:
	player_stats._add_score(score_to_add)
	
func speedup():
	print("speed up")
	background_ring.increase_rotation_speed()
	
	speed*=1.15
	if add_score_timer.wait_time >= 0:
		add_score_timer.set("wait_time",add_score_timer.wait_time-0.001)	
	print_debug("speed: ",speed," wait_time :", add_score_timer.wait_time)
	ring.increment_speedup(0.017)



func _on_add_score_timer_timeout() -> void:
	if(game_started):
		_add_score(1)
	

func _on_start_button_pressed() -> void:
	print_debug("button pressed")
	menu.disable_buttons()
	start_game() # Replace with function body.
 # Replace with function body.


func _on_collision_cooldown_timer_timeout() -> void:
	_collision_cooldown = false
	_collisions = 0 


func _on_gpgs_controller_open_sign_in_menu() -> void:
	if(get_tree().get_first_node_in_group("SignInMessageMenu") == null):
		var sign_in_message_menu = (load("res://Scenes/GUI/SignInMessageMenu.tscn") as PackedScene).instantiate() as SignInMessageMenu
		menu_canvas.add_child(sign_in_message_menu)
		sign_in_message_menu.sign_in_menu_sign_in_button_pressed.connect(gpgs_controller._on_sign_in_google_play_button_pressed)


func _on_gpgs_controller_close_sign_in_menu() -> void:
	var sign_in_message_menu: SignInMessageMenu = get_tree().get_first_node_in_group("SignInMessageMenu")
	if(sign_in_message_menu != null):
		sign_in_message_menu.delete()

func _on_restart_pressed() -> void:
	print("restart pressed")
	_add_score(-1)#reset score to 0
	menu.show_title()
	reset_game()
	


func _on_line_manager_coin_collected() -> void:
	var coins = player_stats.collect_coin()
	coins_label.text = ":  "+str(coins)
	


func _on_line_manager_power_up_collected() -> void:
	ring.enlarge()

func ride_power_up() -> void:
	var lines = line_manager.get_node("Lines").get_children()
	var endpoints: Array = []
	for line in lines:
		var line_endpoint = (line as Line3DSegment).get_endpoint()
		endpoints.append(line_endpoint)
		
	ring.ride_power_up(endpoints)


func _on_ring_add_coins(_coins: int) -> void:
	var coins = player_stats.ring_add_coins(_coins)
	coins_label.text = ":  "+str(coins)


func _on_ring_trigger_gameover() -> void:
	stop_game()


func _on_game_over_menu_continue_pressed() -> void:
	continue_game()
