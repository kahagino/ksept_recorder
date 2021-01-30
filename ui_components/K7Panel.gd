extends MarginContainer

export var chrono_font:DynamicFont

var center:Vector2 = rect_size / 2
enum tube_type {IN, OUT}
const tube_size:float = 40.0
var cursor_angle:float
var tape_points:PoolVector2Array

var MAX_CURSOR:float = 10.0 # max k7 ui time in seconds

enum UI_AUDIO_STATES {RECORD, PLAY, PAUSE}
var ui_audio_state = UI_AUDIO_STATES.PAUSE

func _ready():
	Global.audio_manager.connect("cursor_updated", self, "_on_cursor_updated")
	Global.audio_manager.connect("record_started", self, "_on_record_started")
	Global.audio_manager.connect("audio_play", self, "_on_audio_play")
	Global.audio_manager.connect("audio_pause", self, "_on_audio_pause")

func _draw():
	var left_tube_pos = center + Vector2(-65, -10)
	var right_tube_pos = center + Vector2(+65, -10)
	var lecture_head_pos = center + Vector2(0, 30)
	
	_draw_tube(left_tube_pos, cursor_angle, tube_type.IN)
	_draw_tube(right_tube_pos, cursor_angle + PI/4, tube_type.OUT)
	_draw_lecture_head(lecture_head_pos)
	
	_draw_tape(center, lecture_head_pos, left_tube_pos, right_tube_pos, tube_size)

	_draw_state_shape(ui_audio_state, center)

func _draw_tube(pos:Vector2, angle:float, tube_type_arg)->void:
	draw_circle(pos, 5.0, Color.black)
	draw_arc(pos, 25.0, 0, 2*PI, 32, Color.black, 2.0)
	if tube_type_arg == tube_type.IN:
		draw_arc(pos, get_tape_pos(), 0, 2*PI, 32, Color.black, 1.5)
	else:
		draw_arc(pos, tube_size - get_tape_pos(), 0, 2*PI, 32, Color.black, 1.5)
	
	var da = 2*PI / 3
	for i in range(3):
		var start_point = Vector2(10, 0).rotated(angle + i * da)
		var end_point = Vector2(20, 0).rotated(angle + i * da)
		draw_line(pos + start_point, pos + end_point, Color.black, 2.0)

func _draw_lecture_head(pos:Vector2)->void:
	draw_circle(pos, 5.0, Color.black)

func _draw_tape(center:Vector2, lecture_head_pos:Vector2, left_tube_pos:Vector2, right_tube_pos:Vector2, tube_size:float)->void:
	
	var left_full_puller = center + Vector2(-55, 45)
	var left_puller = center + Vector2(-25, 30)
	var right_puller = center + Vector2(25, 30)
	var right_full_puller = center + Vector2(55, 45)
	
	draw_circle(left_full_puller, 3.0, Color.black)
	draw_circle(left_puller, 3.0, Color.black)
	draw_circle(right_puller, 3.0, Color.black)
	draw_circle(right_full_puller, 3.0, Color.black)
	
	tape_points = [
		left_tube_pos + Vector2(-get_tape_pos(), 0).rotated(-0.02 * get_tape_pos()),
		left_full_puller + Vector2(0, 3),
		left_puller  + Vector2(0, -3),
		lecture_head_pos + Vector2(0, 3),
		right_puller + Vector2(0, -3),
		right_full_puller  + Vector2(0, 3),
		right_tube_pos + Vector2(tube_size - get_tape_pos(), 0).rotated(0.02 * (tube_size - get_tape_pos()))
	]
	
	draw_polyline(tape_points, Color.black, 1.5)


func _draw_state_shape(state, pos:Vector2)->void:
	match state:
		UI_AUDIO_STATES.RECORD:
			_draw_record(pos)
		UI_AUDIO_STATES.PLAY:
			_draw_play(pos)
		UI_AUDIO_STATES.PAUSE:
			_draw_pause(pos)

func _draw_pause(pos_center:Vector2)->void:
	draw_line(pos_center + Vector2(-6, -10), pos_center + Vector2(-6, 10), Color(0, 0, 0, 0.7), 10.0)
	draw_line(pos_center + Vector2(6, -10), pos_center + Vector2(6, 10), Color(0, 0, 0, 0.7), 10.0)

func _draw_record(pos_center:Vector2)->FuncRef:
	return draw_circle(pos_center, 11, Color(1, 0, 0, 0.7))

func _draw_play(pos_center:Vector2)->FuncRef:
	return draw_polygon([
		pos_center + Vector2(15, 0),
		pos_center + Vector2(15, 0).rotated(2*PI/3),
		pos_center + Vector2(15, 0).rotated(4*PI/3)
		], PoolColorArray([Color(0.1, 1, 0.3, 0.7)]), PoolVector2Array()
	)

func get_tape_pos()->float:
	return Global.map(
		sin(1/MAX_CURSOR * cursor_angle + PI/2),
		-1,
		1,
		0,
		tube_size)

func _on_cursor_updated()->void:
	$Label.text = _get_chrono_text()
	cursor_angle = Global.get_cursor_pos()
	update()

func _on_record_started():
	ui_audio_state = UI_AUDIO_STATES.RECORD

func _on_audio_play():
	ui_audio_state = UI_AUDIO_STATES.PLAY

func _on_audio_pause():
	ui_audio_state = UI_AUDIO_STATES.PAUSE

func _get_chrono_text()->String:
	var cursor_pos:float = Global.get_cursor_pos()
	var mins:int = int(cursor_pos / 60.0)
	var secs:int = int(int(cursor_pos) % 60)
	var millis:int = int((cursor_pos - int(cursor_pos)) * 10)
	var mins_str = "%02d" % mins
	var secs_str = "%02d" % secs
	var millis_str = "%0-2d" % millis
	return mins_str + ":" + secs_str + ":" + millis_str


func _on_K7Panel_resized():
	center = rect_size / 2
