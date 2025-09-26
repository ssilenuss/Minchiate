@tool
extends Control
class_name CardDrop

@export var radius : int = 45 :
	set(value):
		radius = value
		queue_redraw()
@export var color : Color :
	set(value):
		color = value
		queue_redraw()

@export var style_box : StyleBox :
	set(value):
		style_box = value
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

func _draw() -> void:
	var style_box = StyleBoxLine.new()
	style_box.set_corner_radius_all(radius)
	draw_style_box(style_box, Rect2(Vector2.ZERO, size))
