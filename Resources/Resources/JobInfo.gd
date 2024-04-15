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

func _init(_jobType : JobType, _targetLocation : Vector2i):
	jobType = _jobType;
	targetLocation = _targetLocation;
	progressMax = getJobProgressMax(jobType);
	jobVisibility = getJobVisibility(jobType);

func progressJob(delta : float, environment : EnvironmentInfo) -> bool:	
	# Progress job.
	progress += delta;
	if (progress < progressMax): return false;
			
	# Finish job.
	match (jobType):
		JobInfo.JobType._Mining: environment.setTile(targetLocation, TileConfig.TileConfigID._Grass);	
		JobInfo.JobType._Sleeping: JobPool.addJob(self); 
	
	# Job finished.
	return true;

static func getJobProgressMax(jobType : JobType) -> int:
	match (jobType):
		#JobType._Mining: return 6;
		JobType._Sleeping: return 16;
	return 0;
static func getJobVisibility(jobType : JobType) -> bool:
	match (jobType):
		JobType._Sleeping: return false;
	return true;
