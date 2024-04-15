extends Camera2D
class_name MainCamera;

@export var zoomRate : float = 1.1;
@export var zoomBounds : Vector2 = Vector2(0.5, 8);

@export var cursor : Node2D = null;
@export var jobIconPrefab : PackedScene = null;
@export var environment : EnvironmentInfo = null;

enum Actions {
	_None,
	_Ping,
	_Mining, _Building
};
var activeAction : Actions = Actions._None;
var activeTile : TileConfig.TileConfigID;

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
		elif (event.button_index == MOUSE_BUTTON_LEFT):	
			if (cursor != null && !event.pressed && environment):
				var pos = Vector2i(cursor.position / EnvironmentInfo.tileSize);
				
				match (activeAction):
					Actions._Ping:
						if (TileConfig.isTileWalkable(environment.getTile(pos))):
							# Ping job.
							var job : JobInfo = JobInfo.new(JobInfo.JobType._Fighting, pos);
							if (jobIconPrefab != null):
								job.jobIcon = jobIconPrefab.instantiate();
								job.jobIcon.find_child("Ping").visible = true;
								job.jobIcon.position = pos * EnvironmentInfo.tileSize;
								environment.add_child(job.jobIcon);
							JobPool.addJob(job);
							
					Actions._Mining:
						if (TileConfig.isTileMineable(environment.getTile(pos))):
							# Mining job.
							var job : JobInfo = JobInfo.new(JobInfo.JobType._Mining, pos);
							if (jobIconPrefab != null):
								job.jobIcon = jobIconPrefab.instantiate();
								job.jobIcon.find_child("Mining").visible = true;
								job.jobIcon.position = pos * EnvironmentInfo.tileSize;
								environment.add_child(job.jobIcon);
							JobPool.addJob(job);
						
					Actions._Building:
						if (TileConfig.isTileWalkable(environment.getTile(pos)) && 
							ResourceConfig.buyBuilding(activeTile)):
							# Building job.
							
							environment.setTile(pos, TileConfig.TileConfigID._BuildingSite);
							var job = JobInfo.new(JobInfo.JobType._Building, pos);
							job.buildingTarget = activeTile;
							if (jobIconPrefab != null):
								job.jobIcon = jobIconPrefab.instantiate();
								job.jobIcon.find_child("Building").visible = true;
								job.jobIcon.position = pos * EnvironmentInfo.tileSize;
								environment.add_child(job.jobIcon);
							JobPool.addJob(job);	
							
							
	elif event is InputEventMouseMotion:
		if (dragged):
			var moveAmount = event.position - lastPosition;
			position -= moveAmount / zoom;
			lastPosition = event.position;
		else: 
			if (cursor != null):
				cursor.visible = true;
				var remapped : Vector2 = Vector2(
					remap(event.position.x, 0, 640, -320, 320),
					remap(event.position.y, 0, 360, -180, 180),
				) / zoom;					
				cursor.position = (Vector2i((position + remapped) / EnvironmentInfo.tileSize)) * EnvironmentInfo.tileSize;
