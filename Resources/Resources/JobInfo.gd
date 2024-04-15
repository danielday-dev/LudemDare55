extends Node
class_name JobInfo

enum JobType {
	_None,
	_Mining, 
	_Farming,
	_Building,
	_Fighting,
	_Sleeping,
}

# Common variables.
var jobType : JobType;
var targetLocation : Vector2i;
var jobVisibility = true;
var progress : float = 0;
var progressMax : float = 0;
var jobEntity : EntityInfo = null;
var jobRepeat : bool = false;

# Job specific variables.
var buildingTarget : TileConfig.TileConfigID = TileConfig.TileConfigID._Grass;

func _init(_jobType : JobType, _targetLocation : Vector2i):
	jobType = _jobType;
	targetLocation = _targetLocation;
	progressMax = getJobProgressMax(jobType);

func progressJob(delta : float, entity : EntityInfo, environment : EnvironmentInfo) -> bool:	
	# On job start.
	if (jobEntity != null):
		jobEntity.visible = true;
	
	# Progress job.
	progress += delta;
	if (progress < progressMax): return false;
			
	# Finish job.
	match (jobType):
		JobInfo.JobType._Mining: 
			var tile : TileConfig.TileConfigID = environment.getTile(targetLocation);
			environment.setTile(targetLocation, TileConfig.getMineTileDrop(tile));	
			ResourceConfig.sellBuilding(tile);
		JobInfo.JobType._Building: 
			environment.setTile(targetLocation, buildingTarget);
		JobInfo.JobType._Farming: 
			if (jobEntity != null):
				jobEntity.visible = false;
				jobEntity.farmRemaining = EntityInfo.farmGrowthTime + randf_range(-10.0, 10.0);
				jobEntity = null;
				match(environment.getTile(targetLocation)):
					TileConfig.TileConfigID._Farm: ResourceConfig.woodAmount += 4;
					TileConfig.TileConfigID._ManaCollector: ResourceConfig.manaAmount += 9;
		JobInfo.JobType._Sleeping: 
			entity.tiredness = 0;
	
	# Handle repeat jobs.
	if (jobRepeat):
		# Duplicate job.
		var job = JobInfo.new(jobType, targetLocation);
		job.jobRepeat = jobRepeat;
		job.jobVisibility = jobVisibility;
		job.buildingTarget = buildingTarget;
		if (jobEntity != null):
			job.jobEntity = EntityInfo.new(jobEntity.entityID, jobEntity.position);
			job.jobEntity.visible = false;
			environment.addEntity(job.jobEntity);
		JobPool.addJob(job); 
	
	# Cleanup entity.
	if (jobEntity != null):
		for i : int in range(environment.entities.size()):
			if (environment.entities[i] == jobEntity):
				environment.entities.pop_at(i);
				break;
		
	# Job finished.
	return true;

static func getJobProgressMax(jobType : JobType) -> int:
	match (jobType):
		JobType._Mining: return 1;#20;
		JobType._Farming: return 10;
		JobType._Building: return 1;#45;
		JobType._Fighting: return 20;
		JobType._Sleeping: return 10;
	return 0;
