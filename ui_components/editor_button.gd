extends MarginContainer

enum BTYPE {PLAY_PAUSE, STOP, RECORD, ADD, DELETE}

export(String) var buttonText = ""
export(BTYPE) var buttonType # defined by user in the editor


func _ready():
	get_node("Button").text = buttonText


func _on_Button_pressed():
	match buttonType:
		BTYPE.PLAY_PAUSE:
			Global.audioManager.play_pause()
		BTYPE.STOP:
			Global.audioManager.stop()
		BTYPE.RECORD:
			Global.audioManager.record()
		BTYPE.ADD:
			Global.audioManager.add_track()
		BTYPE.DELETE:
			Global.audioManager.remove_track()
		_:
			print("button type ", buttonType, " of button with text: ", buttonText, " doesn't match any known type")
