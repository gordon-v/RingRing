extends Node

func _ready():
	
	var gpu_name = RenderingServer.get_video_adapter_name().to_lower()
	
	if gpu_name.find("mali") != -1 or gpu_name.find("powervr") != -1:
		set_resolution(0.5)  # Low-end GPU (Mali, PowerVR)
	elif gpu_name.find("adreno") != -1 and gpu_name.find("600") != -1:
		set_resolution(0.85) # Mid-range GPU (Adreno 600+)
	else:
		set_resolution(1.0)  # High-end GPU (Default full resolution)
		
		
		
func set_resolution(scale: float):
	get_viewport().set("rendering/scaling_3d/scale",scale)
