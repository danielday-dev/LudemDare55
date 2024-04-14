extends Node
class_name EntityConfig;

enum EntityConfigID {
	_None,
	_Skeleton, _Cat, _Dog, _Bat,
	_Player, _SummonCircle
};

static func getEntityConfigID(tileID : int) -> EntityConfigID:
	match (tileID):
		2: return EntityConfigID._Skeleton;
		6: return EntityConfigID._Cat;
		10: return EntityConfigID._Dog;
		14: return EntityConfigID._Bat;	
		
		0, 1, 4, 5: return EntityConfigID._Player;
		8, 9, 12, 13: return EntityConfigID._SummonCircle;		
		
	return EntityConfigID._None;

static func getEntitySight(entityID : EntityConfigID) -> int:
	match (entityID):
		EntityConfigID._Skeleton: return 10;
	
	return 0;
