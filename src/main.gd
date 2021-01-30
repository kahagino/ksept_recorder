extends Control

func _ready()->void:
	load_app_theme()
	
	var err = OS.request_permissions() # for READ/WRITE to external storage
#	OS.alert("OS.request_permissions() returned " + str(err))
	
	# DEBUG ANDROID
#	var file2Check = File.new()
#	var doFileExists = file2Check.file_exists(Global.downloadDirPath + "exported.wav")
#	file2Check.close()
#	if doFileExists:
#		OS.alert('file exists')
#	else:
#		OS.alert("file doesn't exists")

func load_app_theme()->void:
	theme = Global.app_theme
