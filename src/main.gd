extends Control

func _ready()->void:
	#load_app_theme()	
	var err = OS.request_permissions() # for READ/WRITE to external storage

#func load_app_theme()->void:
#	theme = Global.app_theme
