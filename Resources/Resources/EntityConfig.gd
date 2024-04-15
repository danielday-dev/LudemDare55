extends Node
class_name EntityConfig;

enum EntityConfigID {
	_None,
	_Skeleton, _Cat, _Dog, _Bat,
	_Player, _SummonCircle,
	_Tombstone, _Farm, _LookoutTower, _ManaCollector,
};

static func getEntityTile(entityID : EntityConfigID) -> int:
	match (entityID):
		EntityConfigID._Skeleton: return 2;
		
		EntityConfigID._Player: return 0;
		EntityConfigID._SummonCircle: return 10;
		
		EntityConfigID._Tombstone: return 7;
		EntityConfigID._Farm: return 8;
		EntityConfigID._LookoutTower: return 9;	
		EntityConfigID._ManaCollector: return 12;	
	return -1;
		
static func getEntityConfigID(tileID : int) -> EntityConfigID:
	match (tileID):
		2: return EntityConfigID._Skeleton;
		
		0, 1, 5, 6: return EntityConfigID._Player;
		10, 11, 15, 16: return EntityConfigID._SummonCircle;		
		
		7: return EntityConfigID._Tombstone;
		8: return EntityConfigID._Farm;
		9: return EntityConfigID._LookoutTower;	
		12: return EntityConfigID._ManaCollector;	
		
	return EntityConfigID._None;

static func getEntitySight(entityID : EntityConfigID) -> int:
	match (entityID):
		EntityConfigID._Skeleton: return 10;
		EntityConfigID._Player: return 5;
		EntityConfigID._Tombstone: return 3;
		EntityConfigID._LookoutTower: return 20;
		EntityConfigID._ManaCollector: return 2;
	return 0;
