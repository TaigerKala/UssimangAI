extends Node

const SNAKE_LAYER = 0
const SNAKE_ID = 1
const APPLE_ID = 2

var snake_body_positions = [Vector2(10, 10), Vector2(10, 11), Vector2(10, 12)]
var snake_direction = Vector2(0, -1)
var objektid

var apple_pos
var snake_timer

func _ready():
	objektid = $TileMap
	snake_timer = Timer.new()
	snake_timer.wait_time = 0.1
	snake_timer.connect("timeout", self, "_on_timeout")
	add_child(snake_timer)

	apple_pos = place_apple()
	draw_snake()
	draw_apple()
	snake_timer.start()

func place_apple():
	var empty_spaces = []
	for x in range(20):
		for y in range(20):
			var pos = Vector2(x, y)
			if pos not in snake_body_positions:
				empty_spaces.append(pos)
	
	if empty_spaces:
		return empty_spaces[randi() % empty_spaces.size()]
	else:
		return Vector2(-1, -1)

func draw_snake():
	objektid.clear_layer(SNAKE_LAYER)
	var head = snake_body_positions[0]
	for block in snake_body_positions:
		if block == head:
			objektid.set_cell(SNAKE_LAYER, block, SNAKE_ID)
		else:
			objektid.set_cell(SNAKE_LAYER, block, SNAKE_ID, Vector2i(1, 0))

func draw_apple():
	objektid.clear_layer(SNAKE_LAYER)
	objektid.set_cell(SNAKE_LAYER, apple_pos, APPLE_ID)

func _on_timeout():
	var new_head = snake_body_positions[0] + snake_direction
	if new_head in snake_body_positions or new_head.x < 0 or new_head.x >= 20 or new_head.y < 0 or new_head.y >= 20:
		snake_timer.stop()
		return
	snake_body_positions.insert(0, new_head)
	if new_head == apple_pos:
		apple_pos = place_apple()
		draw_apple()
	else:
		var tail = snake_body_positions.pop_back()
		objektid.set_cell(SNAKE_LAYER, tail, -1)
	draw_snake()
