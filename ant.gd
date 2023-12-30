extends CharacterBody2D

enum States {IDLE, SCOUTING, EATING, FORAGING, HARVESTING, RETURNING, FIGHTING}

var timer_active : bool = false
var can_change_state : bool = false
var move_speed : float = 30.0
var random_angle : float
var direction_vector : Vector2
var food_location : Vector2
var colony_location : Vector2 = Vector2 ( 544, 400)


var current_state : States :
	set(value):
		current_state = value
		print (States.find_key(current_state))
		if current_state == States.SCOUTING or States.FORAGING:
			get_direction_vector()
		
@onready var state_timer: Timer = $Timer


func _ready() -> void:
	current_state = randi_range (0,1)
	get_node("/root/Field").food_placed.connect(_on_food_placed)

func _on_food_placed(food_location2):
	if current_state == States.IDLE or current_state == States.SCOUTING :
		current_state = States.FORAGING
		food_location = food_location2

func _physics_process(delta: float) -> void:
	
	match current_state:
		States.IDLE:
			if can_change_state:
				can_change_state = false
				current_state = States.SCOUTING
				
			elif timer_active == false:
				timer_active = true
				state_timer.wait_time = 2
				state_timer.start()
				
				
		States.SCOUTING:
			if can_change_state:
				can_change_state = false
				current_state = States.IDLE
				
			elif timer_active == false:
				timer_active = true
				state_timer.wait_time = 2
				state_timer.start()
				
			else: 
				velocity = direction_vector * move_speed
				move_and_slide()
				
		States.FORAGING:
			direction_vector = (food_location - global_position).normalized()
			set_rotation(direction_vector.angle())
			velocity = direction_vector * move_speed
			move_and_slide()
			if (food_location - global_position).length() <= 5:
				current_state = States.HARVESTING
				
		States.HARVESTING:
			await get_tree().create_timer(1).timeout
			direction_vector = (colony_location - global_position).normalized()
			set_rotation(direction_vector.angle())
			velocity = direction_vector * move_speed
			move_and_slide()
			if (colony_location - global_position).length() <= 5:
				queue_free()

func get_direction_vector():
	random_angle = randf_range( 0, TAU )
	set_rotation(random_angle)
	direction_vector = Vector2.RIGHT.rotated(random_angle)


func _on_timer_timeout() -> void:
	timer_active = false
	can_change_state = true

