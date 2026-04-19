# Copyright (c) 2026 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name CoreData extends CoreGlobal
## Class to manage custom data types


## Enum for Type
enum Type {
	NULL,				## Represents no value (null / None)
	ANY,				## Represents a Variant any type
	STRING,				## A standard text string
	BOOL,				## A true/false boolean value
	INT,				## A 64-bit integer number
	FLOAT,				## A floating-point number
	ARRAY,				## A dynamic array of values
	DICTIONARY,			## A key/value map (hash table)
	VECTOR2,			## A 2D vector (x, y) with floats
	VECTOR2I,			## A 2D vector (x, y) with integers
	RECT2,				## A 2D rectangle defined by position and size (floats)
	RECT2I,				## A 2D rectangle defined by position and size (integers)
	VECTOR3,			## A 3D vector (x, y, z) with floats
	VECTOR3I,			## A 3D vector (x, y, z) with integers
	VECTOR4,			## A 4D vector (x, y, z, w) with floats
	VECTOR4I,			## A 4D vector (x, y, z, w) with integers
	COLOR,				## A color with red, green, blue, and alpha channels
	OBJECT,				## A reference to any Godot Object (Node, Resource, etc.)
	CALLABLE,			## A callable function reference
	SIGNAL,				## A signal reference (connectable event)
	ENUM,				## An enumerator
	BITFLAGS,			## Bit Flags
	IP,					## An IP address
	INPUTEVENT,			## An InputEvent
	SETTINGSMANAGER,	## A SettingsManager
	PACKEDSCENE,		## A PackedScene object
	ACTION,				## An Action that can be triggred
}

## Enum copy of DataConfig.Sub.Type
static var Sub: DataConfig.SubType = DataConfig.SubType.new()


## Enum for SerializationFlags
enum SerializationFlags {
	NONE		= 0,		## No special behavior
	REALTIME	= 1 << 0,	## Include normally unsaved realtime data (usefull for synchronizing)
	NO_UUID		= 1 << 1,	## Exclude the object's unique UUID (useful for duplication)
}

## Enum for NetworkFlags
enum NetworkFlags {
	NONE				= 0,		## No special network behavior
	ALLOW_SERIALIZE		= 1 << 0,	## Allow the object to be serialized in outgoing messages
	ALLOW_DESERIALIZE	= 1 << 1,	## Allow the object to be deserialized from incoming messages
	ALLOW_UNRESOLVED	= 1 << 2,	## Allow the object's UUID to be returned if the object can't be resolved
};


## Map custom Type to Godot Variant.Type
var custom_type_map: Dictionary[Type, Variant.Type] = {
	Type.NULL: 				TYPE_NIL,
	Type.ANY:				TYPE_MAX,
	Type.STRING:			TYPE_STRING,
	Type.BOOL: 				TYPE_BOOL,
	Type.INT: 				TYPE_INT,
	Type.FLOAT:				TYPE_FLOAT,
	Type.ARRAY: 			TYPE_ARRAY,
	Type.DICTIONARY: 		TYPE_DICTIONARY,
	Type.VECTOR2: 			TYPE_VECTOR2,
	Type.VECTOR2I: 			TYPE_VECTOR2,
	Type.RECT2: 			TYPE_RECT2,
	Type.RECT2I: 			TYPE_RECT2,
	Type.VECTOR3: 			TYPE_VECTOR3,
	Type.VECTOR3I: 			TYPE_VECTOR3,
	Type.VECTOR4: 			TYPE_VECTOR4,
	Type.VECTOR4I: 			TYPE_VECTOR4,
	Type.COLOR:				TYPE_COLOR,
	Type.OBJECT: 			TYPE_OBJECT,
	Type.CALLABLE: 			TYPE_CALLABLE,
	Type.SIGNAL: 			TYPE_SIGNAL,
	Type.ENUM: 				TYPE_INT,
	Type.BITFLAGS: 			TYPE_INT,
	Type.IP:				TYPE_OBJECT,
	Type.INPUTEVENT:		TYPE_OBJECT,
	Type.SETTINGSMANAGER:	TYPE_OBJECT,
	Type.PACKEDSCENE:		TYPE_OBJECT,
	Type.ACTION:			TYPE_NIL,
}

