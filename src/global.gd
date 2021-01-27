extends Node

var audio_manager = preload("res://src/audio_manager.gd")

var downloadDirPath = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS) + "/"

func get_tracks()->Array:
	return audio_manager.get_tracks()

func get_cursor_pos()->float:
	return audio_manager.cursor
