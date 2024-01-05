# Madu jaoks mänguväli grid
var grid = [
	[0, 0, 0, 0, 0], # 0 tähendab vaba ruutu
	[0, 1, 1, 1, 0], # 1 tähendab seina
	[0, 1, 0, 0, 0],
	[0, 0, 0, 1, 1],
	[0, 1, 0, 0, 0]
]

# A* algoritmi implementatsioon
func astar(start, goal):
	var open_set = [start]  # Hoiab avatud (uuritavate) sõlmede listi
	var came_from = {}      # Hoiab teekonda iga sõlme jaoks

	var g_score = {}        # Hoiab parimat teadaolevat kaugust lähtesõlmest
	g_score[start] = 0

	var f_score = {}        # Hoiab parimat teadaolevat kaugust + hinnangut eesmärgi suunas
	f_score[start] = heuristic(start, goal)

	while open_set:
		var current = get_lowest_f_score(open_set, f_score)
		if current == goal:
			return reconstruct_path(came_from, current)

		open_set.erase(current)

		for neighbor in get_neighbors(current):
			var tentative_g_score = g_score[current] + 1
			if not g_score.has(neighbor) or tentative_g_score < g_score[neighbor]:
				came_from[neighbor] = current
				g_score[neighbor] = tentative_g_score
				f_score[neighbor] = g_score[neighbor] + heuristic(neighbor, goal)

				if not open_set.has(neighbor):
					open_set.append(neighbor)

	return null

func heuristic(a, b):
	return abs(a.x - b.x) + abs(a.y - b.y)  # Lihtne hinnang kaugusele eesmärgi suunas

func get_lowest_f_score(nodes, scores):
	var lowest = nodes[0]
	for node in nodes:
		if scores[node] < scores[lowest]:
			lowest = node
	return lowest

func get_neighbors(node):
	var neighbors = []
	for dir in [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]:
		var neighbor = node + dir
		if is_valid(neighbor):
			neighbors.append(neighbor)
	return neighbors

func is_valid(node):
	return node.x >= 0 and node.x < len(grid[0]) and node.y >= 0 and node.y < len(grid)

func reconstruct_path(came_from, current):
	var path = [current]
	while came_from.has(current):
		current = came_from[current]
		path.append(current)
	return path
