extends TileMap
class_name EnvironmentInfo

@export var skeletonStatsMenu : StatsMenu = null;
@export var skeletonInformationPanel : Control = null;
@export var skeletonInformationPrefab : PackedScene;

const tileSize = 16;

const entitySource = 0;
const entitySourceWidth = 5;
var entities : Array[EntityInfo];

const tileSource = 1;
var environmentState : Array[TileInfo];
var environmentLighting : Array[float];
var environmentWidth : int = 0; 
var environmentHeight : int = 0;

func _ready():
	# Initialize environment.
	readEnvironment();
	
	# Test jobs.
	for y in range(environmentHeight):
		for x in range(environmentWidth):
			var pos : Vector2i = Vector2i(x, y);
			var tile : TileConfig.TileConfigID = getTile(pos);
			if (tile != TileConfig.TileConfigID._None):
				setTile(pos, tile);
				
	# Draw.
	generateLighting();
	writeEnvironment();

var lightingTick : float = 0;
var processTick : float = 0;
@export var lightingDegradeRate : float = 0.2;
@export var lightingDegradeCooldown : float = 1.0;
@export var processCooldown : float = 0.4;
func _process(delta):
	# State update efficiency flags.
	var updateEnvironment : bool = false;
	var tickLighting : bool = false;
	
	# TODO: Remove code.
	# Move first test entity.
	var dx : int = (1 if Input.is_action_just_pressed("ui_right") else 0) - (1 if Input.is_action_just_pressed("ui_left") else 0);
	var dy : int = (1 if Input.is_action_just_pressed("ui_down") else 0) - (1 if Input.is_action_just_pressed("ui_up") else 0);
	if (dx != 0 || dy != 0):
		entities[0].position += Vector2i(dx, dy);
		updateEnvironment = true;
		
	# Handle lighting tick.
	lightingTick -= delta;
	if (lightingTick <= 0): 
		# Reset tick.
		lightingTick = lightingDegradeCooldown;
		# Update lighting.
		tickLighting = true;
	
	
	
	# Handle process tick.
	var entityTick = false;
	processTick -= delta;
	if (processTick <= 0): 
		# Reset tick.
		processTick = processCooldown;
		# Update environmnet.
		entityTick = true;
		updateEnvironment = true;
	
	# Process entities.
	for e in entities:
		e._process(delta, self, entityTick);

	# Update environment;
	if (!updateEnvironment && !tickLighting): return;
	generateLighting(lightingDegradeRate if tickLighting else 0);
	writeEnvironment();

func readEnvironment():			
	# Get environment information.
	var bounds : Rect2i = get_used_rect();
	environmentWidth = bounds.size.x - max(bounds.position.x, 0);
	environmentHeight = bounds.size.y - max(bounds.position.y, 0);
	
	# Generate buffers.
	environmentState.resize(environmentWidth * environmentHeight);
	environmentLighting.resize(environmentWidth * environmentHeight);
	environmentLighting.fill(0);
	
	# Read in cells.
	for y in range(environmentHeight):
		for x in range(environmentWidth):
			# Get cell info.
			var cellPos : Vector2i = Vector2i(x, y);			
			var atlasPos : Vector2i = get_cell_atlas_coords(0, cellPos);
			var source : int = get_cell_source_id(0, cellPos);
			var index : int = x + (y * environmentWidth);
			
			match (source):
				entitySource:
					# Get entities.
					addEntity(EntityInfo.new(atlasPos.x + (atlasPos.y * entitySourceWidth), cellPos));
					# Set default tile.
					environmentState[index] = TileInfo.new(TileConfig.getTileID(TileConfig.TileConfigID._Water));
				
				_, tileSource:			
					# Setup data.
					var tileID = -1; 
					# Set data.
					if (atlasPos != null): 
						tileID = TileConfig.randomizeTile(atlasPos.x);
					# Add cell to data.
					environmentState[index] = TileInfo.new(tileID);
	
