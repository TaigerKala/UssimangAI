extends Node2D

const SNAKE_ID = 0
const SNAKE_LAYER = 0
const APPLE_ID = 1
const APPLE_LAYER = 1

@onready var objektid = $Objektid
@onready var snake_timer = $SnakeTimer
@onready var skoori_label = $Skoor
@onready var astar_grid


#Ussimängu muutujad
var apple_pos: Vector2i
var snake_direction := Vector2(1,0)
var snake_body_positions := [Vector2i(5,10), Vector2i(4,10), Vector2i(3,10)]
var bite_apple := false
var snake_timer_stop := false
var solid_points := []
var oun_ussis := false
var skoori_number := 0

func _ready() -> void:
	#apple_pos = place_apple()
	apple_pos = Vector2(10,5)
	snake_timer.timeout.connect(_on_timeout)
	draw_apple()
	
	astar_grid = AStarGrid2D.new()
	astar_grid.region = Rect2i(Vector2i(0, 1), Vector2i(800, 800))
	astar_grid.cell_size = Vector2(40, 40)
	astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.jumping_enabled = false
	astar_grid.update()

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
	var y := randi_range(1, 19)
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
	
func move_snake(coord_list: Array) -> void:
	if coord_list.is_empty():
		return
	var alg_vektor: Vector2 = snake_body_positions[0]
	var lopp_vektor: Vector2 = coord_list[0]
	var suuna_vektor: Vector2 = lopp_vektor - alg_vektor
	
	snake_direction = suuna_vektor.normalized()
	
	print("See on coord list ", coord_list)
	if bite_apple:
		delete_tiles(SNAKE_LAYER)
		var body_copy = snake_body_positions.slice(0, snake_body_positions.size())
		var new_head = coord_list[0]
		body_copy.insert(0, new_head)
		snake_body_positions = body_copy
		bite_apple = false
	else:
		delete_tiles(SNAKE_LAYER)
		var body_copy = snake_body_positions.slice(0, snake_body_positions.size() - 1)
		var new_head = coord_list[0]
		body_copy.insert(0, new_head)
		snake_body_positions = body_copy

func delete_tiles(layer_number):
	objektid.clear_layer(layer_number)

func _on_timeout():
	var coord_list = a_star_algoritm()
	move_snake(coord_list)
	draw_snake()
	check_apple_eaten()
	check_game_over()
	draw_apple()
	queue_redraw()

func check_apple_eaten() -> void:
	if apple_pos == snake_body_positions[0]:
		skoori_number += 1
		skoori_label.text = "SKOOR: %s" % skoori_number
		oun_ussis = true
		apple_pos = place_apple()
		while oun_ussis:
			if apple_pos in snake_body_positions:
				print("Õun on ussi sees")
				apple_pos = place_apple()
				oun_ussis = true
			else:
				oun_ussis = false
			
		bite_apple = true

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
	var positsioon = a_star_algoritm()
	var positsioon_koopia := []
	
	for i in positsioon:
		positsioon_koopia.append(getTileMapGlobalPos(i))
	
	var joonista_heuristika: PackedVector2Array = positsioon_koopia
	
	draw_polyline(joonista_heuristika, Color.AQUA, 8.0)

func a_star_algoritm() -> Array:
	print("Need on solid pointid ", solid_points)
	
	for j in solid_points:
		astar_grid.set_point_solid(j, false)
		solid_points.pop_front()
	
	for i in snake_body_positions:
		astar_grid.set_point_solid(i, true)
		solid_points.append(i)
		
	var a_star_tee = astar_grid.get_point_path(snake_body_positions[0], apple_pos)
	
	#Array = PackedVector2Array
	var valitud_tee: Array = a_star_tee
	
	#Coords to local
	var local_pos_list := []
	
	for i in valitud_tee:
		var x_pos: int = i.x
		var y_pos:int  = i.y
		
		x_pos = x_pos / 40
		y_pos = y_pos / 40
		
		local_pos_list.append(Vector2i(x_pos, y_pos))
	local_pos_list.pop_front()
	return local_pos_list
