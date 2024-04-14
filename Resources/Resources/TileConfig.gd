extends Node
class_name TileConfig;

enum TileConfigID {
	_None,
	_Mountain, _Rock,
	_Tree, _Water,
	_Flower, _Grass
};

static func getTileConfigID(tileID : int) -> TileConfigID:
	match (tileID):
		0: return TileConfigID._Mountain;
		1: return TileConfigID._Rock;
		2, 3: return TileConfigID._Tree;
		4: return TileConfigID._Water;
		5, 6, 7, 8: return TileConfigID._Flower;
		9, 10, 11, 12, 13, 14, 15: return TileConfigID._Grass;
	return TileConfigID._None;

static func randomizeTile(tileID : int) -> int:
	match (getTileConfigID(tileID)):
		TileConfigID._Tree: return randi_range(2, 3);
		TileConfigID._Flower: return randi_range(5, 8);
		TileConfigID._Grass: return randi_range(9, 15);
	return tileID;

static func getTileVisibility(tileConfigID : TileConfigID) -> int:
	match (tileConfigID):
		TileConfigID._Mountain: return 0;
		TileConfigID._Rock: return 1;
		TileConfigID._Tree: return 2;
	return 999;
	
static func isTileWalkable(tileConfigID : TileConfigID) -> int:
	match (tileConfigID):
		TileConfigID._Mountain, TileConfigID._Rock,	TileConfigID._Tree,	TileConfigID._Water: return false;
	
	return true;
