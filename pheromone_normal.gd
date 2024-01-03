extends StaticBody2D

'''PHEROMONE FOOD EMITED BY FORAGING ANTS,  
THEY EMIT THEM SO OTHER ANTS CAN FOLLOW IT TOWARDS THE FOOD'''

@export var pheromone_strenght : float = 100.0
@export var time_per_pheromone_tick : float = 2.0
@export var strength_lost_per_pheromone_tick : float = 5.0

@onready var timer: Timer = $Timer
@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	pheromone_strenght = 100
	timer.wait_time = time_per_pheromone_tick
	timer.one_shot = false
	timer.start()


func _on_timer_timeout() -> void:
	pheromone_strenght -= strength_lost_per_pheromone_tick
	sprite_2d.modulate.a -= 0.05
	if sprite_2d.modulate.a < 0.05:
		queue_free()
