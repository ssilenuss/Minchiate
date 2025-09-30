extends Camera2D
class_name SmoothCam

@export var target_position := Vector2.ZERO
@export var lerp_speed : float = 0.05
@export var move_speed : float = 1000
@export var zoom_speed : float = 50

var left_node := Node2D.new()
var right_node := Node2D.new()
var top_node := Node2D.new()
var bottom_node := Node2D.new()
var nodes : Array[Node2D] = [left_node, right_node, top_node, bottom_node]

func _ready() -> void:
	item_rect_changed.connect(_on_item_rect_changed)
	for n in nodes:
		add_child(n)
	set_edge_nodes()

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_left"):
		target_position.x -= delta*move_speed
	elif Input.is_action_pressed("ui_right"):
		target_position.x += delta*move_speed
		
	if Input.is_action_pressed("ui_up"):
		target_position.y -= delta*move_speed
	elif Input.is_action_pressed("ui_down"):
		target_position.y += delta*move_speed
	
	
	if Input.is_action_just_pressed("wheel_down"):
		var zoom_scale := Vector2.ONE *delta *zoom_speed
		zoom += zoom_scale
	elif Input.is_action_just_pressed("wheel_up"):
		var zoom_scale := Vector2.ONE *delta *zoom_speed
		if zoom.x - zoom_scale.x > 0 and zoom.y - zoom_scale.y:
			zoom -= Vector2.ONE * delta * zoom_speed	
	position = lerp(position, target_position, lerp_speed)
	


func set_edge_nodes()->void:
	var size : Vector2 = get_viewport_rect().size
	left_node.position.x = -size.x/2.0
	right_node.position.x = size.x/2.0
	top_node.position.y = -size.y/2.0
	bottom_node.position.y = size.y/2.0

func _on_item_rect_changed()->void:
	set_edge_nodes()
	
