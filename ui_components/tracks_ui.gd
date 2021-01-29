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
	_draw_focused_track(Global.get_focused_track_index())
	
	var tracks = Global.get_tracks()
	for i in range(tracks.size()):
		var track_color = tracks[i].color
		_draw_track_circle(i, track_color) # to indicate that a track is available
		if tracks[i].is_defined():
			_draw_track(tracks[i].start_t_stamp, tracks[i].end_t_stamp, i, track_color)
		elif tracks[i].is_start_set:
			# dynamic size when recording:
			_draw_track(tracks[i].start_t_stamp, Global.get_cursor_pos(), i, track_color)
	
	_draw_time_scale()
	
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

func _draw_track(start_t_stamp:float, end_t_stamp:float, i:int, track_color:Color)->FuncRef:
	var time_to_pos_scale = get_time_to_pos_scale()
	var track_start_pos = time_to_pos_scale * start_t_stamp
	var track_end_pos = time_to_pos_scale * end_t_stamp
	var rect_pos = view_pos + Vector2(
		track_start_pos,
		i * tracks_thickness +  (i+1) * v_separation)
	return draw_rect(
		Rect2(
			rect_pos + time_to_pos_scale * view_offset,
			Vector2(track_end_pos - track_start_pos, tracks_thickness)),
		track_color,
		true)

func _draw_track_circle(i:int, track_color, cust_offset:Vector2 = Vector2.ZERO)->FuncRef:
	var rect_pos = get_time_to_pos_scale() * view_offset + view_pos + Vector2(
		-10,
		i * tracks_thickness +  (i+1) * v_separation + tracks_thickness/2)
	return draw_circle(rect_pos, 3.0, track_color)

func _draw_cursor()->FuncRef:
	var time_to_pos_scale = get_time_to_pos_scale()
	var line_pos_up = view_offset * time_to_pos_scale + Vector2(0, -10)
	var line_pos_down = line_pos_up + Vector2(
		0,
		rect_size.y - view_offset.y * get_time_to_pos_scale()
		)
	return draw_line(line_pos_up, line_pos_down, Color.red, 1.0)	

func _draw_focused_track(focused_track_index:int)->FuncRef:
	var time_to_pos_scale = get_time_to_pos_scale()
	var track_start_pos = -10*get_time_to_pos_scale()
	var track_end_pos = time_to_pos_scale * view_scale +10*get_time_to_pos_scale()
	var thickness_pos = focused_track_index * tracks_thickness
	var separation_pos = (focused_track_index+1) * v_separation
	var rect_pos = Vector2(
		track_start_pos,
		thickness_pos + separation_pos + view_offset.y * time_to_pos_scale -2)
	return draw_rect(
		Rect2(
			rect_pos,
			Vector2(track_end_pos - track_start_pos, tracks_thickness +4)),
		Color("#f1f2f6"),
		true)
		
func _draw_time_scale()->void:
	var time_to_pose_scale = get_time_to_pos_scale()
	var cursor_pos_int = int(Global.get_cursor_pos())
	
	# the lines will draw dynamically but keep a maxium interval size
	# of view_scale
	# user has the impression that the number of lines is infinite
	var low_range = -int(view_scale/4) + (cursor_pos_int)
	var top_range = int(view_scale/4) + cursor_pos_int
	if cursor_pos_int <= view_scale/4:
		low_range = 0
	
	var line_pos_x = view_pos.x
	var line_offset = view_offset * time_to_pose_scale 
	draw_line(
			line_offset + Vector2(line_pos_x, rect_size.y - view_offset.y * time_to_pose_scale),
			line_offset + Vector2(line_pos_x, -15),
			Color.black
			)
	
	# 5 secs line
	for i in range((low_range +4)/5, (top_range+4)/5, 1):
		line_pos_x = view_pos.x + 5 * i * time_to_pose_scale
		line_offset = view_offset * time_to_pose_scale
		draw_line(
			line_offset + Vector2(line_pos_x, 0),
			line_offset + Vector2(line_pos_x, -8),
			Color.black
			)
	# 1 sec lines
	for i in range(low_range, top_range, 1):
		line_pos_x = view_pos.x + i * time_to_pose_scale
		line_offset = view_offset * time_to_pose_scale
		draw_line(
			line_offset + Vector2(line_pos_x, -3),
			line_offset + Vector2(line_pos_x, -5),
			Color.black
			)
