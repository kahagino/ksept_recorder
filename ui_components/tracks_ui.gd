extends MarginContainer

var view_pos:Vector2 = Vector2.ZERO
var view_offset:Vector2 = Vector2(30.0, 3)
var view_scale:float = 60.0 # the duration that the view represents in seconds

const tracks_thickness:float = 10.0
const v_separation:float = 5.0

func _ready()->void:
	Global.audio_manager.connect("tracks_updated", self, "_on_tracks_updated")
	Global.audio_manager.connect("cursor_updated", self, "_on_cursor_updated")

func _draw()->void:
	_draw_time_scale()
	_draw_focused_track(Global.get_focused_track_index())
	
	var tracks = Global.get_tracks()
	for i in range(tracks.size()):
		_draw_track_circle(i) # to indicate that a track is available
		if tracks[i].is_defined():
			_draw_track(tracks[i].start_t_stamp, tracks[i].end_t_stamp, i)
		elif tracks[i].is_start_set:
			# dynamic size when recording:
			_draw_track(tracks[i].start_t_stamp, Global.get_cursor_pos(), i)
	
	_draw_cursor()

func _adapt_view_to_cursor(cursor_pos:float)->void:
	view_pos.x = -cursor_pos * get_time_to_pos_scale()

func _on_tracks_updated()->void:
	update()

func _on_cursor_updated()->void:
	var cursor_pos:float = Global.get_cursor_pos()
	_adapt_view_to_cursor(cursor_pos)
	update()

func get_time_to_pos_scale()->float:
	return rect_size.x / 60.0

func _draw_track(start_t_stamp:float, end_t_stamp:float, i:int)->FuncRef:
	print("draw track")
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

func _draw_track_circle(i:int)->FuncRef:
	var rect_pos = get_time_to_pos_scale() * view_offset + view_pos + Vector2(
		-10,
		i * tracks_thickness +  i * v_separation + tracks_thickness/2)
	return draw_circle(rect_pos, 4.0, Color("#2f3542"))

func _draw_cursor()->FuncRef:
	var time_to_pos_scale = get_time_to_pos_scale()
	var line_pos_up = view_offset * time_to_pos_scale + Vector2(0, -10)
	var line_pos_down = line_pos_up + Vector2(0, 60)
	return draw_line(line_pos_up, line_pos_down, Color.red, 1.0)	

func _draw_focused_track(focused_track_index:int)->FuncRef:
	var time_to_pos_scale = get_time_to_pos_scale()
	var track_start_pos = -10*get_time_to_pos_scale()
	var track_end_pos = time_to_pos_scale * view_scale +10*get_time_to_pos_scale()
	var thickness_pos = focused_track_index * tracks_thickness
	var separation_pos = focused_track_index * v_separation
	var rect_pos = Vector2(
		track_start_pos,
		thickness_pos + separation_pos + view_offset.y * time_to_pos_scale)
	return draw_rect(
		Rect2(
			rect_pos,
			Vector2(track_end_pos - track_start_pos, tracks_thickness)),
		Color("#dfe4ea"),
		true)
		
func _draw_time_scale()->void:
	var time_to_pose_scale = get_time_to_pos_scale()
	# 5 secs lines
	for i in range(0, 61, 5):
		var line_pos_x = view_pos.x + i * time_to_pose_scale
		var line_offset = view_offset * time_to_pose_scale
		draw_line(
			line_offset + Vector2(line_pos_x, 0),
			line_offset + Vector2(line_pos_x, -10),
			Color.black
			)
	# 1 sec lines
	for i in range(0, 61, 1):
		var line_pos_x = view_pos.x + i * time_to_pose_scale
		var line_offset = view_offset * time_to_pose_scale
		draw_line(
			line_offset + Vector2(line_pos_x, 0),
			line_offset + Vector2(line_pos_x, -5),
			Color.black
			)
