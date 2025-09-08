extends Node2D
@export var color: String = ""
@export var piece_type: int = 0
var matched = false

func _ready():
	if color == null or color == "":
		color = "unknown_" + str(self.get_instance_id())
	if has_node("Sprite2D"):
		$Sprite2D.visible = true
		$Sprite2D.modulate = Color(1,1,1,1)

func move(target):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", target, 0.4)

func dim():
	if has_node("Sprite2D"):
		$Sprite2D.modulate = Color(1,1,1,0.5)

func activate_special():
	match piece_type:
		1:
			explode_row()
		2:
			explode_column()
		3:
			explode_adjacent()
		4:
			explode_rainbow()

func explode_row():
	var grid = get_parent()
	var pos = grid.pixel_to_grid(position.x, position.y)
	var row = int(pos.y)
	for x in range(grid.width):
		var p = grid.all_pieces[x][row]
		if p != null:
			p.queue_free()
			grid.all_pieces[x][row] = null

func explode_column():
	var grid = get_parent()
	var pos = grid.pixel_to_grid(position.x, position.y)
	var col = int(pos.x)
	for y in range(grid.height):
		var p = grid.all_pieces[col][y]
		if p != null:
			p.queue_free()
			grid.all_pieces[col][y] = null

func explode_adjacent():
	var grid = get_parent()
	var pos = grid.pixel_to_grid(position.x, position.y)
	var cx = int(pos.x)
	var cy = int(pos.y)
	for x in range(cx - 1, cx + 2):
		for y in range(cy - 1, cy + 2):
			if grid.in_grid(x, y):
				var p = grid.all_pieces[x][y]
				if p != null:
					p.queue_free()
					grid.all_pieces[x][y] = null

func explode_rainbow():
	var grid = get_parent()
	var target_color = color
	for x in range(grid.width):
		for y in range(grid.height):
			var p = grid.all_pieces[x][y]
			if p != null and (p.color == target_color or p.piece_type != 0):
				p.queue_free()
				grid.all_pieces[x][y] = null
