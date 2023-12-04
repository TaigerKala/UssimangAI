extends TileMap

const SNAKE_ID := 0

func draw_snake(layer, coords, id, atlas_coords, snake_body) -> void:
	for block in snake_body:
		self.set_cell(layer, coords, id, atlas_coords)
		
