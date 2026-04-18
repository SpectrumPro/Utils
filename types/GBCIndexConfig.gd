# Copyright (c) 2026 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name GBCIndexConfig extends Object
## Class for storing CoreObjectDB and CoreClassListDB entrys for GBC complient objects


## The base class
var _base_class: Script

## The CoreObjectDB for the base class
var _objectdb: CoreObjectDB

## The CoreClassListDB for the base class
var _classdb: CoreClassListDB

## The ChildManager to use when adding and removing objects
var _child_manager: ChildManager


## Init
func _init(p_base_class: Script, p_objectdb: CoreObjectDB, p_classdb: CoreClassListDB, p_child_manager: ChildManager) -> void:
	_base_class = p_base_class
	_objectdb = p_objectdb
	_classdb = p_classdb
	_child_manager = p_child_manager


## Returns the Script for the base class of this GBC
func get_base_class() -> Script:
	return _base_class


## Returns the CoreObjectDB for this GBC Class
func get_objectdb() -> CoreObjectDB:
	return _objectdb


## Returns the CoreObjectDB for this GBC Class
func get_class_listdb() -> CoreClassListDB:
	return _classdb


## Return ChildManager
func get_child_manager() -> ChildManager:
	return _child_manager
