extends Node

signal finished # emited when AudioStreamPlayer finished

var start_t_stamp:float
var end_t_stamp:float
var is_start_set:bool = false
var is_end_set = false

func _ready()->void:
	$AudioStreamPlayer.connect("finished", self, "_on_AudioStream_finished")

func play_at(from_position:float)->void:
	if !$AudioStreamPlayer.playing:
		if is_defined():
			if(from_position >= start_t_stamp && from_position < end_t_stamp):
				$AudioStreamPlayer.play(from_position - start_t_stamp)
				print("playing track ", self, "...")

func stop()->void:
	$AudioStreamPlayer.stop()

func set_stream(stream:AudioStream)->void:
	$AudioStreamPlayer.stream = stream

func is_playing()->bool:
	if $AudioStreamPlayer.playing:
		return true
		
	return false

func is_defined()->bool:
	if is_start_set && is_end_set:
		return true
	
	return false

func set_start_t_stamp(t_stamp:float)->void:
	start_t_stamp = t_stamp
	print(self, " start_t_stamp set to ", start_t_stamp)
	is_start_set = true

func update_end_t_stamp()->void:
	end_t_stamp = start_t_stamp + get_length()
	print(self, " end_t_stamp set to ", end_t_stamp)
	is_end_set = true

func get_length()->float:
	return $AudioStreamPlayer.stream.get_length()

func set_bus(new_bus:String)->void:
	$AudioStreamPlayer.bus = new_bus

func _on_AudioStream_finished()->void:
	emit_signal("finished")
	print("track ", self, " finished")
