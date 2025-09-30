extends Camera2D

@export var target_position := Vector2.ZERO
@export var lerp_speed : float = 0.05
@export var move_speed : float = 1000
@export var zoom_speed : float = 50

func _ready() -> void:
	pass

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
