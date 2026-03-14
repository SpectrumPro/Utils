# Copyright (c) 2026 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name Utils extends Object
## Usefull function that would be annoying to write out each time


## Removes numbers regex
static var number_regex := RegEx.new()


## init
static func _static_init() -> void:
	number_regex.compile("\\d+")


## Formats a 12 hour time from an 24 hour interger
static func format_12_hour(p_hour_24: int) -> String:
	var period: String = "AM"
	var hour_12: int = p_hour_24

	if p_hour_24 == 0:
		hour_12 = 12
		period = "AM"
	elif p_hour_24 == 12:
		hour_12 = 12
		period = "PM"
	elif p_hour_24 > 12:
		hour_12 = p_hour_24 - 12
		period = "PM"
	
	return str("%02d" % hour_12) + period


## Converts any bitmask enum into a readable string like "FLAG1+FLAG2"
static func flags_to_string(p_flags: int, p_enum: Dictionary) -> String:
	var names: Array[String] = []
	
	for name in p_enum.keys():
		var value: int = p_enum[name]
		
		if value != 0 and (p_flags & value) != 0:
			names.append(name)
	
	return "+".join(names)


## Removes numbers from a string
static func remove_numbers(p_string: String) -> Dictionary:
	var matches: Array[RegExMatch] = number_regex.search_all(p_string)
	var numbers: Array[int] = []
	
	for m: RegExMatch in matches:
		numbers.append(int(m.get_string()))
	
	var cleaned: String = number_regex.sub(p_string, "", true)
	
	return {
		"string": cleaned,
		"numbers": numbers
	}


## Saves a JSON valid dictonary to a file, creates the file and folder if it does not exist
static func save_json_to_file(file_path: String, file_name: String, json: Dictionary) -> Error:
	if not DirAccess.dir_exists_absolute(file_path):
		print("The folder \"" + file_path + "\" does not exist, creating one now, errcode: ", DirAccess.make_dir_absolute(file_path))

	var file_access: FileAccess = FileAccess.open(file_path+"/"+file_name, FileAccess.WRITE)
	
	if FileAccess.get_open_error():
		print(FileAccess.get_open_error())
		return FileAccess.get_open_error()
	
	file_access.store_string(JSON.stringify(json, "\t"))
	file_access.close()
	
	return file_access.get_error()


## Loads JSON from a file, returning the JSON dictionary or {}
static func load_json_from_file(p_file_path: String, p_file_name: String) -> Dictionary:
	if not DirAccess.dir_exists_absolute(p_file_path):
		return {}
	
	var file_access: FileAccess = FileAccess.open(p_file_path + p_file_name, FileAccess.READ)
	
	if FileAccess.get_open_error() or not is_instance_valid(file_access):
		return {}
	
	var json: Variant = JSON.parse_string(file_access.get_as_text())
	
	if json is Dictionary:
		return json
	else:
		return {}


## Calculates the HTP value of two colors
static func get_htp_color(color_1: Color, color_2: Color) -> Color:
	# Calculate the intensity of each channel for color1
	var intensity_1_r = color_1.r
	var intensity_1_g = color_1.g
	var intensity_1_b = color_1.b

	# Calculate the intensity of each channel for color2
	var intensity_2_r = color_2.r
	var intensity_2_g = color_2.g
	var intensity_2_b = color_2.b

	# Compare the intensities for each channel and return the color with the higher intensity for each channel
	var result_color = Color()
	result_color.r = intensity_1_r if intensity_1_r > intensity_2_r else intensity_2_r
	result_color.g = intensity_1_g if intensity_1_g > intensity_2_g else intensity_2_g
	result_color.b = intensity_1_b if intensity_1_b > intensity_2_b else intensity_2_b
	
	return result_color


## Blends two colors
static func blend_color_additive(color_a: Color, color_b: Color) -> Color:
	return Color(
		clamp(color_a.r + color_b.r, 0.0, 1.0),
		clamp(color_a.g + color_b.g, 0.0, 1.0),
		clamp(color_a.b + color_b.b, 0.0, 1.0),
		clamp(color_a.a + color_b.a, 0.0, 1.0)
	)


## Gets the most common variant in an array
static func get_most_common_value(arr: Array) -> Variant:
	var count_dict := {}
	
	# Count the occurrences of each value
	for value in arr:
		if value in count_dict:
			count_dict[value] += 1
		else:
			count_dict[value] = 1
	
	# Find the most common value
	var most_common_value = null
	var max_count = 0
	
	for key in count_dict:
		if count_dict[key] > max_count:
			max_count = count_dict[key]
			most_common_value = key
	
	return most_common_value


## Sums all items in an array
static func sum_array(array: Array) -> Variant:
	var sum: Variant = 0
	
	for element: Variant in array:
		sum += element
	
	return sum


## Sorts all the text in an array
static func sort_text(arr: Array) -> Array:
	arr.sort_custom(func(a, b): return a.naturalnocasecmp_to(b) < 0)
	return arr


## Sorts all the text in an array, with numbers
static func sort_text_and_numbers(arr: Array) -> Array:
	arr.sort_custom(func(a, b): return _split_sort_key(a) < _split_sort_key(b))
	return arr


## Helper function for sort_text_and_numbers
static func _split_sort_key(s: String) -> Array:
	var regex = RegEx.new()
	regex.compile(r"\d+|\D+")
	
	var parts: Array = []
	for match in regex.search_all(s):
		var sub = match.get_string()
		parts.append(int(sub) if sub.is_valid_int() else sub)
	
	return parts


## Moves an item to the start of an array
static func array_move_to_start(arr: Array, item) -> Array:
	var i = arr.find(item)
	if i > 0:  # Ensures "root" is found and isn't already at index 0
		arr.remove_at(i)
		arr.insert(0, item)
	return arr
