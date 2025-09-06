extends Node
# scripts/level_manager.gd

enum LevelType { MOVES, TIMED }

var level_type: int = LevelType.MOVES
var running: bool = false

var current_score: int = 0
var target_score: int = 0
var remaining_moves: int = 0
var remaining_time: int = 0

@onready var grid  = $"../grid" 
@onready var hud  = $"../top_ui"
@onready var timer := Timer.new()

func _ready() -> void:
	# preparar timer para niveles TIMED
	add_child(timer)
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.timeout.connect(_on_timer_tick)

	# 🔹 conectar señales del grid
	if grid:
		if grid.has_signal("swap_started"):
			grid.swap_started.connect(_on_grid_swap_started)
		if grid.has_signal("match_resolved"):
			grid.match_resolved.connect(_on_grid_match_resolved)
	else:
		print("⚠️ LevelManager no encontró el nodo grid")

	# 🔹 iniciar prueba en modo MOVES
	start_moves_level(500, 5)
	

func start_moves_level(target: int, moves: int) -> void:
	level_type = LevelType.MOVES
	running = true
	current_score = 0
	target_score = target
	remaining_moves = moves
	remaining_time = 0

	if hud:
		hud.set_mode_moves()
		hud.set_score(current_score)
		hud.set_moves(remaining_moves)

	timer.stop() 

func start_timed_level(target: int, seconds: int) -> void:
	level_type = LevelType.TIMED
	running = true
	current_score = 0
	target_score = target
	remaining_moves = 0
	remaining_time = max(0, seconds)

	if hud:
		hud.set_mode_timed()
		hud.set_score(current_score)
		hud.set_time(remaining_time)

	timer.start()  

func _on_timer_tick() -> void:
	if not running: return
	if level_type != LevelType.TIMED: return

	remaining_time -= 1
	if hud:
		hud.set_time(remaining_time)

	if remaining_time <= 0:
		timer.stop()
		running = false
		
func _on_grid_swap_started() -> void:
	if not running: 
		return
	if level_type == LevelType.MOVES:
		remaining_moves -= 1
		if hud: 
			hud.set_moves(remaining_moves)


func _on_grid_match_resolved(points: int, cascade: int) -> void:
	if not running: 
		return
	current_score += points
	if hud: 
		hud.set_score(current_score)
		
		
