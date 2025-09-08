extends Node2D

enum {WAIT, MOVE}
var state

@export var width: int = 8
@export var height: int = 8
@export var x_start: int = 64
@export var y_start: int = 800
@export var offset: int = 64
@export var y_offset: int = 6

var normal_pieces = [
	preload("res://scenes/blue_piece.tscn"),
	preload("res://scenes/green_piece.tscn"),
	preload("res://scenes/light_green_piece.tscn"),
	preload("res://scenes/pink_piece.tscn"),
	preload("res://scenes/yellow_piece.tscn"),
	preload("res://scenes/orange_piece.tscn")
]

var special_pieces = {
	1: {"blue": preload("res://scenes/blue_row_piece.tscn"),
		"green": preload("res://scenes/green_row_piece.tscn"),
		"lightgreen": preload("res://scenes/light_green_row_piece.tscn"),
		"pink": preload("res://scenes/pink_row_piece.tscn"),
		"yellow": preload("res://scenes/yellow_row_piece.tscn"),
		"orange": preload("res://scenes/orange_row_piece.tscn")},
	2: {"blue": preload("res://scenes/blue_column_piece.tscn"),
		"green": preload("res://scenes/green_column_piece.tscn"),
		"lightgreen": preload("res://scenes/light_green_column_piece.tscn"),
		"pink": preload("res://scenes/pink_column_piece.tscn"),
		"yellow": preload("res://scenes/yellow_column_piece.tscn"),
		"orange": preload("res://scenes/orange_column_piece.tscn")},
	3: {"blue": preload("res://scenes/blue_adjacent_piece.tscn"),
		"green": preload("res://scenes/green_adjacent_piece.tscn"),
		"lightgreen": preload("res://scenes/light_green_adjacent_piece.tscn"),
		"pink": preload("res://scenes/pink_adjacent_piece.tscn"),
		"yellow": preload("res://scenes/yellow_adjacent_piece.tscn"),
		"orange": preload("res://scenes/orange_adjacent_piece.tscn")},
	4: preload("res://scenes/rainbow_piece.tscn")
}

var all_pieces = []
var piece_one = null
var piece_two = null
var last_place = Vector2.ZERO
var last_direction = Vector2.ZERO
var move_checked = false

var first_touch = Vector2.ZERO
var final_touch = Vector2.ZERO
var is_controlling = false

const BASE_PIECE_POINTS: int = 10
var current_cascade_index: int = 0
var last_destroyed_count: int = 0

signal swap_started()
signal match_resolved(points: int, cascade: int)

func _ready():
	state = MOVE
	randomize()
	all_pieces = make_2d_array()
	spawn_initial_pieces()

func make_2d_array():
	var arr = []
	for i in range(width):
		arr.append([])
		for j in range(height):
			arr[i].append(null)
	return arr

func grid_to_pixel(c,r):
	return Vector2(x_start + offset*c, y_start - offset*r)

func pixel_to_grid(px,py):
	return Vector2(round((px-x_start)/offset), round((y_start-py)/offset))

func in_grid(c,r):
	return c>=0 and c<width and r>=0 and r<height

func spawn_initial_pieces():
	for i in range(width):
		for j in range(height):
			var piece = spawn_random_normal()
			add_child(piece)
			piece.position = grid_to_pixel(i,j)
			all_pieces[i][j] = piece
	check_all_matches_after_spawn()

func spawn_random_normal():
	var idx = randi_range(0, normal_pieces.size()-1)
	var piece = normal_pieces[idx].instantiate()
	piece.piece_type = 0
	return piece

func touch_input():
	var mouse = get_global_mouse_position()
	var g = pixel_to_grid(mouse.x, mouse.y)
	if Input.is_action_just_pressed("ui_touch") and in_grid(g.x,g.y):
		first_touch = g
		is_controlling = true
	if Input.is_action_just_released("ui_touch") and in_grid(g.x,g.y) and is_controlling:
		is_controlling = false
		final_touch = g
		touch_difference(first_touch, final_touch)

func swap_pieces(c,r,d):
	var nx = int(c+d.x)
	var ny = int(r+d.y)
	if not in_grid(nx,ny): return
	var a=all_pieces[c][r]
	var b=all_pieces[nx][ny]
	if a==null or b==null: return
	state = WAIT
	piece_one = a
	piece_two = b
	last_place = Vector2(c,r)
	last_direction = d
	all_pieces[c][r] = b
	all_pieces[nx][ny] = a
	a.move(grid_to_pixel(nx,ny))
	b.move(grid_to_pixel(c,r))
	emit_signal("swap_started")
	if not move_checked:
		find_matches()

func swap_back():
	if piece_one!=null and piece_two!=null:
		swap_pieces(int(last_place.x),int(last_place.y),last_direction)
	state = MOVE
	move_checked = false

