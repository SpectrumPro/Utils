# class_name DataConfig extends Object


## Class to store SubType keys
class SubType:
	enum Type {
		NULL,						## No Type
	}


## Config for Data
static var config: Dictionary[String, Variant] = {
	"custom_type_to_string_method": custom_type_to_string,
	"get_object_name_signal_method": get_object_name_changed_signal,
	"get_object_db": get_object_db,
	"gbc_index": {
		#"ClassName": GBCIndexConfig.new(Script, ObjectDB, ClassListDB, ChildManager)
	}
}


## Converts a custom data type to a string, with a human readable name
@warning_ignore("unused_parameter")
static func custom_type_to_string(p_variant: Variant, p_orignal_type: Data.Type) -> Variant:
	## return a String to override default convertion
	# return "Value"

	## else return false to use default convertion
	return false


## Returns the signal emitted when the name of an object is changed
static func get_object_name_changed_signal(p_module: SettingsModule) -> Variant:
	var object: Variant = p_module.get_getter().call()
	
	## return Signal() if the object type is invalid, or has no name signal
	if typeof(object) != TYPE_OBJECT or not is_instance_valid(object):
		return Signal()
	
	## check object type and return correct signal
	#if object is Node:
		#return (object as Node).renamed
	
	## else return false to use default 
	return false



## Returns the ObjectDB that p_object's type belongs to
static func get_object_db(p_object: Object) -> ObjectDB:
	if not is_instance_valid(p_object):
		return null
	
	match p_object.get_base_class():
		_:
			return null
