extends TileMap

var environmentState : Array[TileInfo];
var environmentWidth : int = 0; 
var environmentHeight : int = 0;
var activeSource : int = -1;

func _ready():
	readEnvironment();

func readEnvironment():		
	# Get environment information.
	var bounds : Rect2i = get_used_rect();
	environmentWidth = bounds.size.x - max(bounds.position.x, 0);
	environmentHeight = bounds.size.y - max(bounds.position.y, 0);
	
	# Read in cells.
	environmentState.resize(environmentWidth * environmentHeight);
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
				
				# Get source.
				if (activeSource == -1):
					activeSource = get_cell_source_id(0, cellPos);
				
				
			# Add cell to data.
			environmentState[x + (y * environmentWidth)] = TileInfo.new(
				tileID
			);
			
	# Reset.
	clear();
	writeEnvironment();
	
func writeEnvironment(): 
	var lightCenter : Vector2i = Vector2i(environmentWidth / 3, environmentHeight / 2);
	const lightDistance : int = 10;
	
	# Set terrain.
	for y in range(environmentHeight):
		for x in range(environmentWidth):
			# Get tile.
			var tile : TileInfo = environmentState[x + (y * environmentWidth)];
			if (tile.tileID == -1): 
				continue;
				
			var change = (lightCenter - Vector2i(x, y)).abs();
			var lighting = max(lightDistance - (change.length() as int), 0);
			if (lighting > 0):
				var tileLighting = max(3 - lighting, 0);
				# Set tile.
				set_cell(0, Vector2i(x, y), activeSource, Vector2i(tile.tileID, tileLighting));
			else:
				# Cell not visible.
				erase_cell(0, Vector2i(x, y));
