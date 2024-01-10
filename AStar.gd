extends Node

class AStar:

	var points = []
	var connections = {}

	func add_point(id, position):
		points.append({"id": id, "position": position})
		connections[id] = []

	func connect_points(id1, id2, bidirectional):
		if bidirectional:
			connections[id1].append(id2)
			connections[id2].append(id1)
		else:
			connections[id1].append(id2)

	func has_point(id):
		return id in connections

	func get_point_path(start_id, end_id):
		var open_set = [start_id]
		var came_from = {}
		var g_score = {start_id: 0}
		var f_score = {start_id: heuristic_cost_estimate(start_id, end_id)}

		while open_set:
			var current = get_lowest_f_score(open_set, f_score)
			if current == end_id:
				return reconstruct_path(came_from, current)

			open_set.remove(current)
			for neighbor in connections[current]:
				var tentative_g_score = g_score[current] + dist_between(current, neighbor)
				if neighbor not in g_score or tentative_g_score < g_score[neighbor]:
					came_from[neighbor] = current
					g_score[neighbor] = tentative_g_score
					f_score[neighbor] = g_score[neighbor] + heuristic_cost_estimate(neighbor, end_id)
					if neighbor not in open_set:
						open_set.append(neighbor)

		return []

	func heuristic_cost_estimate(id, goal_id):
		var pos1 = get_point_position(id)
		var pos2 = get_point_position(goal_id)
		return abs(pos1.x - pos2.x) + abs(pos1.y - pos2.y)

	func dist_between(id1, id2):
		var pos1 = get_point_position(id1)
		var pos2 = get_point_position(id2)
		return abs(pos1.x - pos2.x) + abs(pos1.y - pos2.y)

	func get_lowest_f_score(open_set, f_score):
		var lowest = open_set[0]
		for point in open_set:
			if f_score[point] < f_score[lowest]:
				lowest = point
		return lowest

	func get_point_position(id):
		for point in points:
			if point["id"] == id:
				return point["position"]

	func reconstruct_path(came_from, current):
		var total_path = [current]
		while current in came_from:
			current = came_from[current]
			total_path.append(current)
		return total_path.reversed()

	func clear():
		points.clear()
		connections.clear()
