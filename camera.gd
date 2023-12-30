extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	zoom = Vector2(0.8, 0.8)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("wheel_up") and zoom < Vector2(8, 8):
		zoom += Vector2(0.15,0.15)
	elif event.is_action_pressed("wheel_down") and zoom > Vector2(1, 1):
		zoom -= Vector2(0.10,0.10)
	elif event.is_action_pressed("wheel_click"):
		global_position = get_global_mouse_position()
