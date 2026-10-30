extends Camera3D

var yaw := 0.65
var pitch := 0.27
var distance := 6.6
var target := Vector3(0, 0.95, 0)
var dragging := false

func _ready() -> void:
	update_view()

func reset_view() -> void:
	yaw = 0.65
	pitch = 0.27
	distance = 6.6
	update_view()

func update_view() -> void:
	position = target + Vector3(sin(yaw) * cos(pitch), sin(pitch), -cos(yaw) * cos(pitch)) * distance
	look_at(target)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		dragging = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			distance = clampf(distance - 0.4, 3.2, 10.0)
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distance = clampf(distance + 0.4, 3.2, 10.0)
	if event is InputEventMouseMotion and dragging:
		yaw -= event.relative.x * 0.008
		pitch = clampf(pitch + event.relative.y * 0.006, 0.06, 0.95)
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		reset_view()
	update_view()
