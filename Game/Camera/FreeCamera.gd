class_name FreeCamera extends Camera2D

const DRAG_SPEED := 1.0
const KEY_SPEED := 1000
const ZOOM_SPEED := Vector2(0.1,0.1)
const MIN_ZOOM := Vector2(.02,.02)
const MAX_ZOOM := Vector2(8,8)

var dragging := false
var mousePos := Vector2.ZERO

signal zoomChanged(value:Vector2)

func _process(delta: float) -> void:
	var keyInput := Vector2.ZERO
	if Input.is_action_pressed("ui_left"):keyInput.x -= 1
	if Input.is_action_pressed("ui_right"):keyInput.x += 1
	if Input.is_action_pressed("ui_up"):keyInput.y -= 1
	if Input.is_action_pressed("ui_down"):keyInput.y += 1

	if keyInput != Vector2.ZERO:
		keyInput = keyInput.normalized()
		addPos(keyInput * KEY_SPEED * delta / zoom)

func _input(event: InputEvent) -> void:
	var oldMousePos := get_global_mouse_position()
	if(event.is_action_pressed("mouse_wheel_up")):
		zoom+=ZOOM_SPEED*zoom
		if(zoom > MAX_ZOOM) : zoom = MAX_ZOOM
		addPos(oldMousePos - get_global_mouse_position())
		zoomChanged.emit(zoom)
	elif(event.is_action_pressed("mouse_wheel_down")):
		zoom-=ZOOM_SPEED*zoom
		if(zoom < MIN_ZOOM) : zoom = MIN_ZOOM
		addPos(oldMousePos - get_global_mouse_position())
		zoomChanged.emit(zoom)
	
	if(event.is_action_pressed("middle_mouse")):
		dragging = true
		mousePos = event.position
	elif(event.is_action_released("middle_mouse")):
		dragging = false
	
	if dragging and event is InputEventMouseMotion:
		var delta:Vector2 = event.position - mousePos
		addPos(- delta * DRAG_SPEED / zoom)
		mousePos = event.position

func addPos(pos:Vector2)->void:
	global_position += pos
