extends VBoxContainer

class_name Menu

@export var ring_selection_menu: RingSelectionMenu
var enable_tween
var disable_tween
var title: Title
var buy_stars_menu: PackedScene = preload("res://Scenes/BuyGemsMenu.tscn")
var start_button: Button
var ads_disabled: bool = false

signal can_close_game_over_menu

func _ready() -> void:
	start_button = get_node("StartButton")
	title = (get_node("Title") as Title)
	title._show_game_name()

func enable() -> void:
	if disable_tween and disable_tween.is_running():
		await disable_tween.finished
	enable_tween = create_tween()
	enable_tween.tween_callback(_toggle_visibility.bind(true))
	enable_tween.set_trans(Tween.TRANS_EXPO)
	enable_tween.tween_property(self,"modulate",Color.WHITE,1)

func disable() -> void:
	if enable_tween and enable_tween.is_running():
		await enable_tween.finished
	disable_tween = create_tween()
	disable_tween.set_trans(Tween.TRANS_EXPO)
	disable_tween.tween_property(self,"modulate",Color.TRANSPARENT,0.6)
	disable_tween.tween_callback(_toggle_visibility.bind(false))
	
func _toggle_visibility(_visible: bool) -> void:
	set("visible", _visible)

func _on_ring_selection_menu_button_pressed() -> void:
	ring_selection_menu.appear() # Replace with function body.

func show_gameover() -> void:
	await title._show_gameover()
	can_close_game_over_menu.emit()
	
func show_highscore(highscore: int) -> void:
	await title._show_highscore(highscore)
	can_close_game_over_menu.emit()
	
func show_title() -> void:
	await title._show_game_name()
	can_close_game_over_menu.emit()
	


func _on_buy_stars_button_pressed() -> void:
	
	var buy_menu_instance = buy_stars_menu.instantiate()
	get_parent().add_child(buy_menu_instance)

func disable_buttons() -> void:
	$HBoxContainer/AchievementsButton.disabled = true
	$HBoxContainer/NoAdsButton.disabled = true
	$HBoxContainer/BuyStarsButton.disabled = true
	$HBoxContainer/ShowLeaderboardButton.disabled = true
	$HBoxContainer/SignInGooglePlayButton.disabled = true
	$HBoxContainer/RingSelectionMenuButton.disabled = true
	$HBoxContainer/AchievementsButton.visible = false
	$HBoxContainer/NoAdsButton.visible = false
	$HBoxContainer/BuyStarsButton.visible = false
	$HBoxContainer/ShowLeaderboardButton.visible = false
	$HBoxContainer/SignInGooglePlayButton.visible = false
	$HBoxContainer/RingSelectionMenuButton.visible = false
	
func enable_buttons() -> void:
	$HBoxContainer/AchievementsButton.disabled = false
	$HBoxContainer/BuyStarsButton.disabled = false
	$HBoxContainer/ShowLeaderboardButton.disabled = false
	$HBoxContainer/SignInGooglePlayButton.disabled = false
	$HBoxContainer/RingSelectionMenuButton.disabled = false
	$HBoxContainer/AchievementsButton.visible = true
	$HBoxContainer/BuyStarsButton.visible = true
	$HBoxContainer/ShowLeaderboardButton.visible = true
	$HBoxContainer/SignInGooglePlayButton.visible = true
	$HBoxContainer/RingSelectionMenuButton.visible = true
	
	if !ads_disabled:
		$HBoxContainer/NoAdsButton.disabled = false
		$HBoxContainer/NoAdsButton.visible = true
	


func _on_no_ads_button_pressed() -> void:
	var billing = get_tree().get_first_node_in_group("BillingController") as BillingController
	billing.purchaseNoAds()

func disable_ads_button() -> void:
	$HBoxContainer/NoAdsButton.disabled = true
	$HBoxContainer/NoAdsButton.visible = false


func _on_player_stats_ads_off() -> void:
	ads_disabled = true
	disable_ads_button() # Replace with function body.


func _on_ring_selection_menu_enabled() -> void:
	disable_buttons()

func _on_ring_selection_menu_disabled() -> void:
	enable_buttons()
