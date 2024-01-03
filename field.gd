extends Node2D

const ANT_SCENE = preload ("res://ant.tscn")
const FOOD_SCENE = preload("res://food.tscn")

var food : int = 50 :
	set(value):
		food = value
		%FoodStock.text = "FOOD: " + str(value)
		
var food_upkeep : float = 0:
	set(value):
		food_upkeep = value
		%Consumition.text = "FOOD UPKEEP: " + str(value)

var ants_amount : int = 0 :
	set(value):
		ants_amount = value
		%Ants.text = "ANT AMOUNT: " + str(value)


@onready var spawn: Marker2D = $Spawn
@onready var timer: Timer = $Spawn/Timer
@onready var tile_map: TileMap = $TileMap

func _ready() -> void:
	%FoodStock.text = "FOOD: " + str(food)
	randomize()


func spawn_new_ant():
	var new_ant = ANT_SCENE.instantiate()
	spawn.add_child(new_ant)
	new_ant.global_position = spawn.global_position + Vector2 (randi_range(-15 , 15), randi_range(-15 , 15))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		spawn_food()
		
func spawn_food():
	var new_food = FOOD_SCENE.instantiate()
	%Food.add_child(new_food)
	new_food.global_position = get_global_mouse_position()


func _on_button_pressed() -> void:
	spawn_new_ant()
	food -= 5
	food_upkeep += 0.2
	ants_amount += 1