func touch_difference(g1,g2):
	var diff = g2-g1
	if abs(diff.x) > abs(diff.y):
		if diff.x > 0: swap_pieces(int(g1.x), int(g1.y), Vector2(1,0))
		elif diff.x < 0: swap_pieces(int(g1.x), int(g1.y), Vector2(-1,0))
	else:
		if diff.y > 0: swap_pieces(int(g1.x), int(g1.y), Vector2(0,1))
		elif diff.y < 0: swap_pieces(int(g1.x), int(g1.y), Vector2(0,-1))

func _process(delta):
	if state == MOVE:
		touch_input()

func find_matches():
	var specials_to_spawn = []
	for i in range(width):
		for j in range(height):
			var p = all_pieces[i][j]
			if p == null: continue
			var c = p.color
			var hseq = [p]
			for k in range(1,width-i):
				var np = all_pieces[i+k][j]
				if np != null and np.color == c: hseq.append(np)
				else: break
			if hseq.size() >= 3:
				for idx in range(hseq.size()):
					if hseq.size() == 4 and idx == 1:
						specials_to_spawn.append({"type":1, "pos":grid_to_pixel(i+1,j), "color":c, "grid":Vector2(i+1,j)})
					elif hseq.size() >= 5 and idx == 2:
						specials_to_spawn.append({"type":4, "pos":grid_to_pixel(i+2,j), "color":c, "grid":Vector2(i+2,j)})
					else:
						hseq[idx].matched = true
						hseq[idx].dim()
			var vseq = [p]
			for k in range(1,height-j):
				var np = all_pieces[i][j+k]
				if np != null and np.color == c: vseq.append(np)
				else: break
			if vseq.size() >= 3:
				for idx in range(vseq.size()):
					if vseq.size() == 4 and idx == 1:
						specials_to_spawn.append({"type":2, "pos":grid_to_pixel(i,j+1), "color":c, "grid":Vector2(i,j+1)})
					elif vseq.size() >= 5 and idx == 2:
						specials_to_spawn.append({"type":4, "pos":grid_to_pixel(i,j+2), "color":c, "grid":Vector2(i,j+2)})
					else:
						vseq[idx].matched = true
						vseq[idx].dim()
	get_parent().get_node("destroy_timer").start()
	for sp in specials_to_spawn:
		var special_piece
		if sp["type"] in [1,2,3]:
			special_piece = special_pieces[sp["type"]][sp["color"]].instantiate()
		else:
			special_piece = special_pieces[4].instantiate()
		special_piece.color = sp["color"]
		special_piece.position = sp["pos"]
		add_child(special_piece)
		all_pieces[int(sp["grid"].x)][int(sp["grid"].y)] = special_piece

func destroy_matched():
	var destroyed = 0
	for i in range(width):
		for j in range(height):
			var p = all_pieces[i][j]
			if p != null and p.matched:
				if p.piece_type == 1:
					for x in range(width):
						if all_pieces[x][j]!=null: all_pieces[x][j].queue_free(); all_pieces[x][j]=null
				elif p.piece_type == 2:
					for y in range(height):
						if all_pieces[i][y]!=null: all_pieces[i][y].queue_free(); all_pieces[i][y]=null
				elif p.piece_type in [3,4]:
					p.activate_special()
				p.queue_free()
				all_pieces[i][j] = null
				destroyed += 1
	last_destroyed_count = destroyed
	move_checked = true
	if destroyed>0:
		get_parent().get_node("collapse_timer").start()
	else:
		swap_back()

func collapse_columns():
	for i in range(width):
		for j in range(height):
			if all_pieces[i][j] == null:
				for k in range(j+1,height):
					if all_pieces[i][k] != null:
						all_pieces[i][k].move(grid_to_pixel(i,j))
						all_pieces[i][j] = all_pieces[i][k]
						all_pieces[i][k] = null
						break
	get_parent().get_node("refill_timer").start()

func refill_columns():
	for i in range(width):
		for j in range(height):
			if all_pieces[i][j] == null:
				var piece = spawn_random_normal()
				add_child(piece)
				piece.position = grid_to_pixel(i,j+y_offset)
				piece.move(grid_to_pixel(i,j))
				all_pieces[i][j] = piece
	find_matches()
	if last_destroyed_count>0:
		get_parent().get_node("destroy_timer").start()

func check_all_matches_after_spawn():
	find_matches()

func _on_destroy_timer_timeout():
	destroy_matched()
	if last_destroyed_count>0:
		emit_signal("match_resolved", last_destroyed_count*BASE_PIECE_POINTS, current_cascade_index)

func _on_collapse_timer_timeout():
	collapse_columns()

func _on_refill_timer_timeout():
	refill_columns()

func game_over():
	state = WAIT
