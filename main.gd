extends Node

const SNAKE_LAYER = 0
const SNAKE_ID = 1
const APPLE_ID = 2

var snake_body_positions = [Vector2(10, 10), Vector2(10, 11), Vector2(10, 12)]
var snake_direction = Vector2(0, -1)
var gridmap
var apple_pos
var snake_timer
var pathfinding

func _ready():
	gridmap = $GridMap
	snake_timer = $SnakeTimer
	snake_timer.wait_time = 0.1
	snake_timer.start()
	
	apple_pos = place_apple()
	draw_snake()
	draw_apple()

	pathfinding = $Pathfinding  # Access the Pathfinding node

	# Initialize the grid
	for x in range(20):
		for y in range(20):
			var pos = Vector2(x, y)
			gridmap.set_cell(SNAKE_LAYER, pos, 1)  # Set the entire grid as walkable

	snake_timer.connect("timeout", self, "_on_timeout")

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
	gridmap.clear_layer(SNAKE_LAYER)
	var head = snake_body_positions[0]
	for block in snake_body_positions:
		if block == head:
			gridmap.set_cell(SNAKE_LAYER, block, SNAKE_ID)
		else:
			gridmap.set_cell(SNAKE_LAYER, block, SNAKE_ID, Vector2i(1, 0))
	update_walkable_areas()

func draw_apple():
	gridmap.clear_layer(SNAKE_LAYER)
	gridmap.set_cell(SNAKE_LAYER, apple_pos, APPLE_ID)

func _on_timeout():
	var path = pathfinding.get_simple_path(snake_body_positions[0], apple_pos, true)
	var new_head = snake_body_positions[0] + snake_direction  # Declare new_head at the start of the function

	if path.size() > 1:
		# Move the snake towards the next position in the path
		var next_position = path[1]
		snake_direction = (next_position - snake_body_positions[0]).normalized()
		new_head = snake_body_positions[0] + snake_direction  # Update new_head based on path

	# Check for collision with itself or boundaries
	if new_head in snake_body_positions or new_head.x < 0 or new_head.x >= 20 or new_head.y < 0 or new_head.y >= 20:
		snake_timer.stop()
		# Handle game over condition here
		return

	if path.size() > 1:
		# Move the snake towards the next position in the path
		var next_position = path[1]
		snake_direction = (next_position - snake_body_positions[0]).normalized()

		# Check for collision with itself or boundaries
		if new_head in snake_body_positions or new_head.x < 0 or new_head.x >= 20 or new_head.y < 0 or new_head.y >= 20:
			snake_timer.stop()
			# Handle game over condition here
			return
	else:
		# No valid path or snake has reached the apple, handle accordingly
		snake_timer.stop()
		# Handle game over or victory condition here
		return

	# Update the snake's position
	snake_body_positions.insert(0, new_head)
	if new_head == apple_pos:
		apple_pos = place_apple()
		draw_apple()
	else:
		var tail = snake_body_positions.pop_back()
		gridmap.set_cell(SNAKE_LAYER, tail, -1)

	draw_snake()

func update_walkable_areas():
	# Tehtud hetkel nii et grid oleks 20x20 aga seda peab muutma siis vastavalt actual suurusele
	for x in range(20):
		for y in range(20):
			var pos = Vector2(x, y)
			if pos in snake_body_positions:
				# Mark as unwalkable
				gridmap.set_cell(SNAKE_LAYER, pos.x, pos.y, -1) # -1 or any other value to denote unwalkable
			else:
				# Mark as walkable
				gridmap.set_cell(SNAKE_LAYER, pos.x, pos.y, 0) # 0 or any other value to denote walkable
