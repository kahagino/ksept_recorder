extends MarginContainer

enum BTYPE {PLAY_PAUSE, STOP, RECORD, ADD, DELETE}

export(String) var buttonText = ""
export(BTYPE) var buttonType # defined by user in the editor


func _ready():
	get_node("Button").text = buttonText


func _on_Button_pressed():
	match buttonType:
		BTYPE.PLAY_PAUSE:
			Global.audio_manager.play_pause()
		BTYPE.STOP:
			Global.audio_manager.stop()
		BTYPE.RECORD:
			Global.audio_manager.record()
		BTYPE.ADD:
			Global.audio_manager.add_track()
		BTYPE.DELETE:
			Global.audio_manager.remove_track()
		_:
			print("button type ", buttonType, " of button with text: ", buttonText, " doesn't match any known type")
