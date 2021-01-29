extends Node

var audio_manager = preload("res://src/audio_manager.gd")
var downloadDirPath = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS) + "/"

enum THEME {BRIGHT, DARK}
var app_theme = load("res://theme/theme_bright.tres") # by default

func select_theme(new_theme:int):
	match new_theme:
		THEME.BRIGHT:
			app_theme = load("res://theme/theme_bright.tres")
		THEME.DARK:
			app_theme = load("res://theme/theme_dark.tres")
		_:
			print(new_theme, " is not a defined theme")
		

func get_tracks()->Array:
	return audio_manager.track_manager.tracks

func get_cursor_pos()->float:
	return audio_manager.cursor

func get_focused_track_index()->int:
	return audio_manager.track_manager.focused_track_index

func map(value:float, istart:float, istop:float, ostart:float, ostop:float):
	return ostart + (ostop - ostart) * ((value - istart) / (istop - istart))
