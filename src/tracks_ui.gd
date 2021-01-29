extends MarginContainer

var view_pos:Vector2 = Vector2.ZERO
var view_offset:Vector2 = Vector2(30.0, 0)
var view_scale:float = 60.0 # the duration that the view represents in seconds

const tracks_thickness:float = 20.0
const v_separation:float = 10.0

func _ready():
	Global.audio_manager.connect("tracks_updated", self, "_on_tracks_updated")
	Global.audio_manager.connect("cursor_updated", self, "_on_cursor_updated")

func _draw():
	var tracks = Global.get_tracks()
	for i in range(tracks.size()):
		if tracks[i].is_defined():
			_draw_track(tracks[i].start_t_stamp, tracks[i].end_t_stamp, i)
		elif tracks[i].is_start_set:
			# dynamic size when recording:
			_draw_track(tracks[i].start_t_stamp, Global.get_cursor_pos(), i)
	
	_draw_focused_track(Global.get_focused_track_index())
	
	_draw_cursor(Global.get_cursor_pos())
	print("draw")

func _adapt_view_to_cursor(cursor_pos:float):
	view_pos.x = -cursor_pos * get_time_to_pos_scale()

func _on_tracks_updated():
	update()

func _on_cursor_updated():
	_adapt_view_to_cursor(Global.get_cursor_pos())
	update()

func get_time_to_pos_scale()->float:
	return rect_size.x / 60.0

func _draw_track(start_t_stamp:float, end_t_stamp:float, i:int)->FuncRef:
	var time_to_pos_scale = get_time_to_pos_scale()
	var track_start_pos = time_to_pos_scale * start_t_stamp
	var track_end_pos = time_to_pos_scale * end_t_stamp
	var rect_pos = view_pos + Vector2(
		track_start_pos,
		i * tracks_thickness +  i * v_separation)
	return draw_rect(
		Rect2(
			rect_pos + time_to_pos_scale * view_offset,
			Vector2(track_end_pos - track_start_pos, tracks_thickness)),
		Color.aquamarine,
		true)

func _draw_cursor(cursor_pos:float)->FuncRef:
	#cursor_pos = Global.map(cursor_pos, 0, cursor_pos, 0, 60)
	#var pos_percent = (cursor_pos / 60.0)-int(cursor_pos / 60.0)
	var time_to_pos_scale = get_time_to_pos_scale()
	var line_pos_up = view_offset * time_to_pos_scale
	var line_pos_down = line_pos_up + Vector2(0, 60)
	return draw_line(line_pos_up, line_pos_down, Color.black, 1.0)	

func _draw_focused_track(focused_track_index:int)->FuncRef:
	var time_to_pos_scale = get_time_to_pos_scale()
	var track_start_pos = 0.0
	var track_end_pos = time_to_pos_scale * view_scale
	var thickness_pos = focused_track_index * tracks_thickness
	var separation_pos = focused_track_index * v_separation
	var rect_pos = view_pos + Vector2(
		track_start_pos,
		thickness_pos +  separation_pos)
	return draw_rect(
		Rect2(
			rect_pos + time_to_pos_scale * view_offset,
			Vector2(track_end_pos - track_start_pos, tracks_thickness)),
		Color.blueviolet,
		false)
	
