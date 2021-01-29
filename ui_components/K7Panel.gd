extends MarginContainer


export var chrono_font:DynamicFont

func _ready():
	Global.audio_manager.connect("cursor_updated", self, "_on_cursor_updated")

func _on_cursor_updated()->void:
	$Label.text = _get_chrono_text()

func _draw_clock_text(text:String, pos:Vector2)->FuncRef:
	var string_size = chrono_font.get_string_size(text)/2
	var center_offset = Vector2(-string_size.x, -string_size.y)
	return draw_string(
		chrono_font,
		center_offset + pos,
		text,
		Color.white
		)

func _get_chrono_text()->String:
	var cursor_pos:float = Global.get_cursor_pos()
	var mins:int = int(cursor_pos / 60.0)
	var secs:int = int(int(cursor_pos) % 60)
	var millis:int = int((cursor_pos - int(cursor_pos)) * 10)
	var mins_str = "%02d" % mins
	var secs_str = "%02d" % secs
	var millis_str = "%0-2d" % millis
	return mins_str + ":" + secs_str + ":" + millis_str
