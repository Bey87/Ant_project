extends StaticBody2D

'''PHEROMONE NORMAL EMITED BY SCOUTING ANTS,  
THEY TRY TO AVOID THEM TO SEARCH FOR UNEXPLORED AREAS 
BUT ONCE FOOD IS FOUND THEY LOOK FOR THIS ONES TO FIND WAY HOME'''

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

