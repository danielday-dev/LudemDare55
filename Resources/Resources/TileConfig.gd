extends Node
class_name TileConfig;

enum TileConfigID {
	_None,
	_Mountain, _Rock, _Core,
	_Tree, _Water,
	_Flower, _Grass, _Stones,
	_Player,
	
	_BuildingSite,
	_LookoutTower,
	_Farm,
	_Tombstone, 
	_ManaCollector,
};

static func getTileConfigID(tileID : int) -> TileConfigID:
	match (tileID):
		0: return TileConfigID._Mountain;
		1: return TileConfigID._Rock;
		2, 3: return TileConfigID._Tree;
		4: return TileConfigID._Water;
		5, 6, 7, 8: return TileConfigID._Flower;
		9, 10, 11, 12, 13, 14, 15: return TileConfigID._Grass;
		16, 17, 18: return TileConfigID._Stones;
		19: return TileConfigID._Player;
		20: return TileConfigID._Core;
		21: return TileConfigID._BuildingSite;
		22: return TileConfigID._LookoutTower;
		23, 24: return TileConfigID._Farm;
		25: return TileConfigID._Tombstone;
		26: return TileConfigID._ManaCollector;
		
	return TileConfigID._None;

static func getTileID(tileConfigID : TileConfigID) -> int:
	var tileID = -1;
	match (tileConfigID):
		TileConfigID._Mountain: tileID = 0;
		TileConfigID._Rock: tileID = 1;
		TileConfigID._Tree: tileID = 2;
		TileConfigID._Water: tileID = 4;
		TileConfigID._Flower: tileID = 5;
		TileConfigID._Grass: tileID = 9;
		TileConfigID._Stones: tileID = 16;
		TileConfigID._Player: tileID = 19;
		TileConfigID._Core: tileID = 20;
		TileConfigID._BuildingSite: tileID = 21;
		TileConfigID._LookoutTower: tileID = 22;
		TileConfigID._Farm: tileID = 23;
		TileConfigID._Tombstone: tileID = 25;
		TileConfigID._ManaCollector: tileID = 26;
		
	return randomizeTile(tileID);
static func randomizeTile(tileID : int) -> int:
	match (getTileConfigID(tileID)):
		TileConfigID._Tree: return randi_range(2, 3);
		TileConfigID._Flower: return randi_range(5, 8);
		TileConfigID._Grass: return randi_range(9, 15);
		TileConfigID._Stones: return randi_range(16, 18);
	return tileID;

static func getTileVisibility(tileConfigID : TileConfigID) -> int:
	match (tileConfigID):
		TileConfigID._Mountain: return 0;
		TileConfigID._Rock: return 1;
		TileConfigID._Tree: return 2;
	return 999;
	
static func isTileWalkable(tileConfigID : TileConfigID) -> bool:
	match (tileConfigID):
		TileConfigID._Flower, TileConfigID._Grass, TileConfigID._Stones, TileConfigID._Tombstone: 
			return true;
	return false;
	
static func isTileMineable(tileConfigID : TileConfigID) -> bool:
	match (tileConfigID):
		TileConfigID._Mountain, TileConfigID._Rock,	TileConfigID._Core, TileConfigID._Tree: return true;
	return false;

static func getMineTileDrop(tileConfigID : TileConfigID) -> TileConfigID:
	match (tileConfigID):
		TileConfigID._Mountain, TileConfigID._Rock, TileConfigID._Core: return TileConfigID._Stones;
	return TileConfigID._Grass;
