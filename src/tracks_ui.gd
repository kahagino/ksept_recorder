extends MarginContainer

var view_pos:Vector2 = Vector2.ZERO
var view_scale:float = 60.0 # the duration that the view represents in seconds

const tracks_thickness:float = 20.0
const v_separation:float = 10.0

func _ready():
	Global.audio_manager.connect("track_added", self, "_on_track_added")
	Global.audio_manager.connect("track_removed", self, "_on_track_removed")

func _draw():
	var tracks = Global.get_tracks()
	for i in range(tracks.size()):
		_draw_track(tracks[i].start_t_stamp, tracks[i].end_t_stamp, i)
	
	_draw_cursor(Global.get_cursor_pos())

func _input(event):
	# debug inputs
	if event.is_action_pressed("ui_up"):
		view_pos.x += 1.0
	elif event.is_action_pressed("ui_down"):
		view_pos.x -= 1.0
	
	update()

func _on_track_added():
	update()

func _on_track_removed():
	if get_child_count() > 0:
		# remove last child
		get_child(get_child_count() -1).queue_free()

func get_time_to_pos_scale()->float:
	return rect_size.x / 60.0

func _draw_track(start_t_stamp:float, end_t_stamp:float, i:int)->FuncRef:
	var time_to_pos_scale = get_time_to_pos_scale()
	var track_start_pos = time_to_pos_scale * start_t_stamp
	var track_end_pos = time_to_pos_scale * end_t_stamp
	var rect_pos = view_pos + Vector2(track_start_pos, i * tracks_thickness +  i * v_separation)
	return draw_rect(
		Rect2(
			rect_pos,
			Vector2(track_end_pos - track_start_pos, tracks_thickness)),
		Color.aquamarine,
		true)

func _draw_cursor(cursor_pos:float)->FuncRef:
	var time_to_pos_scale = get_time_to_pos_scale()
	var line_pos_up = view_pos + Vector2(cursor_pos, 0)
	line_pos_up.x *= time_to_pos_scale
	var line_pos_down = line_pos_up + Vector2(0, 60)
	return draw_line(line_pos_up, line_pos_down, Color.black, 1.0)	
