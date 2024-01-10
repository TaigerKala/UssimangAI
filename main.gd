extends Node2D

const SNAKE_ID = 0
const SNAKE_LAYER = 0
const APPLE_ID = 1
const APPLE_LAYER = 1

@onready var objektid = $Objektid
@onready var snake_timer = $SnakeTimer

var apple_pos: Vector2i
var snake_direction := Vector2i(1, 0)
var snake_body_positions := [Vector2i(5, 10), Vector2i(4, 10), Vector2i(3, 10)]
var bite_apple := false
var snake_timer_stop := false

# A* algoritmi muutujad
var open_set := []
var closed_set := []
var came_from := {}
var g_score := {}
var f_score := {}

func heuristic_cost_estimate(current, goal) -> float:
	return abs(current.x - goal.x) + abs(current.y - goal.y)

func get_lowest_f_score(nodes) -> Vector2i:
	var lowest = nodes[0]
	for node in nodes:
		if f_score[node] < f_score[lowest]:
			lowest = node
	return lowest

func reconstruct_path(came_from, current) -> void:
	var total_path = [current]
	while came_from.has(current):
		current = came_from[current]
		total_path.append(current)

	total_path.reverse()

	if total_path.size() > 1:
		snake_direction = total_path[1] - snake_body_positions[0]
		if came_from[current] == snake_body_positions[1]:
			snake_direction *= -1

func get_neighbors(node) -> Array:
	var neighbors = []
	for dir in [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]:
		var neighbor = node + dir
		if neighbor.x >= 0 and neighbor.x < 20 and neighbor.y >= 0 and neighbor.y < 20:
			neighbors.append(neighbor)
	return neighbors

func _ready() -> void:
	apple_pos = place_apple()
	snake_timer.timeout.connect(_on_timeout)
	draw_apple()

	# Muutke ussi algne suund siin
	snake_direction = Vector2i(1, 0)

func _input(event: InputEvent):
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
	return Vector2i(x, y)

func draw_apple() -> void:
	delete_tiles(APPLE_LAYER)
	objektid.set_cell(APPLE_LAYER, apple_pos, APPLE_ID, Vector2i(0, 0))

func draw_snake() -> void:
	delete_tiles(SNAKE_LAYER)
	for block in snake_body_positions:
		objektid.set_cell(SNAKE_LAYER, block, SNAKE_ID, Vector2i(2, 0))

func move_snake() -> void:
	if bite_apple:
		var body_copy = snake_body_positions.slice(0, snake_body_positions.size())
		var new_head = body_copy[0] + snake_direction
		body_copy.insert(0, new_head)
		snake_body_positions = body_copy
		bite_apple = false
	else:
		delete_tiles(SNAKE_LAYER)
		var start = snake_body_positions[0]
		var goal = apple_pos

		open_set = [start]
		came_from = {}
		g_score = {start: 0}
		f_score = {start: heuristic_cost_estimate(start, goal)}

		while open_set.size() > 0:
			var current = get_lowest_f_score(open_set)

			if current == goal:
				reconstruct_path(came_from, current)
				break

			open_set.erase(current)
			closed_set.append(current)

			for neighbor in get_neighbors(current):
				if closed_set.find(neighbor) != -1:
					continue

				var tentative_g_score = g_score[current] + 1

				if !g_score.has(neighbor) or tentative_g_score < g_score[neighbor]:
					came_from[neighbor] = current
					g_score[neighbor] = tentative_g_score
					f_score[neighbor] = g_score[neighbor] + heuristic_cost_estimate(neighbor, goal)

					if open_set.find(neighbor) == -1:
						open_set.append(neighbor)

		if came_from.has(start):
			snake_direction = start - snake_body_positions[0]

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
	if head.x > 19 or head.x < 0 or head.y < 0 or head.y > 19:
		game_over()
	for block in snake_body_positions.slice(1, snake_body_positions.size() - 1):
		if block == head:
			game_over()

func game_over() -> void:
	snake_timer.stop()
	print("Põrge")