class LightingInfo:
	var position : Vector2i;
	var brightness : int;
	func _init(_position : Vector2i, _brightness : int):
		position = _position;
		brightness = _brightness;
func generateLighting(degradeAmount : float = 0):
	# Degrade lighting.
	if (degradeAmount > 0):
		for y in range(environmentHeight):
			for x in range(environmentWidth):
				var index : int = x + (y * environmentWidth);
				environmentLighting[index] = clamp(environmentLighting[index] - degradeAmount, 0, 3);
	
	# Setup lighting.
	var activeLighting : Array[LightingInfo];
	for e : EntityInfo in entities:
		if (!e.visible): continue;
		
		# Check in bounds.
		if (e.position.x < 0 || e.position.y < 0 || 
			e.position.x >= environmentWidth || e.position.y >= environmentHeight): continue;
		
		# Get entity ID.
		var entityID = EntityConfig.getEntityConfigID(e.entityID);
		if (entityID == EntityConfig.EntityConfigID._None): continue;
		
		# Get lighting amount.
		var brightness = EntityConfig.getEntitySight(entityID);
		if (brightness <= 0): continue;
		
		# Add to lighting.
		activeLighting.push_back(LightingInfo.new(e.position, brightness));
	
	# Process lighting.
	while (!activeLighting.is_empty()):
		# Find largest.
		var bestLight : int = 0;
		for i : int in range(1, activeLighting.size()):
			if (activeLighting[bestLight].brightness < activeLighting[i].brightness):
				bestLight = i;
		var brightest : LightingInfo = activeLighting.pop_at(bestLight);
		
		# Calculate remaining brightness.
		var remainingBrightness : int = min(brightest.brightness - 1, TileConfig.getTileVisibility(TileConfig.getTileConfigID(environmentState[brightest.position.x + (brightest.position.y * environmentWidth)].tileID)));
		if (remainingBrightness <= 0): continue;
		
		# Process largest.
		const checks : Array[Vector2i] = [
			Vector2i(-1, 0), Vector2i(1, 0),	
			Vector2i(0, -1), Vector2i(0, 1),	
		];
		for check : Vector2i in checks:
			# Get pos.
			var pos : Vector2i = brightest.position + check; 
			if (pos.x < 0 || pos.y < 0 || pos.x >= environmentWidth || pos.y >= environmentHeight): continue;
			
			# Check environment.
			var index : int = pos.x + (pos.y * environmentWidth);
			if (environmentLighting[index] >= remainingBrightness): continue;
			
			# Update lighting.
			environmentLighting[index] = remainingBrightness;
			activeLighting.push_back(LightingInfo.new(pos, remainingBrightness));

func writeEnvironment(): 
	# Clear terrain.
	clear();
	
	# Set terrain.
	for y : int in range(environmentHeight):
		for x : int in range(environmentWidth):
			var index : int = x + (y * environmentWidth);
			
			# Get tile.
			var tile : TileInfo = environmentState[index];
			if (tile.tileID == -1): 
				continue;
				
			var lighting : float = ceilf(environmentLighting[index]);
			if (lighting > 0):
				var tileLighting = max(3.0 - lighting, 0);
				# Set tile.
				set_cell(0, Vector2i(x, y), tileSource, Vector2i(tile.tileID, tileLighting));
			else:
				# Cell not visible.
				erase_cell(0, Vector2i(x, y));
	
	# Place entities.
	for e : EntityInfo in entities:
		if (!e.visible): continue;
		
		# Handle mutliple skeletons on one spot.
		if (get_cell_source_id(0, e.position) == entitySource && 
			get_cell_tile_data(0, e.position).terrain == EntityConfig.getEntityTile(EntityConfig.EntityConfigID._Skeleton)):
			set_cell(0, Vector2i(e.position.x, e.position.y), entitySource, Vector2i(get_cell_atlas_coords(0, e.position).x + 1, e.entityID / 4));
		else:
			set_cell(0, Vector2i(e.position.x, e.position.y), entitySource, Vector2i(e.entityID % entitySourceWidth, e.entityID / entitySourceWidth));

