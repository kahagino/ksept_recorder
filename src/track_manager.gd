extends Node

enum MODE {EDIT, EXPORT}
var mode = MODE.EDIT # by default

var tracks:Array = []
var focused_track:AudioStreamPlayer

var exportedNumber:int = 0
signal export_ready

const Track = preload("res://nodes/Track.tscn")

func add_track():
	var track = Track.instance()
	add_child(track)
	track.connect("finished", self, "_on_track_finished")
	tracks.append(track)
	print("focusedTrack: ", focused_track)
	print(tracks)
	print("number of child: ", get_child_count())
	print_tree_pretty()

func remove_track():
	if get_child_count() > 0:
		tracks[tracks.size() -1].queue_free()
		tracks.pop_back()
	
	print("focusedTrack: ", focused_track)
	print(tracks)
	print("number of child: ", get_child_count())
	print_tree_pretty()
	
func add_stream_to_track(stream:AudioStream):
	var last_track = tracks[tracks.size() -1]
	last_track.set_stream(stream)
	last_track.update_end_t_stamp()

func set_current_t_stamp(cursor:float):
	var last_track = tracks[tracks.size() -1]
	last_track.set_start_t_stamp(cursor)


func play_at(cursor:float):
	for track in tracks:
		track.play_at(cursor)

func is_playing():
	# return true if any track is currently playing
	for track in tracks:
		if track.is_playing():
			return true
	
	return false
		

func stop():	
	for track in tracks:
		track.stop()

func prepare_export():
	exportedNumber = 0
	mode = MODE.EXPORT
	for track in tracks:
		track.set_bus("Export")
	print("moved each track to bus Export")
	print("exporting...")

func _end_export():
	for track in tracks:
		track.set_bus("Master")
	print("moved each track to bus Master")
	mode = MODE.EDIT

func _on_track_finished():
	match mode:
		MODE.EXPORT:
			exportedNumber += 1
			_check_export_ready()
		MODE.EDIT:
			# TODO: go back to begging ?
			pass
		_:
			print("TrackManager MODE: ", mode, " doesn't match any known MODE")

func _check_export_ready():
	if exportedNumber == tracks.size():
		_end_export()
		emit_signal("export_ready") # merged streams ready to be saved
