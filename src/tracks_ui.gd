extends MarginContainer


func _ready():
	Global.audioManager.connect("track_added", self, "_on_track_added")
	Global.audioManager.connect("track_removed", self, "_on_track_removed")

func _draw():
	pass

func _on_track_added():
	var track_panel = Button.new()
	track_panel.rect_min_size.y = 10
	add_child(track_panel)

func _on_track_removed():
	if get_child_count() > 0:
		# remove last child
		get_child(get_child_count() -1).queue_free()
