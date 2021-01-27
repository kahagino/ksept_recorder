extends MarginContainer

enum BTYPE {PLAY_PAUSE, STOP, RECORD, ADD, DELETE}

export(String) var button_text = ""
export(BTYPE) var button_type # defined by user in the editor


func _ready():
	get_node("Button").text = button_text


func _on_Button_pressed():
	match button_type:
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
			print("button type ", button_type, " of button with text: ", button_text, " doesn't match any known type")
