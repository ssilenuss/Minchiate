extends Control
#class_name CardDrop


@export var color : Color :
	set(value):
		color = value
		queue_redraw()



signal dragging_changed(value: bool)

func _ready() -> void:
	modulate = Color(Color.MEDIUM_PURPLE, 0.7)
	dragging_changed.connect(_on_dragging_changed)

func _process(_delta: float) -> void:
	if Global.is_dragging:
		visible = true
	else:
		visible = false

func _on_dragging_changed(value: bool)->void:
	Global.is_dragging = value
