extends Node
class_name AudioManager

func play_coin_collect() -> void:
	$CoinAudioStreamPlayer.play()
	
func play_powerup_collect() -> void:
	$PowerUpAudioStreamPlayer.play()
	
func play_near_miss() -> void:
	if $NearMissAudioStreamPlayer.playing:
		return
	else:
		print_debug("started")
		$NearMissAudioStreamPlayer.play()

func stop_near_miss() -> void:
	if $NearMissAudioStreamPlayer.playing:
		print_debug("stopped")
		$NearMissAudioStreamPlayer.stop()

func play_lose() -> void:
	$LoseAudioStreamPlayer.play()
	
func play_button() -> void:
	$ButtonAudioStreamPlayer.play()
