extends Node2D

const SNAKE_ID = 0
const SNAKE_LAYER = 0
const APPLE_ID = 1
const APPLE_LAYER = 1

@onready var objektid = $Objektid
@onready var snake_timer = $SnakeTimer

# Muutujad A* algoritmi jaoks
var open_set := []
var closed_set := []
var came_from := {}
var g_score := {}
var f_score := {}
var path_to_apple: Array
var tee_ounani := false

#Ussimängu muutujad
var apple_pos: Vector2
var snake_direction := Vector2(1,0)
var snake_body_positions := [Vector2(5,10), Vector2(4,10), Vector2(3,10)]
var bite_apple := false
var snake_timer_stop := false

func heuristic_cost_estimate(current, goal) -> float:
	return abs(current.x - goal.x) + abs(current.y - goal.y)

func get_lowest_f_score(nodes) -> Vector2:
	var lowest = nodes[0]
	for node in nodes:
		if f_score[node] < f_score[lowest]:
			lowest = node
	return lowest

func reconstruct_path(came_from, current) -> Array:
	var total_path = [current]
	while came_from.has(current):
		current = came_from[current]
		total_path.append(current)
	
	#if total_path.size() > 1:
		#snake_direction = total_path[1] - snake_body_positions[0]
		## Kui madu pöörab tagasi, muuda suunda vastupidiseks
		#if total_path[1] == snake_body_positions[1]:
			#snake_direction *= -1
	return total_path

func get_neighbors(node) -> Array:
	var neighbors = []
	for dir in [Vector2(0, -1), Vector2(0, 1), Vector2(-1, 0), Vector2(1, 0)]:
		var neighbor = node + dir
		if neighbor.x >= 0 and neighbor.x < 20 and neighbor.y >= 0 and neighbor.y < 20:
			neighbors.append(neighbor)
	return neighbors

func _ready() -> void:
	apple_pos = place_apple()
	#apple_pos = Vector2(10,5)
	snake_timer.timeout.connect(_on_timeout)
	draw_apple()

func _input(_event: InputEvent):
	#If-statementid et vältida tagasi endasse liikumist
	#BUG - Kui korraga klahve vajutada saab ikkagi tagasi liiguda
	if Input.is_action_just_pressed("up"):
		if not snake_direction == Vector2(0,1):
			snake_direction = Vector2(0, -1)
	if Input.is_action_just_pressed("down"):
		if not snake_direction == Vector2(0,-1):
			snake_direction =  Vector2(0, 1)
	if Input.is_action_just_pressed("left"):
		if not snake_direction == Vector2(1,0):
			snake_direction =  Vector2(-1, 0)
	if Input.is_action_just_pressed("right"):
		if not snake_direction == Vector2(-1,0):
			snake_direction =  Vector2(1, 0)
	if Input.is_action_just_pressed("start_stop"):
		if snake_timer_stop == false:
			snake_timer.stop()
			snake_timer_stop = true
			return
		elif snake_timer_stop == true:
			snake_timer.start()
			snake_timer_stop = false
			return

func place_apple() -> Vector2:
	randomize()
	var x := randi_range(0, 19)
	var y := randi_range(0, 19)
	return Vector2(x,y)

func draw_apple() -> void:
	delete_tiles(APPLE_LAYER)
	objektid.set_cell(APPLE_LAYER, apple_pos, APPLE_ID,Vector2(0,0))
	
func draw_snake() -> void:
	var head = snake_body_positions[0]
	for block in snake_body_positions:
		objektid.set_cell(SNAKE_LAYER, Vector2(block.x, block.y), SNAKE_ID, Vector2(2,0))
		#Dir - UP, pööra pead
		if snake_direction == Vector2(0, -1):
			objektid.set_cell(SNAKE_LAYER, Vector2(head.x, head.y), SNAKE_ID, Vector2(0,0), 1)
		#Dir - DOWN, pööra pead
		if snake_direction == Vector2(0, 1):
			objektid.set_cell(SNAKE_LAYER, Vector2(head.x, head.y), SNAKE_ID, Vector2(0,0), 2)
		#Dir - LEFT, pööra pead
		if snake_direction == Vector2(-1, 0):
			objektid.set_cell(SNAKE_LAYER, Vector2(head.x, head.y), SNAKE_ID, Vector2(0,0), 3)
		#Dir - RIGHT, pööra pead
		if snake_direction == Vector2(1, 0):
			objektid.set_cell(SNAKE_LAYER, Vector2(head.x, head.y), SNAKE_ID, Vector2(0,0), 4)
	
