class_name ResourceConfig;

static var woodAmount : int = 50;
static var stoneAmount : int = 0;
static var manaAmount : int = 0;

static func buildingWoodPrice(tileConfigID : TileConfig.TileConfigID) -> int:
	match (tileConfigID):
		# Mineables.
		TileConfig.TileConfigID._Tree: return 6;
		
		# Buildings.
		TileConfig.TileConfigID._Farm: return 24;
		TileConfig.TileConfigID._LookoutTower: return 24;
	return 0;
static func buildingStonePrice(tileConfigID : TileConfig.TileConfigID) -> int:
	match (tileConfigID):
		# Mineables.
		TileConfig.TileConfigID._Mountain: return 8;
		TileConfig.TileConfigID._Rock: return 3;
		TileConfig.TileConfigID._Core: return 5;
		
		# Buildings
		TileConfig.TileConfigID._Tombstone: return 24;
		TileConfig.TileConfigID._Farm: return 2;
		TileConfig.TileConfigID._LookoutTower: return 4;
	return 0;
static func buildingManaPrice(tileConfigID : TileConfig.TileConfigID) -> int:
	match (tileConfigID):
		# Mineables.
		TileConfig.TileConfigID._Core: return 24;
		
		# Buildings
		TileConfig.TileConfigID._Tombstone: return 10;
		TileConfig.TileConfigID._Farm: return 1;
		TileConfig.TileConfigID._ManaCollector: return 20;
	return 0;
	
static func canAffordBuilding(tileConfigID : TileConfig.TileConfigID) -> bool:
	return (
		buildingWoodPrice(tileConfigID) <= woodAmount && 
		buildingStonePrice(tileConfigID) <= stoneAmount &&
		buildingManaPrice(tileConfigID) <= manaAmount
	);

static func buyBuilding(tileConfigID : TileConfig.TileConfigID) -> bool:
	if (!canAffordBuilding(tileConfigID)): return false;
	
	# Update cost.
	woodAmount -= buildingWoodPrice(tileConfigID);
	stoneAmount -= buildingStonePrice(tileConfigID);
	manaAmount -= buildingManaPrice(tileConfigID);
	
	return true;
	
static func sellBuilding(tileConfigID : TileConfig.TileConfigID):
	# Update cost.
	woodAmount += buildingWoodPrice(tileConfigID);
	stoneAmount += buildingStonePrice(tileConfigID);
	manaAmount += buildingManaPrice(tileConfigID);
