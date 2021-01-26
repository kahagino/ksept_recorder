extends Control

func _ready():
	var err = OS.request_permissions() # for READ/WRITE to external storage
	OS.alert("OS.request_permissions() returned " + str(err))
	
	# DEBUG ANDROID
	var file2Check = File.new()
	var doFileExists = file2Check.file_exists(Global.downloadDirPath + "exported.wav")
	file2Check.close()
	if doFileExists:
		OS.alert('file exists')
	else:
		OS.alert("file doesn't exists")
