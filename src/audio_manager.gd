# class to manage audio

extends Node

# ui can catch this signal to update itself
signal track_added
signal track_removed

var SAVE_PATH = Global.downloadDirPath

var effect
var recording

var cursor:float = 0.0

func _ready():
	Global.audioManager = self
	print(AudioServer.get_device_list())
	
	var _err = $TrackManager.connect("export_ready", self, "_on_export_ready")
	
	var idx = AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(idx, 0)
	

func record():
	if effect.is_recording_active():
		# stop recording on current track
		recording = effect.get_recording()
		effect.set_recording_active(false)
		$TrackManager.add_stream_to_track(recording)
		print("stopped recording")
	else:
		# start recording on current track
		$TrackManager.set_current_t_stamp(cursor)
		effect.set_recording_active(true)
		print("recording...")

func play_pause():
	if !effect.is_recording_active():
		if !$TrackManager.is_playing():
			$TrackManager.play_at(cursor)
		else:
			$TrackManager.stop()

func stop():
	if effect.is_recording_active():
		recording = effect.get_recording()
		effect.set_recording_active(false)
		print("stopped recording")
		$TrackManager.add_stream_to_track(recording)
	$TrackManager.stop()

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
	saveAudio()

func _on_ExportButton_pressed():
	$TrackManager.start_export()
