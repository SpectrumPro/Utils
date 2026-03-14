# Copyright (c) 2026 Liam Sherwin & Contributors.
# This file was based on https://github.com/binogure-studio/godot-uuid
# See the LICENSE file for details.

class_name UUID extends Object
## Class for creating UUIDs


## Byte mask for binary UUID genaration
const BYTE_MASK: int = 0b11111111

## UUID Stores as an array
var _uuid: Array


## init
func _init(rng := RandomNumberGenerator.new()) -> void:
	_uuid = uuidbinrng(rng)


## Creates a binary UUID
static func uuidbin() -> Array:
	randomize()
	# 16 random bytes with the bytes on index 6 and 8 modified
	return [
		randi() & BYTE_MASK, randi() & BYTE_MASK, randi() & BYTE_MASK, randi() & BYTE_MASK,
		randi() & BYTE_MASK, randi() & BYTE_MASK, ((randi() & BYTE_MASK) & 0x0f) | 0x40, randi() & BYTE_MASK,
		((randi() & BYTE_MASK) & 0x3f) | 0x80, randi() & BYTE_MASK, randi() & BYTE_MASK, randi() & BYTE_MASK,
		randi() & BYTE_MASK, randi() & BYTE_MASK, randi() & BYTE_MASK, randi() & BYTE_MASK,
	]


## Creates a binary UUID with a given RandomNumberGenerator
static func uuidbinrng(rng: RandomNumberGenerator) -> Array:
	rng.randomize()
	return [
		rng.randi() & BYTE_MASK, rng.randi() & BYTE_MASK, rng.randi() & BYTE_MASK, rng.randi() & BYTE_MASK,
		rng.randi() & BYTE_MASK, rng.randi() & BYTE_MASK, ((rng.randi() & BYTE_MASK) & 0x0f) | 0x40, rng.randi() & BYTE_MASK,
		((rng.randi() & BYTE_MASK) & 0x3f) | 0x80, rng.randi() & BYTE_MASK, rng.randi() & BYTE_MASK, rng.randi() & BYTE_MASK,
		rng.randi() & BYTE_MASK, rng.randi() & BYTE_MASK, rng.randi() & BYTE_MASK, rng.randi() & BYTE_MASK,
	]


## Creates a UUIDv4 complient UUID
static func v4() -> String:
	# 16 random bytes with the bytes on index 6 and 8 modified
	var b = uuidbin()

	return '%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x' % [
		# low
		b[0], b[1], b[2], b[3],
		
		# mid
		b[4], b[5],
		
		# hi
		b[6], b[7],
		
		# clock
		b[8], b[9],
		
		# clock
		b[10], b[11], b[12], b[13], b[14], b[15]
	]


## Creates a UUIDv4 complient UUID with a given RandomNumberGenerator
static func v4_rng(rng: RandomNumberGenerator) -> String:
	# 16 random bytes with the bytes on index 6 and 8 modified
	var b = uuidbinrng(rng)
	return '%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x' % [
		# low
		b[0], b[1], b[2], b[3],
		
		# mid
		b[4], b[5],
		
		# hi
		b[6], b[7],
		
		# clock
		b[8], b[9],
		
		# clock
		b[10], b[11], b[12], b[13], b[14], b[15]
	]


## Returns this UUID as an array
func as_array() -> Array:
	return _uuid.duplicate()


## Returns this UUID as a Dictionary
func as_dict(big_endian := true) -> Dictionary:
	if big_endian:
		return {
		  "low"  : (_uuid[0]  << 24) + (_uuid[1]  << 16) + (_uuid[2]  << 8 ) +  _uuid[3],
		  "mid"  : (_uuid[4]  << 8 ) +  _uuid[5],
		  "hi"   : (_uuid[6]  << 8 ) +  _uuid[7],
		  "clock": (_uuid[8]  << 8 ) +  _uuid[9],
		  "node" : (_uuid[10] << 40) + (_uuid[11] << 32) + (_uuid[12] << 24) + (_uuid[13] << 16) + (_uuid[14] << 8 ) +  _uuid[15]
		}
	else:
		return {
		  "low"  : _uuid[0]          + (_uuid[1]  << 8 ) + (_uuid[2]  << 16) + (_uuid[3]  << 24),
		  "mid"  : _uuid[4]          + (_uuid[5]  << 8 ),
		  "hi"   : _uuid[6]          + (_uuid[7]  << 8 ),
		  "clock": _uuid[8]          + (_uuid[9]  << 8 ),
		  "node" : _uuid[10]         + (_uuid[11] << 8 ) + (_uuid[12] << 16) + (_uuid[13] << 24) + (_uuid[14] << 32) + (_uuid[15] << 40)
		}


## Returns this UUID as a string
func as_string() -> String:
	return '%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x' % [
		# low
		_uuid[0], _uuid[1], _uuid[2], _uuid[3],

		# mid
		_uuid[4], _uuid[5],

		# hi
		_uuid[6], _uuid[7],

		# clock
		_uuid[8], _uuid[9],

		# node
		_uuid[10], _uuid[11], _uuid[12], _uuid[13], _uuid[14], _uuid[15]
	]


## Returns true if this UUID is equal to another
func is_equal(p_uuid: UUID) -> bool:
	# Godot Engine compares Array recursively
	# There's no need for custom comparison here.
	return _uuid == p_uuid._uuid
