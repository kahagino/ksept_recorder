extends Node

signal tracks_updated
signal cursor_updated

var SAVE_PATH = Global.downloadDirPath

var track_manager:Node

var effect:AudioEffect
var recording:AudioStreamSample

var cursor:float = 0.0

func _ready()->void:
	Global.audio_manager = self
	print(AudioServer.get_device_list())
	
	track_manager = $TrackManager
	var _err = $TrackManager.connect("export_ready", self, "_on_export_ready")
	
	var idx = AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(idx, 0)
	

func _input(event)->void:
	if event.is_action_pressed("ui_left"):
		cursor += 1.0
		emit_signal("cursor_updated")
	elif event.is_action_pressed("ui_right"):
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

func record()->void:
	if effect.is_recording_active():
		stop()
	else:
		# start recording on current track
		$TrackManager.set_current_t_stamp(cursor)
		effect.set_recording_active(true)
		play_cursor()
		print("recording...")

func play_pause()->void:
	if !effect.is_recording_active():
		if !is_playing():
			play_cursor()
		else:
			$TrackManager.stop()
			stop_cursor()

func stop()->void:
	if effect.is_recording_active():
		recording = effect.get_recording()
		effect.set_recording_active(false)
		print("stopped recording")
		$TrackManager.add_stream_to_track(recording)
		play_pause()
	else:
		reset_cursor()
	
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
	#var time = OS.get_time()
	#var time_return = String(time.hour) +"."+String(time.minute)+"."+String(time.second)
	var file_path = SAVE_PATH + "exported"# + time_return
	
	var err = recording.save_to_wav(file_path)
	if err != OK:
		OS.alert('Error saving wav file, check Storage permission', 'Error')
	else:
		var message = 'File saved successfully in ' + file_path
		OS.alert(message, 'Export')
	
	var display_path = [file_path, ProjectSettings.globalize_path(file_path)]
	var status_text = "Saved WAV file to: %s\n(%s)" % display_path
	print(status_text)
	stop()

func _on_export_ready()->void:
	print("export ready to be saved")
	recording = effect.get_recording()
	effect.set_recording_active(false)
	save_audio()

func _on_ExportButton_pressed()->void:
	stop()
	stop() # call to times to ensure cursor is reset to beggining
	$TrackManager.prepare_export()
	play_pause()
	if !effect.is_recording_active():
		effect.set_recording_active(true)
	else:
		OS.alert("Stop record before export", "Alert")

func _on_CursorTimer_timeout()->void:
	cursor += $CursorTimer.wait_time
	$TrackManager.play_at(cursor)
	emit_signal("cursor_updated")
