class_name JobPool

# Jobs.
static var miningJobs : Array[JobInfo];
static var farmingJobs : Array[JobInfo];
static var buildingJobs : Array[JobInfo];
static var fightingJobs : Array[JobInfo];
static var sleepingJobs : Array[JobInfo];

class JobSpec:
	var jobs : Array[JobInfo];
	var weight : float;
	func _init(_jobs : Array[JobInfo], _weight : float):
		jobs = _jobs;
		weight = _weight;
	static func _sort_custom(a : JobSpec, b : JobSpec):
		return a.weight > b.weight;

static func takeJob(entity : EntityInfo, environment : EnvironmentInfo) -> JobInfo:
	# Get job priority.
	var jobPriority : Array[JobSpec] = [
		JobSpec.new(miningJobs, entity.miningProficiency),
		JobSpec.new(farmingJobs, entity.farmingProficiency),
		JobSpec.new(buildingJobs, entity.buildingProficiency),
		JobSpec.new(fightingJobs, entity.fightingProficiency),
		# Sleeping when not doing anything else is a vibe.
		JobSpec.new(sleepingJobs, entity.tiredness), 
	];
	jobPriority.sort_custom(JobSpec._sort_custom);
	
	# Handle jobs.
	for jobSpec in jobPriority:
		# TODO: Ignore unskilled labour lol.
		# if (jobSpec.weight <= 0): break;
	
		# Find closest job.
		var closestJob : int = findClosestJob(entity.position, jobSpec.jobs, environment);
		if (closestJob < 0): continue;
		# Pop job.
		return jobSpec.jobs.pop_at(closestJob);
	
	# Failed to find job.
	print(sleepingJobs.size());
	return null;

class ClosestInfo:
	var position : Vector2i;
	var distance : int;
	func _init(_position : Vector2i, _distance : int):
		position = _position;
		distance = _distance;
static var activeClosestData : Array[int];
static func findClosestJob(center : Vector2i, jobs : Array[JobInfo], environment : EnvironmentInfo) -> int:
	# Ignore if no jobs available.
	if (jobs.is_empty()): return -1;
	if (activeClosestData.is_empty()):
		activeClosestData.resize(environment.environmentWidth * environment.environmentHeight);
	
	# Clear data.
	activeClosestData.fill(-999);
	var jobIndex : int = 0;
	for job : JobInfo in jobs:
		var index : int = job.targetLocation.x + (job.targetLocation.y * environment.environmentWidth);
		activeClosestData[index] = jobIndex;
		jobIndex += 1;
	
	# TODO: Flood fill your mom.
	var activeClosest : Array[ClosestInfo];
	activeClosest.push_back(ClosestInfo.new(center, -1));
	activeClosestData[center.x + (center.y * environment.environmentWidth)] = -1;
	
	# Process closest.
	while (!activeClosest.is_empty()):
		# Find largest.
		var closest : ClosestInfo = activeClosest.pop_front();
		var newDistance : int = closest.distance - 1;
		
		# Process largest.
		const checks : Array[Vector2i] = [
			Vector2i(-1, 0), Vector2i(1, 0),	
			Vector2i(0, -1), Vector2i(0, 1),	
		];
		for check : Vector2i in checks:
			# Get pos.
			var pos : Vector2i = closest.position + check; 
			if (pos.x < 0 || pos.y < 0 || 
				pos.x >= environment.environmentWidth || pos.y >= environment.environmentHeight): 
				continue;
			
			# Check environment.
			var index : int = pos.x + (pos.y * environment.environmentWidth);
			if (activeClosestData[index] >= 0): return activeClosestData[index];
			if (activeClosestData[index] >= newDistance): continue;
			if (!TileConfig.isTileWalkable(TileConfig.getTileConfigID(environment.environmentState[index].tileID))): continue;
			
			# Update closest.
			activeClosestData[index] = newDistance;
			activeClosest.push_back(ClosestInfo.new(pos, newDistance));
	
	# No jobs accessible.
	return -1;

static func addJob(job : JobInfo):
	match (job.jobType):
		JobInfo.JobType._Mining: miningJobs.push_back(job);
		JobInfo.JobType._Farming: farmingJobs.push_back(job);
		JobInfo.JobType._Building: buildingJobs.push_back(job);
		JobInfo.JobType._Fighting: fightingJobs.push_back(job);
		JobInfo.JobType._Sleeping: sleepingJobs.push_back(job);
