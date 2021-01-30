extends Node

signal tracks_updated
signal cursor_updated
signal record_started
signal export_state_changed
signal audio_play
signal audio_pause

const deadzone_x = 1.0
const deadzone_y = 120.0
var ready_for_next_focus:bool = true

var SAVE_PATH = Global.downloadDirPath

var track_manager:Node

var effect:AudioEffect
var recording:AudioStreamSample

var cursor:float = 0.0

var is_exporting:bool = false

func _ready()->void:
	Global.audio_manager = self
	print(AudioServer.get_device_list())
	
	track_manager = $TrackManager
	var _err = $TrackManager.connect("export_ready", self, "_on_export_ready")
	
	var idx = AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(idx, 0)
	

func _input(event)->void:
	# debug inputs
	if event.is_action_pressed("ui_left"):
		if !is_playing():
			cursor += 1.0
			emit_signal("cursor_updated")
	elif event.is_action_pressed("ui_right"):
		if !is_playing():
			cursor -= 1.0
			if cursor < 0.0:
				reset_cursor()
			emit_signal("cursor_updated")
	elif event.is_action_pressed("ui_up"):
		track_manager.focus_next()
		emit_signal("tracks_updated")
	elif event.is_action_pressed("ui_down"):
		track_manager.focus_previous()
		emit_signal("tracks_updated")

func move_cursor_from_gesture(relative_move:Vector2)->void:
	if !is_playing():
		if abs(relative_move.x) > deadzone_x:
			cursor = lerp(cursor, cursor -relative_move.x, 0.06)
			if cursor < 0.0:
				reset_cursor()
			emit_signal("cursor_updated")

func move_focused_track_from_gesture(speed:Vector2)->void:
	if !is_playing() && ready_for_next_focus:
		if abs(speed.y) > deadzone_y:
			if sign(speed.y) > 0:
				track_manager.focus_previous()
				emit_signal("tracks_updated")
			else:
				track_manager.focus_next()
				emit_signal("tracks_updated")
			
			ready_for_next_focus = false

func check_released_for_next_focus(is_touch_pressed:bool)->void:
	if !is_touch_pressed && !ready_for_next_focus:
		ready_for_next_focus = true

func record()->void:
	if effect.is_recording_active():
		stop()
	else:
		# start recording on current track
		$TrackManager.set_current_t_stamp(cursor)
		effect.set_recording_active(true)
		play_cursor()
		emit_signal("record_started")
		print("recording...")

func play_pause()->void:
	if !effect.is_recording_active():
		if !is_playing():
			play_cursor()
			emit_signal("audio_play")
		else:
			$TrackManager.stop()
			stop_cursor()
			emit_signal("audio_pause")

func stop()->void:
	if effect.is_recording_active():
		if !is_exporting:
			recording = effect.get_recording()
			effect.set_recording_active(false)
			print("stopped recording")
			$TrackManager.add_stream_to_track(recording)
			play_pause()
			emit_signal("audio_pause")
	else:
		reset_cursor()
		emit_signal("audio_pause")
		
	$TrackManager.stop()

func is_playing()->bool:
	if $CursorTimer.is_stopped():
		return false
	
	return true


func play_cursor()->void:
	$CursorTimer.start()
	emit_signal("cursor_updated")

func stop_cursor()->void:
	$CursorTimer.stop()
	emit_signal("cursor_updated")

func reset_cursor()->void:
	cursor = 0.0
	stop_cursor()

func add_track()->void:
	if !effect.is_recording_active():
		$TrackManager.add_track()
		emit_signal("tracks_updated")

func remove_track()->void:
	if !effect.is_recording_active():
		$TrackManager.remove_track()
		emit_signal("tracks_updated")

func save_audio()->void:
	var time = OS.get_time()
	var time_return = str(time.hour)+"."+str(time.minute)+"."+str(time.second)
	var file_path = SAVE_PATH + "/ksept/exported_" + time_return
	
	var dir = Directory.new()
	if !dir.dir_exists(SAVE_PATH + "/ksept"):
		dir.open(SAVE_PATH)
		dir.make_dir("ksept")
	
	var err = recording.save_to_wav(file_path)
	if err != OK:
		OS.alert('Error saving wav file, check Storage permission', 'Error')
	else:
		var message = 'File saved successfully: ' + file_path
		OS.alert(message, 'Export')
	
	stop()
	is_exporting = false
	emit_signal("export_state_changed", is_exporting)

func _on_export_ready()->void:
	print("export ready to be saved")
	recording = effect.get_recording()
	effect.set_recording_active(false)
	save_audio()

func _on_ExportButton_pressed()->void:
	if !is_exporting:
		if !is_playing():
			stop()
			stop() # call two times to ensure cursor is reset to beggining
			$TrackManager.prepare_export()
			play_pause()
			if !effect.is_recording_active():
				effect.set_recording_active(true)
				is_exporting = true
				emit_signal("export_state_changed", is_exporting)

func _on_CursorTimer_timeout()->void:
	cursor += $CursorTimer.wait_time
	$TrackManager.play_at(cursor)
	emit_signal("cursor_updated")
