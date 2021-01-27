extends Node

signal finished # emited when AudioStreamPlayer finished

var start_t_stamp:float
var end_t_stamp:float
var is_playable:bool

func _ready():
	$AudioStreamPlayer.connect("finished", self, "_on_AudioStream_finished")

func play_at(from_position:float):
	if is_playable:
		if(from_position >= start_t_stamp && from_position < end_t_stamp):
			$AudioStreamPlayer.play(from_position - start_t_stamp)
			print("playing track ", self, "...")

func stop():
	$AudioStreamPlayer.stop()

func set_stream(stream:AudioStream):
	$AudioStreamPlayer.stream = stream

func is_playing():
	if $AudioStreamPlayer.playing:
		return true
		
	return false
	
func set_start_t_stamp(t_stamp:float):
	start_t_stamp = t_stamp
	print(self, " start_t_stamp set to ", start_t_stamp)
	is_playable = true

func update_end_t_stamp():
	end_t_stamp = start_t_stamp + get_length()
	print(self, " end_t_stamp set to ", end_t_stamp)

func get_length():
	return $AudioStreamPlayer.stream.get_length()


func _on_AudioStream_finished():
	emit_signal("finished")
	print("track ", self, " finished...")
