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
		2, 3, 4: return EntityConfigID._Skeleton;
		
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
	
static func getRandomEntityName() -> String:
	const names : Array[String] = [
		"Boney",
		"Bonathon",
		"Skelliot",
		"Maxilla",
		"Elboliver",
		"Tombone",
		"Keith",
		"Boen",
		"Timbia",
		"Boneard",
		"Saccrum",
		"Ulniver",
		"Footzgerald",
		"Wilbone",
		"Vertibrad",
		"Incusteve",
		"Sacrumwell",
		"Kenney",
		"Karadaniel",
		"Kokoronaldo",
		"Bodylan",
		"Amandible",
		"Fibulana",
		"Clairvicle",
		"Patella",
		"Mandibleth",
		"Mandiblethany",
		"Marrowena",
		"Marrowyn",
		"Janium",
		"Tibia",
		"Penelopelvis",
		"Calliopelvis",
		"Delilium",
		"Army",
		"Karen",
		"Yubianca",
		"Ericarpal",
		"Bonelope",
	];
	const titles : Array[String] = [
		"the Strong",
		"the Boney",
		"the Tired",
		"the Unresting",
		"the Ribler",
	];
		
	if (names.is_empty() || titles.is_empty()): return "UNNAMED";
	return names.pick_random() + " " + titles.pick_random();
