extends Node
class_name AdManager


var rewarded_ad : RewardedAd
var rewarded_ad_load_callback : RewardedAdLoadCallback
var rewarded_ad_play_on_load: bool = false
var on_user_earned_reward_listener :OnUserEarnedRewardListener
var player_stats : PlayerStats
var noads: bool = false
var video_ad: InterstitialAd
var video_ad_load_callback: InterstitialAdLoadCallback
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_stats = (get_tree().get_first_node_in_group("PlayerStats") as PlayerStats)
	noads = player_stats.getAdStatus()
	if noads:
		return
	rewarded_ad_load_callback = RewardedAdLoadCallback.new()
	rewarded_ad_load_callback.on_ad_failed_to_load = on_rewarded_ad_failed_to_load
	rewarded_ad_load_callback.on_ad_loaded = on_rewarded_ad_loaded # Replace with function body.
	on_user_earned_reward_listener = OnUserEarnedRewardListener.new()
	on_user_earned_reward_listener.on_user_earned_reward = rewarded
	video_ad_load_callback = InterstitialAdLoadCallback.new()
	video_ad_load_callback.on_ad_loaded = on_interstitial_ad_loaded
	video_ad_load_callback.on_ad_failed_to_load = on_interstitial_ad_failed_to_load
	
	
	
func load_rewarded_ad() -> void:
	var unit_id : String
	if OS.get_name() == "Android":
		unit_id = "ca-app-pub-3940256099942544/5224354917"
	elif OS.get_name() == "iOS":
		unit_id = "ca-app-pub-3940256099942544/1712485313"
	RewardedAdLoader.new().load(unit_id, AdRequest.new(), rewarded_ad_load_callback)

func rewarded(_rewarded_item : RewardedItem):
	load_rewarded_ad()
	
	(get_tree().get_first_node_in_group("PlayerStats") as PlayerStats).add_stars(5)
	(get_tree().get_first_node_in_group("MessageManager") as MessageManager).push_message(1,"Free Stars!","Added 5 stars, watch more ads to get more!")

func load_interstitial_ad() -> void:
	noads = player_stats.getAdStatus()
	
	if noads:
		return
	var unit_id: String
	if OS.get_name() == "Android":
		unit_id = "ca-app-pub-3940256099942544/1033173712"
	elif OS.get_name() == "iOS":
		unit_id = "ca-app-pub-3940256099942544/1033173712"
	InterstitialAdLoader.new().load(unit_id, AdRequest.new(), video_ad_load_callback)
	
func on_rewarded_ad_failed_to_load(adError : LoadAdError) -> void:
	print(adError.message)
	
func on_rewarded_ad_loaded(_rewarded_ad : RewardedAd) -> void:
	self.rewarded_ad = _rewarded_ad
	if rewarded_ad_play_on_load:
		play_rewarded_ad()
		rewarded_ad_play_on_load = false

func on_interstitial_ad_loaded(_interstitial_ad: InterstitialAd) -> void:
	self.video_ad = _interstitial_ad
	
func on_interstitial_ad_failed_to_load(adError: LoadAdError) -> void:
	print(adError.message)

func _on_texture_button_pressed() -> void:
	pass

func play_rewarded_ad() -> void:
	rewarded_ad_play_on_load = true
	if rewarded_ad:
		rewarded_ad.show(on_user_earned_reward_listener)
		#rewarded_ad_play_on_load = false
	else:
		load_rewarded_ad()

func play_video_ad() -> void:
	noads = player_stats.getAdStatus()
	
	if noads:
		return
	if video_ad:
		print("playing video ads while noads:"+str(noads))
		video_ad.show()
	else:
		load_interstitial_ad()
		if video_ad:
			video_ad.show()
		
