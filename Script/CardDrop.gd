@tool
extends Card
class_name CardDrop

@export var card_manager: CardManager

@export_category("Style")
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
	card_manager.set_card_size(self)
	queue_redraw()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _draw() -> void:
	draw_style_box(style_box, Rect2(Vector2.ZERO, size))
	
func _on_mouse_entered()->void:
	
	if card_manager.card_dragging:
		if is_card_drop:
			card_manager.set_card_drop(self)
			bg_color= Color(0,1,0,0.5)
		else:
			bg_color = Color(1,0,0,0.5)

	
func _on_mouse_exited()->void:
	card_manager.set_card_drop(null)
	#card_manager.card_drop = null
	bg_color.a = 0.0
