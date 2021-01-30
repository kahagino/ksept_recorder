extends MarginContainer

enum BTYPE {PLAY_PAUSE, STOP, RECORD, ADD, DELETE}

export(String) var button_text:String = ""
export(BTYPE) var button_type # defined by user in the editor

var center

func _ready()->void:
	#get_node("Button").text = button_text
	center = rect_size/2
	Global.audio_manager.connect("audio_play", self, "update")
	Global.audio_manager.connect("audio_pause", self, "update")

func _draw():
	match button_type:
		BTYPE.PLAY_PAUSE:
			_draw_play(center, Global.audio_manager.is_playing())
		BTYPE.STOP:
			_draw_stop(center)
		BTYPE.RECORD:
			_draw_record(center)
		BTYPE.ADD:
			_draw_add(center)
		BTYPE.DELETE:
			_draw_remove(center)
			
func _draw_stop(pos_center:Vector2)->FuncRef:
	var pos = pos_center + Vector2(-10, -10)
	var end = Vector2(20, 20)
	return draw_rect(Rect2(pos, end), Color(0, 0, 0, 0.7), true)

func _draw_record(pos_center:Vector2)->FuncRef:
	return draw_circle(pos_center, 11, Color(1, 0, 0, 0.7))

func _draw_play(pos_center:Vector2, is_playing:bool)->void:
	if is_playing:
		draw_line(pos_center + Vector2(-6, -10), pos_center + Vector2(-6, 10), Color(0, 0, 0, 0.7), 10.0)
		draw_line(pos_center + Vector2(6, -10), pos_center + Vector2(6, 10), Color(0, 0, 0, 0.7), 10.0)
	else:
		draw_polygon([
			pos_center + Vector2(15, 0),
			pos_center + Vector2(15, 0).rotated(2*PI/3),
			pos_center + Vector2(15, 0).rotated(4*PI/3)
			], PoolColorArray([Color(0.1, 1, 0.3, 0.7)]), PoolVector2Array()
		)


func _draw_add(pos_center:Vector2)->void:
	draw_line(pos_center + Vector2(10, 0), pos_center + Vector2(-10, 0), Color(0, 0, 0, 0.7), 4.0)
	draw_line(pos_center + Vector2(0, 10), pos_center + Vector2(0, -10), Color(0, 0, 0, 0.7), 4.0)

func _draw_remove(pos_center:Vector2)->void:
	draw_line(pos_center + Vector2(10, 0), pos_center + Vector2(-10, 0), Color(0, 0, 0, 0.7), 4.0)

func _on_Button_pressed()->void:
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