func getTile(pos : Vector2i) -> TileConfig.TileConfigID:
	# Check if in bounds.
	if (pos.x < 0 || pos.y < 0 || 
		pos.x >= environmentWidth || pos.y >= environmentHeight): 
		return TileConfig.TileConfigID._None;
	# Return tile id.
	return TileConfig.getTileConfigID(environmentState[pos.x + (pos.y * environmentWidth)].tileID);

func setTile(pos : Vector2i, tileConfigID : TileConfig.TileConfigID):
	# Check if in bounds.
	if (pos.x < 0 || pos.y < 0 || 
		pos.x >= environmentWidth || pos.y >= environmentHeight): 
		return;
	
	# Fix any old stuffs.
	match (environmentState[pos.x + (pos.y * environmentWidth)].tileID):
		_: pass; 
		
	# Update tile.
	environmentState[pos.x + (pos.y * environmentWidth)].tileID = TileConfig.getTileID(tileConfigID);
	
	# Perform any further actions.
	match (tileConfigID):
		TileConfig.TileConfigID._Tombstone:
			var job : JobInfo = JobInfo.new(JobInfo.JobType._Sleeping, pos);
			job.jobVisibility = false;
			job.jobRepeat = true;
			job.jobEntity = EntityInfo.new(EntityConfig.getEntityTile(EntityConfig.EntityConfigID._Tombstone), pos);
			job.jobEntity.visible = false;
			addEntity(job.jobEntity);
			JobPool.addJob(job);
			addEntity(EntityInfo.new(EntityConfig.getEntityTile(EntityConfig.EntityConfigID._Skeleton), pos));
		
		TileConfig.TileConfigID._LookoutTower:
			var job : JobInfo = JobInfo.new(JobInfo.JobType._Fighting, pos);
			job.jobVisibility = false;
			job.jobRepeat = true;
			job.jobEntity = EntityInfo.new(EntityConfig.getEntityTile(EntityConfig.EntityConfigID._LookoutTower), pos);
			job.jobEntity.visible = false;
			addEntity(job.jobEntity);
			JobPool.addJob(job);
			
		TileConfig.TileConfigID._Farm:
			var entity : EntityInfo = EntityInfo.new(EntityConfig.getEntityTile(EntityConfig.EntityConfigID._Farm), pos);
			entity.visible = false;
			addEntity(entity);
		TileConfig.TileConfigID._ManaCollector:
			var entity : EntityInfo = EntityInfo.new(EntityConfig.getEntityTile(EntityConfig.EntityConfigID._ManaCollector), pos);
			entity.visible = false;
			addEntity(entity);
		
	
func findNearestTile(center : Vector2i, tileConfigID : TileConfig.TileConfigID) -> Vector2i:
	# Find nearest.
	var nearestDistance : int = -1;
	var nearest : Vector2i = center;
	for y : int in range(environmentHeight):
		for x : int in range(environmentWidth):
			var pos : Vector2i = Vector2i(x, y);
			
			# Check for matching tile.
			if (getTile(pos) != tileConfigID): continue;
			
			# Compare to nearest.
			var change = pos - center;
			var distance = abs(change.x) + abs(change.y);
			if (nearestDistance == -1 || nearestDistance > distance):
				# Update distance.
				nearestDistance = distance;
				nearest = pos;
	
	# Return nearest.
	return nearest;

func addEntity(entity : EntityInfo):
	if (EntityConfig.getEntityConfigID(entity.entityID) == EntityConfig.EntityConfigID._Skeleton):
		if (skeletonInformationPanel != null && 
			skeletonStatsMenu != null &&
			skeletonInformationPrefab != null):
			skeletonInformationPanel.visible = true;
			var prefab = skeletonInformationPrefab.instantiate();
			prefab.setEntity(entity);
			prefab.statsMenu = skeletonStatsMenu;
			skeletonInformationPanel.get_child(0).get_child(0).add_child(prefab);
	entities.push_back(entity);
	
	