## Stores all autoload Globals
var _globals: Array[CoreGlobal]


## init
func _init(p_uuid: String = "", ...p_args: Array[Variant]) -> void:
	super._init(p_uuid, p_args)
	_set_class_name("CoreData")


## ready
func _ready() -> void:
	Config.load_config("res://DataConfig.gd")
	
	var global_class_tree: Dictionary[String, Variant]
	for node: Node in get_tree().get_root().get_children():
		if node is CoreGlobal:
			_globals.append(node)
			
			GlobalDB.register_component(node)
			global_class_tree[node.get_class_name()] = node.get_script()
	
	GlobalClassList.merge_class_tree({"CoreGlobal": global_class_tree})
	add_gbc_index(GBCIndexConfig.new(CoreGlobal, GlobalDB, GlobalClassList, ChildManager.new(
		self,
		Callable(),
		Callable(),
		Callable(),
		Callable(),
		Callable(),
		Callable(),
		Callable(),
		get_globals,
		Signal(),
		Signal(),
		CoreGlobal,
		CoreGlobal,
	)))


## Returns true if the 2 given types have a matching Variant.Type base
func do_types_match_base(p_type_one: Type, p_type_two: Type) -> bool:
	var type_one_base: Variant.Type = custom_type_map[p_type_one]
	var type_two_base: Variant.Type = custom_type_map[p_type_two]
	
	return type_one_base == type_two_base


## Converts a custom data type to a string, with a human readable name
func custom_type_to_string(p_variant: Variant, p_orignal_type: Type) -> String:
	if p_variant is Object and is_instance_valid(p_variant) and p_variant.has_method("get_uname"):
		return p_variant.get_uname()
	
	return type_convert(p_variant, TYPE_STRING)


## Returns the signal emitted when the name of an object is changed
func get_object_name_changed_signal(p_module: SettingsModule) -> Signal:
	var object: Variant = p_module.get_getter().call()
	if typeof(object) != TYPE_OBJECT or not is_instance_valid(object):
		return Signal()
	
	if object.has_signal("name_changed"):
		return object.name_changed
	
	if object is Node:
		return (object as Node).renamed
	
	return Signal()


## Returns all the CoreGlobal nodes
func get_globals() -> Array[CoreGlobal]:
	return _globals.duplicate()


## Returns the GBCIndexConfig for the given GBC class name, either a Script or String classname
func get_gbc_config(p_gbc_class: Variant) -> GBCIndexConfig:
	if p_gbc_class is Script:
		p_gbc_class = p_gbc_class.get_global_name()
	
	p_gbc_class = type_convert(p_gbc_class, TYPE_STRING)
	return Config.gbc_index.get(p_gbc_class, null)


## Adds a GBC index 
func add_gbc_index(p_index: GBCIndexConfig) -> void:
	Config.gbc_index[p_index.get_base_class().get_global_name()] = p_index


## Returns true if a GBCIndexConfig exists for the given GBC class name, either a Script or String classname 
func has_gbc_config(p_gbc_class: Variant) -> bool:
	if p_gbc_class is Script:
		p_gbc_class = p_gbc_class.get_global_name()
	
	p_gbc_class = type_convert(p_gbc_class, TYPE_STRING)
	return Config.gbc_index.has(p_gbc_class)


## Returns true if the givn object is GBC complient
func is_gbc_complient(p_object: Object) -> bool:
	# Placeholder for when GDScript has support for traits or interfaces
	return is_instance_valid(p_object) and p_object.has_method("get_uname")


## Stores config for Data
class Config extends Object:
	## User config Dictionary for storeing GBCIndexConfig for each GBC complient class
	static var gbc_index: Dictionary
	
	## Loads config from a file
	static func load_config(p_path: String) -> bool:
		var script: Variant = load(p_path)
		
		if script is not GDScript:
			return false
		
		var config: Dictionary = script.new().get("config")
		
		gbc_index = type_convert(config.get("gbc_index"), TYPE_DICTIONARY)
		
		return true
