extends PanelContainer

@export var mainCamera : MainCamera;

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
	
	var menuGroup = ButtonGroup.new();
	menuGroup.allow_unpress = true;
	var typeGroup = ButtonGroup.new();
	typeGroup.allow_unpress = false;
	
	
	for button : BaseButton in toolButtons:
		if (button == null): continue;
		
		# Assign group.
		button.button_group = menuGroup;
		
		button.connect("toggled",
			func(toggled : bool):
				mainCamera.activeAction = MainCamera.Actions._Mining;
		)
	
	# Connect + group buttons.
	for button : BaseButton in menuButtons:
		if (button == null): continue;
		
		# Assign group.
		button.button_group = menuGroup;
		
		# Connect event.
		button.connect("toggled", 
			func(toggled : bool):
				_onHotbarButton(button, toggled);
		)
		
		for child in button.get_child(0).get_child(0).get_children():
			if (not child is BaseButton): continue;
			var cb : BaseButton = (child as BaseButton);
			cb.button_group = typeGroup;
			
			cb.connect("toggled", 
				func(toggled : bool): 
					_onHotbarItemSelectButton(cb, toggled);		
			);
		
		# Hide child by default.
		var child = button.get_child(0)
		if (child != null): child.visible = false;
	
func _onHotbarButton(toggledButton : BaseButton, toggled : bool):		
	# Get button child.
	var child = toggledButton.get_child(0)
	if (child == null): return;
	# Update child visibility.
	child.visible = toggled
	if (toggled && 
		mainCamera != null && 
		mainCamera.activeTile != TileConfig.TileConfigID._None):
		mainCamera.activeAction = MainCamera.Actions._Building;
	
func _onHotbarItemSelectButton(button : BaseButton, toggled : bool):
	if (mainCamera == null): return;
	
	if (!toggled): 
		mainCamera.activeAction = MainCamera.Actions._None;
	else:
		var tile : TileConfig.TileConfigID = TileConfig.TileConfigID._None;
		match (button.name):
			"Tombstone": tile = TileConfig.TileConfigID._Tombstone;		
			"Farm": tile = TileConfig.TileConfigID._Farm;		
			"ManaCollector": tile = TileConfig.TileConfigID._ManaCollector;		
			"LookoutTower": tile = TileConfig.TileConfigID._LookoutTower;		
		
		# Update camera.
		mainCamera.activeAction = MainCamera.Actions._Building;
		mainCamera.activeTile = tile; 