func move_snake(valitud_tee: Array) -> void:
	if valitud_tee.is_empty():
		return
	if bite_apple:
		delete_tiles(SNAKE_LAYER)
		var body_copy = snake_body_positions.slice(1, snake_body_positions.size())
		var new_head = valitud_tee[-2] 
		body_copy.insert(0, new_head)
		snake_body_positions = body_copy
		bite_apple = false
		tee_ounani = false
	else:
		delete_tiles(SNAKE_LAYER)
		var body_copy = snake_body_positions.slice(0, snake_body_positions.size() - 1)
		var new_head = valitud_tee[-2]  
		body_copy.insert(0, new_head)
		snake_body_positions = body_copy
	
		valitud_tee.pop_back()
	
func delete_tiles(layer_number):
	objektid.clear_layer(layer_number)
	
func _on_timeout():
	check_apple_eaten()
	check_game_over()
	
	if tee_ounani != true:
		path_to_apple = a_star_algoritm()
		tee_ounani = true
	
	move_snake(path_to_apple)
	draw_snake()
	draw_apple()
	queue_redraw()

func check_apple_eaten() -> void:
	if apple_pos == snake_body_positions[0]:
		apple_pos = place_apple()
		bite_apple = true
		tee_ounani = false

func check_game_over() -> void:
	var head = snake_body_positions[0]
	#Uss põrkab vastu seina
	if head.x > 20 or head.x < 0 or head.y < 0 or head.y > 20:
		game_over()
	#Uss põrkab vastu keha
	for block in snake_body_positions.slice(1, snake_body_positions.size() - 1):
		if block == head:
			game_over()
	
func game_over() -> void:
	snake_timer.stop()
	print("Põrge")
	
#Joonista heuristika
func getTileMapGlobalPos(vektor: Vector2) -> Vector2:
	var cellCoords = vektor
	var localCellPos = objektid.map_to_local(cellCoords)
	var global_CellPos = objektid.to_global(localCellPos)
	
	return global_CellPos

func _draw() -> void:
	var snake_head = snake_body_positions[0]
	var snake_head_global_pos = getTileMapGlobalPos(snake_head)
	var apple_global_pos = getTileMapGlobalPos(apple_pos)
	
	if snake_direction.x == -1 or snake_direction.y == -1:
		draw_line(snake_head_global_pos ,Vector2(snake_head_global_pos.x, apple_global_pos.y), Color.CADET_BLUE, 8.0)
		draw_line(Vector2(snake_head_global_pos.x, apple_global_pos.y) ,apple_global_pos, Color.CADET_BLUE, 8.0)
	elif snake_direction.x == 1 or snake_direction.y == 1:
		draw_line(snake_head_global_pos ,Vector2(apple_global_pos.x, snake_head_global_pos.y), Color.CADET_BLUE, 8.0)
		draw_line(Vector2(apple_global_pos.x, snake_head_global_pos.y) ,apple_global_pos, Color.CADET_BLUE, 8.0)

func a_star_algoritm() -> Array:
	var valitud_tee: Array
# A* algoritm
	if not bite_apple:
		var start = snake_body_positions[0]
		var goal = apple_pos
		print(goal)
		
		open_set = [start]
		came_from = {}
		g_score = {start: 0}
		f_score = {start: heuristic_cost_estimate(start, goal)}
		
		while open_set.size() > 0:
			var current = get_lowest_f_score(open_set)
			
			if current == goal:
				valitud_tee = reconstruct_path(came_from, current)
				break
			
			open_set.erase(current)
			closed_set.append(current)
			
			for neighbor in get_neighbors(current):
				if closed_set.find(neighbor) != -1:
					continue
				
				var tentative_g_score = g_score[current] + 1
				
				if open_set.find(neighbor) == -1 or tentative_g_score < g_score[neighbor]:
					came_from[neighbor] = current
					g_score[neighbor] = tentative_g_score
					f_score[neighbor] = g_score[neighbor] + heuristic_cost_estimate(neighbor, goal)
					
					if open_set.find(neighbor) == -1:
						open_set.append(neighbor)
	print("See on valitud tee: ", valitud_tee)
	return valitud_tee
