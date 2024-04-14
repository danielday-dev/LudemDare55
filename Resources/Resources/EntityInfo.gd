extends Object
class_name EntityInfo

@export var entityID : int = -1;
@export var position : Vector2i;

func _init(_entityID : int, _position : Vector2i):
	entityID = _entityID;
	position = _position;
