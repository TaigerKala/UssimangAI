extends Node2D

const SNAKE = 0
const APPLE = 1

@onready var objektid = $Objektid

var apple_pos: Vector2i
var snake_body = [Vector2i(5,10), Vector2i(4,10), Vector2i(3,10)]

func _ready() -> void:
	apple_pos = place_apple()
	draw_snake()
	
func _process(_delta) -> void:
	if Input.is_action_just_pressed("LMB"):
		draw_apple()
		place_apple()
	
func place_apple() -> Vector2:
	randomize()
	var x := randi_range(0, 19)
	var y := randi_range(0, 19)
	return Vector2i(x,y)

func draw_apple() -> void:
	objektid.set_cell(0, apple_pos, APPLE,Vector2i(0,0))
	

