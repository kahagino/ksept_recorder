extends Node

signal track_added
signal track_removed
signal cursor_updated

var SAVE_PATH = Global.downloadDirPath

var track_manager:Node

var effect:AudioEffect
var recording:AudioStreamSample

var cursor:float = 0.0

func _ready():
	Global.audio_manager = self
	print(AudioServer.get_device_list())
	
	track_manager = $TrackManager
	var _err = $TrackManager.connect("export_ready", self, "_on_export_ready")
	
	var idx = AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(idx, 0)
	

func _input(event):
	if event.is_action_pressed("ui_left"):
		cursor += 1.0
		emit_signal("cursor_updated")
	elif event.is_action_pressed("ui_right"):
		cursor -= 1.0
		emit_signal("cursor_updated")

func record():
	if effect.is_recording_active():
		stop()
		# stop recording on current track
#		recording = effect.get_recording()
#		effect.set_recording_active(false)
#		$TrackManager.add_stream_to_track(recording)
#		play_pause()
	else:
		# start recording on current track
		$TrackManager.set_current_t_stamp(cursor)
		effect.set_recording_active(true)
		play_cursor()
		print("recording...")

func play_pause():
	if !effect.is_recording_active():
		if !is_playing():
			play_cursor()
		else:
			$TrackManager.stop()
			stop_cursor()

func stop():
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

func add_track():
	$TrackManager.add_track()
	emit_signal("track_added")

func remove_track():
	$TrackManager.remove_track()
	emit_signal("track_removed")

func saveAudio():
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

func _on_export_ready():
	print("export ready to be saved")
	recording = effect.get_recording()
	effect.set_recording_active(false)
	saveAudio()

func _on_ExportButton_pressed():
	$TrackManager.prepare_export()
	play_pause()
	if !effect.is_recording_active():
		effect.set_recording_active(true)
	else:
		OS.alert("Stop record before export", "Alert")

func _on_CursorTimer_timeout():
	cursor += $CursorTimer.wait_time
	$TrackManager.play_at(cursor)
	emit_signal("cursor_updated")
