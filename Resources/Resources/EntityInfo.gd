extends Object
class_name EntityInfo

# Entity information.
var entityID : int = -1;
var position : Vector2i;
var activePath : Array[Vector2i];
var visible = true;

# Job choices.
var activeJob : JobInfo = null;
var activeJobProgressBarPrefab : PackedScene = preload("res://Prefabs/ProgressBar.tscn");
var activeJobProgressBar : Node2D = null;

# Personality stuff.
var miningProficiency : float = 1.0;
var farmingProficiency : float = 1.0;
var buildingProficiency : float = 1.0;
var fightingProficiency : float = 1.0;
var sleepingProficiency : float = 1.0;

# Other.
var tiredness : float = 0;

func _init(_entityID : int, _position : Vector2i):
	entityID = _entityID;
	position = _position;
	
	match (EntityConfig.getEntityConfigID(entityID)):
		EntityConfig.EntityConfigID._Skeleton:
			miningProficiency = randf_range(1.0, 3.0);
			farmingProficiency = randf_range(1.0, 3.0);
			buildingProficiency = randf_range(1.0, 3.0);
			fightingProficiency = randf_range(1.0, 3.0);
			sleepingProficiency = randf_range(0.5, 2.0);

func _process(delta : float, environment : EnvironmentInfo, tick : bool):
	match (EntityConfig.getEntityConfigID(entityID)):
		EntityConfig.EntityConfigID._Skeleton: _processSkeleton(delta, environment, tick);
	
func _processSkeleton(delta : float, environment : EnvironmentInfo, tick : bool):
	# Walk path.
	if (!activePath.is_empty()):
		if (tick): position = activePath.pop_front();
		return;
	
	# Try perform job.
	if (activeJob != null && 
		activeJob.jobType != JobInfo.JobType._None): 
		
		var jobProficiency : float = 1.0;
		match (activeJob.jobType):
			JobInfo.JobType._Mining: jobProficiency = miningProficiency;
			JobInfo.JobType._Farming: jobProficiency = farmingProficiency;
			JobInfo.JobType._Building: jobProficiency = buildingProficiency;
			JobInfo.JobType._Fighting: jobProficiency = fightingProficiency;
			JobInfo.JobType._Sleeping: jobProficiency = sleepingProficiency;		
		
		if (!activeJob.progressJob(delta * jobProficiency, self, environment)):
			visible = activeJob.jobVisibility;
			# Update progress bar.		
			if (activeJobProgressBar == null):
				activeJobProgressBar = activeJobProgressBarPrefab.instantiate();
				environment.add_child(activeJobProgressBar);
				activeJobProgressBar.position = activeJob.targetLocation * EnvironmentInfo.tileSize;
			if (activeJobProgressBar.setProgress):
				activeJobProgressBar.setProgress(activeJob.progress / activeJob.progressMax);
			return;
	# Cleanup progress bar.
	if (activeJobProgressBar != null):
		activeJobProgressBar.queue_free();
		activeJobProgressBar = null;
		
	# Reset.
	visible = true;		
	if (!tick): 
		activeJob = null;
		return;
	
	# Decide job next.
	activeJob = JobPool.takeJob(self, environment);
	if (activeJob == null || activeJob.jobType == JobInfo.JobType._None): return;
	findPath(activeJob.targetLocation, environment);
	
class PathNode:
	var position : Vector2i;
	var startCost : int;
	var heuristic : int;
	var path : PackedByteArray;
	func _init(_position : Vector2i, _startCost : int, _endDistance : int, _pathDirection : int, _path : PackedByteArray):
		position = _position;
		startCost = _startCost;
		heuristic = startCost + _endDistance;		
		path = _path.duplicate();
		if (_pathDirection >= 0): path.append(_pathDirection);
func manDistance(from : Vector2i, to : Vector2i) -> int:
	return abs(from.x - to.x) + abs(from.y - to.y);
static var activeClosestData : Array[int];
func findPath(target : Vector2i, environment : EnvironmentInfo):
	if (target == position): return;
	
	# Setup data.
	if (activeClosestData.is_empty()):
		activeClosestData.resize(environment.environmentWidth * environment.environmentHeight);
	activeClosestData.fill(999);
	
	# Setup nodes.
	var activeNodes : Array[PathNode];
	activeNodes.push_back(PathNode.new(position, 0, manDistance(position, target), -1, []));
	activeClosestData[position.x + (position.y * environment.environmentWidth)] = manDistance(position, target);
	
	# Checks.
	const checks : Array[Vector2i] = [
		Vector2i(-1, 0), Vector2i(1, 0),	
		Vector2i(0, -1), Vector2i(0, 1),	
	];
	
	# Find best path.
	var bestPath = -1;
	while (!activeNodes.is_empty()):
		bestPath = 0;
		for i : int in range(1, activeNodes.size()):
			if (activeNodes[i].heuristic < activeNodes[bestPath].heuristic):
				bestPath = i;
			
		# Get best node.
		if (activeNodes[bestPath].position == target): 
			print("target found?");
			break;
		var bestNode : PathNode = activeNodes.pop_at(bestPath);
		bestPath = -1;
	
		for i : int in range(0, checks.size()):
			var pos : Vector2i = bestNode.position + checks[i];
			if (pos.x < 0 || pos.y < 0 || 
				pos.x >= environment.environmentWidth || pos.y >= environment.environmentHeight): continue;
			
			var index : int = pos.x + (pos.y * environment.environmentWidth);
			var endDist : int = manDistance(pos, target);
			var heuristic : int = bestNode.startCost + 1 + endDist;
			if (activeClosestData[index] <= heuristic): continue;
			if (!TileConfig.isTileWalkable(TileConfig.getTileConfigID(environment.environmentState[index].tileID)) &&
				pos != target): continue;
	
			activeClosestData[index] = heuristic;
			activeNodes.push_back(PathNode.new(pos, bestNode.startCost + 1, endDist, i, bestNode.path));
	
	# Check if failed to find path.
	if (activeNodes.is_empty() || bestPath == -1): return;
		
	# Trace path.
	var startPos : Vector2i = position;
	for i : int in range(activeNodes[bestPath].path.size() - 1):
		startPos += checks[activeNodes[bestPath].path[i]];
		activePath.push_back(startPos);

