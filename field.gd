extends Node2D

signal food_placed

var ant = preload ("res://ant.tscn")

@onready var spawn: Marker2D = $Spawn
@onready var timer: Timer = $Spawn/Timer
@onready var tile_map: TileMap = $TileMap

func _ready() -> void:
	randomize()

func _on_timer_timeout() -> void:
	for X in 5:
		var new_ant = ant.instantiate()
		spawn.add_child(new_ant)
		new_ant.global_position = spawn.global_position + Vector2 (randi_range(-15 , 15), randi_range(-15 , 15))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		var mouse_click_cell = tile_map.local_to_map(get_global_mouse_position())
		tile_map.set_cell(1,mouse_click_cell,0, Vector2i(4,3),0)
		emit_signal("food_placed",get_global_mouse_position())
		
