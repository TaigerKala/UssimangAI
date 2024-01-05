extends Node2D

const SNAKE_ID = 0
const SNAKE_LAYER = 0
const APPLE_ID = 1
const APPLE_LAYER = 1

@onready var objektid = $Objektid
@onready var snake_timer = $SnakeTimer

var apple_pos: Vector2i
var snake_direction := Vector2i(1,0)
var snake_body_positions := [Vector2i(5,10), Vector2i(4,10), Vector2i(3,10)]
var bite_apple := false
var snake_timer_stop := false

func _ready() -> void:
	apple_pos = place_apple()
	snake_timer.timeout.connect(_on_timeout)
	draw_apple()

func _input(event: InputEvent):
	#If-statementid et vältida tagasi endasse liikumist
	#BUG - Kui korraga klahve vajutada saab ikkagi tagasi liiguda
	if Input.is_action_just_pressed("up"):
		if not snake_direction == Vector2i(0,1):
			snake_direction = Vector2i(0, -1)
	if Input.is_action_just_pressed("down"):
		if not snake_direction == Vector2i(0,-1):
			snake_direction =  Vector2i(0, 1)
	if Input.is_action_just_pressed("left"):
		if not snake_direction == Vector2i(1,0):
			snake_direction =  Vector2i(-1, 0)
	if Input.is_action_just_pressed("right"):
		if not snake_direction == Vector2i(-1,0):
			snake_direction =  Vector2i(1, 0)
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
	return Vector2i(x,y)

func draw_apple() -> void:
	delete_tiles(APPLE_LAYER)
	objektid.set_cell(APPLE_LAYER, apple_pos, APPLE_ID,Vector2i(0,0))
	
func draw_snake() -> void:
	var head = snake_body_positions[0]
	for block in snake_body_positions:
		objektid.set_cell(SNAKE_LAYER, Vector2i(block.x, block.y), SNAKE_ID, Vector2i(2,0))
		#Dir - UP, pööra pead
		if snake_direction == Vector2i(0, -1):
			objektid.set_cell(SNAKE_LAYER, Vector2i(head.x, head.y), SNAKE_ID, Vector2i(0,0), 1)
		#Dir - DOWN, pööra pead
		if snake_direction == Vector2i(0, 1):
			objektid.set_cell(SNAKE_LAYER, Vector2i(head.x, head.y), SNAKE_ID, Vector2i(0,0), 2)
		#Dir - LEFT, pööra pead
		if snake_direction == Vector2i(-1, 0):
			objektid.set_cell(SNAKE_LAYER, Vector2i(head.x, head.y), SNAKE_ID, Vector2i(0,0), 3)
		#Dir - RIGHT, pööra pead
		if snake_direction == Vector2i(1, 0):
			objektid.set_cell(SNAKE_LAYER, Vector2i(head.x, head.y), SNAKE_ID, Vector2i(0,0), 4)
	
	var snake_head_global_pos = getTileMapGlobalPos(head)
	var apple_global_pos = getTileMapGlobalPos(apple_pos)
	draw_line(snake_head_global_pos ,Vector2i(snake_head_global_pos.x, apple_global_pos.y), Color.CADET_BLUE, 8.0)
	draw_line(Vector2i(snake_head_global_pos.x, apple_global_pos.y) ,apple_global_pos, Color.CADET_BLUE, 8.0)
	
func move_snake() -> void:
	if bite_apple:
		delete_tiles(SNAKE_LAYER)
		var body_copy = snake_body_positions.slice(0, snake_body_positions.size())
		var new_head = body_copy[0] + snake_direction
		body_copy.insert(0, new_head)
		snake_body_positions = body_copy
		bite_apple = false
	else:
		delete_tiles(SNAKE_LAYER)
		var body_copy = snake_body_positions.slice(0, snake_body_positions.size() - 1)
		var new_head = body_copy[0] + snake_direction
		body_copy.insert(0, new_head)
		snake_body_positions = body_copy
	
func delete_tiles(layer_number):
	objektid.clear_layer(layer_number)
	
func _on_timeout():
	move_snake()
	draw_snake()
	draw_apple()
	check_apple_eaten()
	check_game_over()
	queue_redraw()

func check_apple_eaten() -> void:
	if apple_pos == snake_body_positions[0]:
		apple_pos = place_apple()
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
func getTileMapGlobalPos(vektor: Vector2i) -> Vector2i:
	var cellCoords = vektor
	var localCellPos = objektid.map_to_local(cellCoords)
	var global_CellPos = objektid.to_global(localCellPos)
	
	return global_CellPos

func _draw() -> void:
	var snake_head = snake_body_positions[0]
	var snake_head_global_pos = getTileMapGlobalPos(snake_head)
	var apple_global_pos = getTileMapGlobalPos(apple_pos)
	
	if snake_direction.x == -1 or snake_direction.y == -1:
		draw_line(snake_head_global_pos ,Vector2i(snake_head_global_pos.x, apple_global_pos.y), Color.CADET_BLUE, 8.0)
		draw_line(Vector2i(snake_head_global_pos.x, apple_global_pos.y) ,apple_global_pos, Color.CADET_BLUE, 8.0)
	elif snake_direction.x == 1 or snake_direction.y == 1:
		draw_line(snake_head_global_pos ,Vector2i(apple_global_pos.x, snake_head_global_pos.y), Color.CADET_BLUE, 8.0)
		draw_line(Vector2i(apple_global_pos.x, snake_head_global_pos.y) ,apple_global_pos, Color.CADET_BLUE, 8.0)
