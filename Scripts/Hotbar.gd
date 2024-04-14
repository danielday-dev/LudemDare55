extends PanelContainer

var buttons : Array[BaseButton];
func _ready():
	# Get buttons.
	buttons = [
		$GridContainer/Housing,
		$GridContainer/Farming,
		$GridContainer/Utility,
		$GridContainer/Defence,
	];
	
	# Connect + group buttons.
	var group = ButtonGroup.new();
	group.allow_unpress = true;
	for button : BaseButton in buttons:
		if (button == null): continue;
		
		# Assign group.
		button.button_group = group;
		
		# Connect event.
		button.connect("toggled", 
			func(toggled : bool):
				_onHotbarButton(button, toggled);
		)
		
		# Hide child by default.
		var child = button.get_child(0)
		if (child != null): child.visible = false;
	
func _onHotbarButton(toggledButton : BaseButton, toggled : bool):		
	# Get button child.
	var child = toggledButton.get_child(0)
	if (child == null): return;
	
	# Update child visibility.
	child.visible = toggled
	
func _onHotbarItemSelectButton(button : Button):
	# TODO: Sent back to environment manager or somin.
	
	pass;
