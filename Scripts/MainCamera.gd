extends Camera2D

@export var zoomRate : float = 1.1;
@export var zoomBounds : Vector2 = Vector2(0.5, 8);

var scrollAmount : int = 0;
func _process(delta):
	if (scrollAmount):
		# Update zoom.
		var newZoom = clamp(zoom.x * pow(zoomRate, scrollAmount), zoomBounds.x, zoomBounds.y);
		zoom = Vector2(newZoom, newZoom);
		
		# Reset scroll amount.
		scrollAmount = 0;

var dragged : bool = false;
var lastPosition : Vector2;
func _unhandled_input(event : InputEvent):
	if event is InputEventMouseButton:
		if (event.button_index == MOUSE_BUTTON_MIDDLE):
			dragged = event.pressed;
			lastPosition = event.position;
		elif (event.button_index == MOUSE_BUTTON_WHEEL_UP):
			scrollAmount += 1;
		elif (event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
			scrollAmount -= 1;
	elif event is InputEventMouseMotion:
		if (dragged):
			var moveAmount = event.position - lastPosition;
			position -= moveAmount / zoom;
			lastPosition = event.position;
