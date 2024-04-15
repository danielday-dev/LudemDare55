extends PanelContainer
class_name StatsMenu;

@export var graphPolygon : Polygon2D = null;
const maxGraphExtent : float = 3.0;
const maxGraphRadius : float = 50.0;

func _ready():
	drawGraph([3,3,3,3,3]);

func showObject(entity : EntityInfo):
	if (entity == null): return;
	
	# Update stats.
	$VBoxContainer/HSplitContainer/Name.text = entity.name;
	drawGraph([
		entity.miningProficiency, 
		entity.farmingProficiency,
		entity.fightingProficiency,
		remap(entity.sleepingProficiency, 0.5, 2.0, 1.0, 3.0),
		entity.buildingProficiency,
	]);
	
	# Show.
	visible = true;
	
func drawGraph(data : Array[float]):
	if (graphPolygon == null): return;
	var arr = PackedVector2Array()
	var rotA : float = (PI * 2) / data.size() as float;
	for i : int in range(data.size()):
		var radius : float = (data[i] / maxGraphExtent) * maxGraphRadius;
		arr.push_back(Vector2(sin(rotA * i) * radius, -cos(rotA * i) * radius));
	graphPolygon.polygon = arr;
	
func closeMenu():
	# Hide.
	visible = false;
