extends CharacterBody2D

enum States {IDLE, SCOUTING, EATING, TO_FOOD_PHEROMONE, TO_FOOD, HARVESTING, TO_COLONY, FIGHTING}

const PHEROMONE_FOOD : PackedScene = preload("res://pheromone_food.tscn")
const PHEROMONE_NORMAL : PackedScene = preload("res://pheromone_normal.tscn")

var list_of_angles_degree : Array

var state_timer_active : bool = false
var can_change_state : bool = false
var move_speed : float = 30.0
var direction_vector : Vector2
var food_location : Vector2
var colony_location : Vector2 = Vector2 ( 552, 392)
var harvesting_time : float = 2

var current_state : States :
	set(value):
		current_state = value
		get_direction_vector()
		update_rotation()
		#print (direction_vector)
		#print (States.find_key(current_state))

		
@onready var state_timer: Timer = %StateTimer
@onready var pheromone_timer: Timer = %PheromoneTimer
@onready var food_carry_image: Sprite2D = %FoodCarry
@onready var detector: Area2D = $Detector


func _ready() -> void:
	current_state = randi_range (0,1)
	food_carry_image.visible = false


func _physics_process(delta: float) -> void:
	match current_state:
		States.IDLE:
			if can_change_state:
				can_change_state = false
				current_state = States.SCOUTING
				
			elif state_timer_active == false:
				state_timer_active = true
				state_timer.wait_time = 0.5
				state_timer.start()
						
		States.SCOUTING:
			if can_change_state:
				can_change_state = false
				current_state = States.IDLE
				
			elif state_timer_active == false:
				state_timer_active = true
				state_timer.wait_time = 0.8
				state_timer.start()
				
			else: 
				velocity = direction_vector * move_speed
				move_and_slide()
				
		States.TO_FOOD:
			velocity = direction_vector * move_speed
			move_and_slide()
			if (food_location - global_position).length() <= 10:
				current_state = States.HARVESTING
				
				
		States.HARVESTING:
			await get_tree().create_timer(harvesting_time).timeout
			current_state = States.TO_COLONY
				
				
		States.TO_COLONY:
			velocity = direction_vector * move_speed
			move_and_slide()
			food_carry_image.visible = true
			if (colony_location - global_position).length() <= 5:
				add_food_to_colony()
				queue_free()


func _on_state_timer_timeout() -> void:
	state_timer_active = false
	can_change_state = true


func get_direction_vector():
	if current_state == States.TO_FOOD or current_state == States.HARVESTING:
		direction_vector = (food_location - global_position).normalized()
		
	elif current_state == States.TO_COLONY:
		direction_vector = (colony_location - global_position).normalized()
	
	else:
		list_of_angles_degree.clear()
		for X in 360:
			for Y in 10:
				list_of_angles_degree.append(X)
		get_pheromones_in_area("PheromoneNormal")
		var random_angle_degrees : int = list_of_angles_degree.pick_random()
		direction_vector = convert_degree_to_vector2(random_angle_degrees)

				

func update_rotation():
	if current_state == States.IDLE:
		return
		
	var new_angle_rad = direction_vector.angle()
	set_rotation(new_angle_rad)
	
	
func _on_pheromone_timer_timeout() -> void:
	if current_state == States.TO_COLONY or current_state == States.HARVESTING:
		pheromone_timer.wait_time = 0.5
		_emit_pheromone(PHEROMONE_FOOD)
	else:
		_emit_pheromone(PHEROMONE_NORMAL)
	
	
func _emit_pheromone(pheromone_type):
	var new_pheromone = pheromone_type.instantiate()
	get_node("/root/Field/Pheromones").add_child(new_pheromone)
	new_pheromone.global_position = global_position
	
	
func _on_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("Food"):
		food_location = body.global_position
		current_state = States.TO_FOOD
	elif body.is_in_group("PheromoneFood"):
		get_pheromones_in_area("PheromoneFood")
		
	
	
