extends PanelContainer

var entity : EntityInfo = null;
@export var statsMenu : StatsMenu = null;

func setEntity(_entity : EntityInfo):
	entity = _entity;
	$VBoxContainer/Name.text = entity.name;

var mouseOver = false
func _input(event):
	if event is InputEventMouseButton && mouseOver:
		var ev : InputEventMouseButton = event as InputEventMouseButton;
		if (ev.button_index == MOUSE_BUTTON_LEFT && !ev.pressed):
			if (entity != null && statsMenu != null):
				statsMenu.showObject(entity);

func mouseEntered():
	mouseOver = true
func mouseExited():
	mouseOver = false

