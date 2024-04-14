extends TileMap

const entitySource = 0;
var entities : Array[EntityInfo];

const tileSource = 1;
var environmentState : Array[TileInfo];
var environmentLighting : Array[int];
var environmentWidth : int = 0; 
var environmentHeight : int = 0;

func _ready():
	# Initialize environment.
	readEnvironment();
	
	# initialize entities.
	entities.push_back(EntityInfo.new(2, Vector2i(10, 10)));
	entities.push_back(EntityInfo.new(2, Vector2i(25, 10)));
	
	# Draw.
	generateLighting();
	writeEnvironment();

func _process(_delta):
	var dx : int = (1 if Input.is_action_just_pressed("ui_right") else 0) - (1 if Input.is_action_just_pressed("ui_left") else 0);
	var dy : int = (1 if Input.is_action_just_pressed("ui_down") else 0) - (1 if Input.is_action_just_pressed("ui_up") else 0);
	
	if (dx != 0 || dy != 0):
		entities[0].position += Vector2i(dx, dy);
		generateLighting();
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
			
			# Setup data.
			var tileID = -1; 
			# Set data.
			if (atlasPos != null): 
				tileID = atlasPos.x;
								
			# Add cell to data.
			environmentState[x + (y * environmentWidth)] = TileInfo.new(
				tileID
			);
	
class LightingInfo:
	var position : Vector2i;
	var brightness : int;
	func _init(_position : Vector2i, _brightness : int):
		position = _position;
		brightness = _brightness;
	static func _custom_sort(a : LightingInfo, b : LightingInfo) -> bool:
		return a.brightness < b.brightness
func generateLighting():
	# Clear lighting.
	environmentLighting.fill(0);
	
	# Setup lighting.
	var activeLighting : Array[LightingInfo];
	for e : EntityInfo in entities:
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
		activeLighting.sort_custom(LightingInfo._custom_sort);
		var brightest : LightingInfo = activeLighting.pop_back();
		
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
				
			var lighting : int = environmentLighting[index];
			if (lighting > 0):
				var tileLighting = max(3 - lighting, 0);
				# Set tile.
				set_cell(0, Vector2i(x, y), tileSource, Vector2i(tile.tileID, tileLighting));
			else:
				# Cell not visible.
				erase_cell(0, Vector2i(x, y));
	
	# Place entities.
	for e : EntityInfo in entities:
		set_cell(0, Vector2i(e.position.x, e.position.y), entitySource, Vector2i(e.entityID % 4, e.entityID / 4));