func add_food_to_colony():
	get_node("/root/Field").food += 25

func convert_degree_to_vector2(angle_degree) -> Vector2:
	var angle_rad : float = deg_to_rad(angle_degree)
	var direction_v2 : Vector2 = Vector2.from_angle(angle_rad)
	return direction_v2

func convert_vector2_to_degree(direction_v2) -> float :
	var angle_rad : float = direction_v2.angle()
	var angle_degree: float = rad_to_deg(angle_rad)
	return angle_degree


func get_pheromones_in_area(pheromone_type):
	var bodies_inside_area = detector.get_overlapping_bodies()
	for X in bodies_inside_area:
		if pheromone_type == "PheromoneNormal":
			if X.is_in_group(pheromone_type) :
				print("yea")
				var pheromone_direction_degree = roundi(convert_vector2_to_degree(X.global_position - global_position))
				var pheromone_strength = X.pheromone_strenght
				if pheromone_strength > 90:
					for Y in 10:
						var pheromone_index = list_of_angles_degree.find(pheromone_direction_degree)
						list_of_angles_degree.remove_at(pheromone_index)
					for Y in 8:
						var pheromone_index_up = list_of_angles_degree.find(pheromone_direction_degree + 1)
						list_of_angles_degree.remove_at(pheromone_index_up)
						var pheromone_index_down = list_of_angles_degree.find(pheromone_direction_degree - 1)
						list_of_angles_degree.remove_at(pheromone_index_down)
						
				elif pheromone_strength > 70:
					for Y in 7:
						var pheromone_index = list_of_angles_degree.find(pheromone_direction_degree)
						list_of_angles_degree.remove_at(pheromone_index)
					for Y in 6:
						var pheromone_index_up = list_of_angles_degree.find(pheromone_direction_degree + 1)
						list_of_angles_degree.remove_at(pheromone_index_up)
						var pheromone_index_down = list_of_angles_degree.find(pheromone_direction_degree - 1)
						list_of_angles_degree.remove_at(pheromone_index_down)
					
				elif pheromone_strength > 50:
					for Y in 5:
						var pheromone_index = list_of_angles_degree.find(pheromone_direction_degree)
						list_of_angles_degree.remove_at(pheromone_index)
					for Y in 4:
						var pheromone_index_up = list_of_angles_degree.find(pheromone_direction_degree + 1)
						list_of_angles_degree.remove_at(pheromone_index_up)
						var pheromone_index_down = list_of_angles_degree.find(pheromone_direction_degree - 1)
						list_of_angles_degree.remove_at(pheromone_index_down)
						
				elif pheromone_strength > 30:
					for Y in 2:
						var pheromone_index = list_of_angles_degree.find(pheromone_direction_degree)
						list_of_angles_degree.remove_at(pheromone_index)
					for Y in 1:
						var pheromone_index_up = list_of_angles_degree.find(pheromone_direction_degree + 1)
						list_of_angles_degree.remove_at(pheromone_index_up)
						var pheromone_index_down = list_of_angles_degree.find(pheromone_direction_degree - 1)
						list_of_angles_degree.remove_at(pheromone_index_down)
						
		if pheromone_type == "PheromoneFood":
			if X.is_in_group(pheromone_type) :
				var pheromone_direction_degree = roundi(convert_vector2_to_degree(X.global_position - global_position))
				var pheromone_strength = X.pheromone_strenght
				if pheromone_strength < 100:
					for Y in 20:
						var pheromone_index = list_of_angles_degree.find(pheromone_direction_degree)
						list_of_angles_degree.append(list_of_angles_degree[pheromone_index])
					for Y in 15:
						var pheromone_index_up = list_of_angles_degree.find(pheromone_direction_degree + 1)
						list_of_angles_degree.append(list_of_angles_degree[pheromone_index_up])
						var pheromone_index_down = list_of_angles_degree.find(pheromone_direction_degree - 1)
						list_of_angles_degree.append(list_of_angles_degree[pheromone_index_down])
