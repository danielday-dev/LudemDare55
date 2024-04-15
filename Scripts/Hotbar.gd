extends PanelContainer

var toolButtons : Array[BaseButton];
var menuButtons : Array[BaseButton];
func _ready():
	# Get buttons.
	toolButtons = [
		$GridContainer/Mining,
	];
	menuButtons = [
		$GridContainer/Housing,
		$GridContainer/Farming,
		$GridContainer/Utility,
		$GridContainer/Defence,
	];
	
	var group = ButtonGroup.new();
	group.allow_unpress = true;
	
	
	for button : BaseButton in toolButtons:
		if (button == null): continue;
		
		# Assign group.
		button.button_group = group;
	
	# Connect + group buttons.
	for button : BaseButton in menuButtons:
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
