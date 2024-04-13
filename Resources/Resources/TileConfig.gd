extends Node

enum TileConfigID {
	_None,
	_Mountain, _Rock,
	_Tree, _Water,
	_Flower, _Grass
};

func getTileEnum(tileID : int) -> TileConfigID:
	match (tileID):
		0: return TileConfigID._Mountain;
		1: return TileConfigID._Rock;
		2, 3: return TileConfigID._Tree;
		4: return TileConfigID._Water;
		5, 6, 7, 8: return TileConfigID._Flower;
		9, 10, 11, 12, 13, 14, 15: return TileConfigID._Grass;
	return TileConfigID._None;

func getTileVisibleRange(tileConfigID : TileConfigID) -> int:
	match (tileConfigID):
		TileConfigID._Mountain: return 0;
		TileConfigID._Rock: return 1;
		TileConfigID._Tree: return 2;
	
	return 99;
	
func isTileWalkable(tileConfigID : TileConfigID) -> int:
	match (tileConfigID):
		TileConfigID._Mountain, TileConfigID._Rock,	TileConfigID._Tree,	TileConfigID._Water: return false;
	
	return true;
