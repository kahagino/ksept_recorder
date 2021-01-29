extends Node

enum MODE {EDIT, EXPORT}
var mode = MODE.EDIT # by default

var tracks:Array = []
const MAX_TRACKS_SIZE = 6
var focused_track_index:int

var exportedNumber:int = 0
signal export_ready

const Track = preload("res://nodes/Track.tscn")

func _ready()->void:
	add_track()

func add_track()->void:
	if tracks.size() < MAX_TRACKS_SIZE:
		var track = Track.instance()
		add_child(track)
		track.connect("finished", self, "_on_track_finished")
		tracks.append(track)
		focused_track_index = tracks.size() -1 # focus to last added track
		print("focusedTrack id: ", focused_track_index)
		print(tracks)
		print("number of child: ", get_child_count())
		print_tree_pretty()

func remove_track()->void:
	if get_child_count() > 1: # we need always at least one track
		tracks[focused_track_index].queue_free()
		tracks.remove(focused_track_index)
		if focused_track_index > 0:
			focused_track_index -= 1 # focus to upper track
	
	print("focusedTrack id: ", focused_track_index)
	print(tracks)
	print("number of child: ", get_child_count())
	print_tree_pretty()

func focus_next()->void:
	if focused_track_index < tracks.size() -1:
		focused_track_index += 1
	
func focus_previous()->void:
	if focused_track_index > 0:
		focused_track_index -= 1

func add_stream_to_track(stream:AudioStream)->void:
	var focused_track = tracks[focused_track_index]
	focused_track.set_stream(stream)
	focused_track.update_end_t_stamp()

func set_current_t_stamp(cursor:float)->void:
	var focused_track = tracks[focused_track_index]
	focused_track.set_start_t_stamp(cursor)
	focused_track.is_end_set = false


func play_at(cursor:float)->void:
	for track in tracks:
		track.play_at(cursor)

func is_playing()->bool:
	# return true if any track is currently playing
	for track in tracks:
		if track.is_playing():
			return true
	
	return false
		

func stop()->void:
	for track in tracks:
		track.stop()

func prepare_export()->void:
	exportedNumber = 0
	mode = MODE.EXPORT
	for track in tracks:
		track.set_bus("Export")
	print("moved each track to bus Export")
	print("exporting...")

func _end_export()->void:
	for track in tracks:
		track.set_bus("Master")
	print("moved each track to bus Master")
	mode = MODE.EDIT

func _on_track_finished()->void:
	match mode:
		MODE.EXPORT:
			exportedNumber += 1
			_check_export_ready()
		MODE.EDIT:
			# TODO: go back to begging ?
			pass
		_:
			print("TrackManager MODE: ", mode, " doesn't match any known MODE")

func _check_export_ready()->void:
	if exportedNumber == tracks.size():
		_end_export()
		emit_signal("export_ready") # merged streams ready to be saved
