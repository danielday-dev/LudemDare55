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
		7: return EntityConfigID._Cat;
		12: return EntityConfigID._Dog;
		17: return EntityConfigID._Bat;	
		
		0, 1, 5, 6: return EntityConfigID._Player;
		10, 11, 15, 16: return EntityConfigID._SummonCircle;		
		
	return EntityConfigID._None;

static func getEntitySight(entityID : EntityConfigID) -> int:
	match (entityID):
		EntityConfigID._Skeleton: return 10;
		EntityConfigID._Player: return 5;
	
	return 0;
