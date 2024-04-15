extends PanelContainer

func _process(delta):
	$HBoxContainer/WoodLabel.text = str(ResourceConfig.woodAmount);
	$HBoxContainer/StoneLabel.text = str(ResourceConfig.stoneAmount);
	$HBoxContainer/ManaLabel.text = str(ResourceConfig.manaAmount);
