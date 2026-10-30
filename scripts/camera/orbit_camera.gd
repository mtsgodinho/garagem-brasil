extends Camera3D

var yaw := 0.65
var pitch := 0.15
var distance := 6.1
var target := Vector3(0, 0.86, 0)
var dragging := false

func _ready() -> void:
	update_view()

func reset_view() -> void:
	target = Vector3(0,0.86,0)
	yaw = 0.65
	pitch = 0.15
	distance = 6.1
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

func focus_detail(part: String) -> void:
	var views := {
		"hood":[0.65,0.60,4.8,Vector3(0,1.0,-0.6)],
		"trunk":[2.65,0.35,5.4,Vector3(0,1.0,0.5)],
		"interior":[1.25,0.40,4.6,Vector3(0,1.0,0.12)],
	}
	if not views.has(part):
		return
	var view: Array = views[part]
	yaw = view[0]
	pitch = view[1]
	distance = view[2]
	target = view[3]
	dragging = false
	update_view()
