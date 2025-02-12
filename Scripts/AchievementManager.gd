extends Node
class_name  AchievementManager

var player_stats: PlayerStats
var gpgs_controller: GPGSController
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_stats = get_tree().get_first_node_in_group("PlayerStats")
func set_gpgs_controller(gpgs: GPGSController):
	gpgs_controller = gpgs

func check_high_score_achievement():
	var score = player_stats.get_score()
	if score >= 100:
		gpgs_controller.unlock_achievement("achievementBeginnersLuck")
	if score >= 500:
		gpgs_controller.unlock_achievement("achievementProPlayer")
	if score >= 1000:
		gpgs_controller.unlock_achievement("achievementHighFlyer")
	if score >= 5000:
		gpgs_controller.unlock_achievement("achievementScoreMaster")

func check_coins_achievement():
	var coins = player_stats.get_coins()
	if coins >= 50:
		gpgs_controller.unlock_achievement("achievementCoinCollector")
	if coins >= 500:
		gpgs_controller.unlock_achievement("achievementTreasureHunter")
	if coins >= 1000:
		gpgs_controller.unlock_achievement("achievementRingRiches")
		
func check_time_achievement(time: float):
	if time >= 60:
		gpgs_controller.unlock_achievement("achievementSteadyHands")
	if time >= 300:
		gpgs_controller.unlock_achievement("achievementEndurancePro")
	if time >= 600:
		gpgs_controller.unlock_achievement("achievementMarathoner")
	if time >= 1200:
		gpgs_controller.unlock_achievement("achievementLegendaryReflexes")
		
func check_power_up_achievement(powerups: int):
	if powerups > 0:
		gpgs_controller.unlock_achievement("achievementFirstBoost")
	if powerups >= 10:
		gpgs_controller.unlock_achievement("achievementPowerupAddict")
	if powerups >= 30:
		gpgs_controller.unlock_achievement("achievementStrategist")
