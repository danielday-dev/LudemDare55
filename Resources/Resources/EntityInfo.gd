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
		
		if (!activeJob.progressJob(delta * jobProficiency, environment)):
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
	
	var targetPos : Vector2i = activeJob.targetLocation;
	if (targetPos == position): return;
	
	# Path find.
	var pathPos : Vector2i = position;
	while (pathPos != targetPos):
		if (pathPos.x < targetPos.x): pathPos.x += 1;
		elif (pathPos.x > targetPos.x): pathPos.x -= 1;
		elif (pathPos.y < targetPos.y): pathPos.y += 1;
		elif (pathPos.y > targetPos.y): pathPos.y -= 1;
		if (pathPos != targetPos): activePath.push_back(pathPos);
	
