# Copyright (c) 2026 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name CoreObjectDB extends CoreGlobal
## CoreObjectDB manages all currently registered components in the engine.


## Emitted when a component is added to the engine.
signal components_added(components: Array)

## Emitted when a component is removed from the engine.
signal components_removed(components: Array)


## Stores all components by their UUID. for all instances of CoreObjectDB
static var _static_components: Dictionary[String, Object]

## Stores all static component request, requests that work accross any instance of CoreObjectDB
static var _static_requests: Dictionary[String, Array]


## Stores all components by their UUID.
var _components: Dictionary[String, Object]

## Stores all components grouped by their class name.
var _components_by_classname: Dictionary[String, Array]

## Stores pending component requests by UUID.
var _component_requests: Dictionary[String, Array]

## Stores all class-level callback signals.
var _class_callbacks: Dictionary[String, Array]

## Temporarily stores components that were added or removed, allowing batch emission of class callbacks.
var _just_changed_components: Dictionary[String, Dictionary]

## True if _emit_class_callbacks is queued to run at the end of this frame.
var _emit_class_callbacks_queued: bool = false


## init
func _init(p_uuid: String = "", ...p_args: Array[Variant]) -> void:
	super._init(p_uuid, p_args)
	_set_class_name("CoreObjectDB")


## Registers a component in the database. Returns false if it already exists.
## p_component must be GBC-compliant.
func register_component(p_component: Object) -> bool:
	if not is_component_allowed(p_component) or p_component.get_uuid() in _components:
		return false
	
	_components[p_component.get_uuid()] = p_component
	_static_components[p_component.get_uuid()] = p_component
	
	for classname: String in p_component.get_class_tree():
		if not classname in _components_by_classname:
			_components_by_classname[classname] = []
		_components_by_classname[classname].append(p_component)
	
	_check_component_requests(p_component)
	_check_class_callbacks(p_component)
	
	p_component.delete_requested.connect(deregister_component)
	components_added.emit([p_component])
	
	return true


## Deregisters a component from the database. Returns false if it does not exist.
## p_component must be GBC-compliant.
func deregister_component(p_component: Object) -> bool:
	if not is_component_allowed(p_component) or not p_component.get_uuid() in _components:
		return false
	
	for classname: String in p_component.get_class_tree():
		_components_by_classname[classname].erase(p_component)
	
	_check_class_callbacks(p_component, true)
	_components.erase(p_component.get_uuid())
	
	p_component.delete_requested.disconnect(deregister_component)
	components_removed.emit([p_component])
	
	return true


## Returns a list of components for a given class name. The result is duplicated to prevent modification.
func get_components_by_classname(p_classname: String) -> Array:
	return _components_by_classname.get(p_classname, []).duplicate()


## Returns the component with the given UUID.
func get_component(p_uuid: String) -> Object:
	return _components.get(p_uuid)


## Returns all components in this CoreObjectDB
func get_components() -> Array:
	return _components.values()


## Checks if the given component exists in the database. Not GBC-safe if the object lacks get_uuid().
func has_component(p_component: Object) -> bool:
	if not is_component_allowed(p_component):
		return false
	
	return _components.has(p_component.get_uuid())


## Returns true if the given component is allowed in this CoreObjectDB
func is_component_allowed(p_component: Object) -> bool:
	return p_component.has_method("get_uuid") 


## Registers a callback to be called once when a component with p_uuid is added.
func request_component(p_uuid: String, p_callback: Callable) -> void:
	if not p_uuid:
		return
	
	if p_uuid in _components:
		p_callback.call(_components[p_uuid])
	else:
		if not p_uuid in _component_requests:
			_component_requests[p_uuid] = []
		_component_requests[p_uuid].append(p_callback)


## Registers a static callback to be called once when a component with p_uuid is added. Works accross any instance of CoreObjectDB
static func request_component_static(p_uuid: String, p_callback: Callable) -> void:
	if not p_uuid:
		return
	
	if p_uuid in _static_components:
		p_callback.call(_static_components[p_uuid])
	else:
		if not p_uuid in _static_requests:
			_static_requests[p_uuid] = []
		_static_requests[p_uuid].append(p_callback)


## Removes a previously registered component request.
func remove_request(p_uuid: String, p_callback: Callable) -> void:
	if p_uuid in _component_requests and p_callback in _component_requests[p_uuid]:
		_component_requests[p_uuid].erase(p_callback)
		
		if not _component_requests[p_uuid]:
			_component_requests.erase(p_uuid)


## Removes a previously registered component request. Works accross any instance of CoreObjectDB
static func remove_request_static(p_uuid: String, p_callback: Callable) -> void:
	if p_uuid in _static_requests and p_callback in _static_requests[p_uuid]:
		_static_requests[p_uuid].erase(p_callback)
		
		if not _static_requests[p_uuid]:
			_static_requests.erase(p_uuid)


## Registers a callback to be called whenever a component matching p_classname is added.
## This callback is invoked for all future additions.
func request_class_callback(p_classname: String, p_callback: Callable) -> void:
	if not _class_callbacks.has(p_classname): 
		_class_callbacks[p_classname] = []
	
	_class_callbacks[p_classname].append(p_callback)


## Removes a previously registered class callback.
func remove_class_callback(p_classname: String, p_callback: Callable) -> void:
	if _class_callbacks.has(p_classname):
		_class_callbacks[p_classname].erase(p_callback)


## Resets all class callbacks and clears the queue.
func reset_callbacks() -> void:
	_just_changed_components.clear()
	_emit_class_callbacks_queued = false


## Checks both static and local component requests and calls callbacks if needed
func _check_component_requests(p_component: Object) -> void:
	for requests: Dictionary[String, Array] in [_static_requests, _component_requests]: 
		if p_component.get_uuid() in requests:
			for callback: Callable in requests[p_component.get_uuid()].duplicate():
				if callback.is_valid(): 
					callback.call(p_component)
			
			requests.erase(p_component.get_uuid())


## Internal method to check and queue class callbacks for p_component.
## If p_remove is true, the component is considered removed.
func _check_class_callbacks(p_component: Object, p_remove: bool = false) -> void:
	for classname: String in p_component.get_class_tree():
		if classname in _class_callbacks:
			if not _just_changed_components.has(classname): 
				_just_changed_components[classname] = {
					"added": [],
					"removed": []
				}
			
			if p_remove:
				_just_changed_components[classname].removed.append(p_component)
			else:
				_just_changed_components[classname].added.append(p_component)
			
			if not _emit_class_callbacks_queued:
				_emit_class_callbacks.call_deferred()
			_emit_class_callbacks_queued = true


## Emits all queued class callbacks. Should be called via call_deferred() to batch callbacks at the end of the frame.
func _emit_class_callbacks() -> void:
	if _just_changed_components:
		for classname: String in _just_changed_components:
			for callback: Callable in _class_callbacks[classname].duplicate():
				if callback.is_valid():
					callback.callv(_just_changed_components[classname].values())
				else:
					_class_callbacks[classname].erase(callback)
	
	_just_changed_components.clear()
	_emit_class_callbacks_queued = false
