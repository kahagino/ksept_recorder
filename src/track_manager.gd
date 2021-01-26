extends Node

enum MODE {EDIT, EXPORT}
var mode = MODE.EDIT # by default

var tracks:Array = []
var focusedTrack:AudioStreamPlayer

var exportedNumber:int = 0
signal export_ready

func add_track():
	var track = AudioStreamPlayer.new()
	add_child(track)
	track.connect("finished", self, "_on_track_finished")
	tracks.append(track)
	print("focusedTrack: ", focusedTrack)
	print(tracks)
	print("number of child: ", get_child_count())
	print_tree_pretty()

func remove_track():
	if get_child_count() > 0:
		tracks[tracks.size() -1].queue_free()
		tracks.pop_back()
	
	print("focusedTrack: ", focusedTrack)
	print(tracks)
	print("number of child: ", get_child_count())
	print_tree_pretty()
	
func add_stream_to_track(stream:AudioStream):
	tracks[tracks.size() -1].stream = stream

func play():
	for track in tracks:
		track.play()

func isPlaying():
	# return true if any track is currently playing
	for track in tracks:
		if track.playing:
			return true
	
	return false
		

func stop():	
	for track in tracks:
		track.stop()

func startExport():
	exportedNumber = 0
	mode = MODE.EXPORT
	for track in tracks:
		track.bus = "Export"
	print("moved each track to bus Export")
	print("exporting...")
	play()

func _endExport():
	for track in tracks:
		track.bus = "Master"
	print("moved each track to bus Master")

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
		_endExport() # redirect every tracks to the output bus
		emit_signal("export_ready") # merged streams ready to be saved
