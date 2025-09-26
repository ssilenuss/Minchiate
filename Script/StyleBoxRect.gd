@tool
extends Control
class_name StyleBoxRect

@export var style_box : StyleBoxFlat = StyleBoxFlat.new()
@export var border_width : int = 1 :
	set(value):
		border_width = value
		style_box.set_border_width_all(border_width)
		queue_redraw()
@export var radius : int = 45 :
	set(value):
		radius = value
		style_box.set_corner_radius_all(radius)
		queue_redraw()
@export var bg_color : Color :
	set(value):
		bg_color = value
		style_box.set_bg_color(bg_color)
		queue_redraw()
@export var border_color : Color :
	set(value):
		border_color = value
		style_box.set_border_color(border_color)
		queue_redraw()

func _ready() -> void:
	queue_redraw()

func _draw() -> void:

	draw_style_box(style_box, Rect2(Vector2.ZERO, size))
