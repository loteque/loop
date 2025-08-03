class_name Buffer
extends RefCounted

var size: int
var max_count: int
var store: Dictionary = {}
var NAV := NotaValue.new()


func _trim_store(key) -> void:
    store[key].pop_front()
    var diff: int = (store[key].size() - 1) - max_count
    if diff > 0: store[key] = store[key].slice(0, diff)


func _update_store(key: StringName, value: Variant) -> void:
    store[key].push_back(value)


func _add_store(key: StringName) -> void:
    store.merge({key: []})


func _delete_store(key: StringName) -> void:
    store.erase(key)


func update(key: StringName, value: Variant) -> Buffer:
    var count: int = store[key].size() - 1
    if count >= max_count: _trim_store(key)
    if store.has(key): _update_store(key, value); return self
    _add_store(key)
    _update_store(key, value)
    return self


func has_at_index(key: StringName, index: int, value: Variant) -> bool:
    if store[key][index] != value: return false
    return true


func retrieve(key: StringName, index: int) -> Variant:
    if not store.has(key): return NAV
    if store[key].size() - 1 < index: return NAV
    return store[key][index]


func _init(_size: int) -> void:
    self.size = _size
    self.max_count = _size - 1


class NotaValue:
    const VALUE = null
