class_name MemTools
extends RefCounted

enum Mode {
    PICK = -1,
    FIFO,
    LIFO,
    KEEP,
    DROP,
    POP,
}


class NotaValue:
    const NULL = null


## class Buffer
##
## Provides a simple FIFO/LIFO buffer for storing data.
## The buffer can be configured to drop data when full, or keep it.
## The buffer can be configured to retrieve data in FIFO or LIFO order.[br]
##
## [b]Method Descriptions:[/b][br]
##
## [i]Buffer[/i] [b]push(value: Variant)[/b][br]
## add a value to the buffer and return the buffer. If max_size 
## is met, it drops the oldest element, otherwise returns NotaValue.[br]
##
## [i]Variant[/i] [b]retrieve()[/b][br] 
## return and remove an element from the the buffer (FIFO or LIFO)[br]
## 
## [i]Variant[/i] [b]dump()[/b][br] 
## return and remove all elements from the buffer, if the retreival 
## mode is set to pop, clear() the data in the buffer.[br]
class Buffer:
    var max_size := -1: set = set_max_size
    var retrieval_mode := Mode.KEEP: set = set_retrieval_mode
    var overflow_mode := Mode.KEEP: set = set_overflow_mode
    var op_mode := Mode.FIFO: set = set_op_mode
    var _data := []
    var _max_count := -1
    var _nav := NotaValue.new()
    var _write_index := 0
    var _read_index := 0


    func _is_buffer_full() -> bool:
        if max_size == -1: return false
        if _data.size() < max_size: return false
        return true


    func _fifo_retrieve() -> Variant:
        var data: Variant
        match retrieval_mode:
            Mode.POP: 
                data = _data.pop_front()
            _: 
                data = _data[_read_index]
                _read_index += 1; if _read_index > _write_index: _read_index = 0
        return data


    func _fifo_dump() -> Array:
        var arr := []
        for i in range(_data.size() - 1): arr.push_back(_data[i])
        if retrieval_mode == Mode.POP: _data.clear()
        _read_index = 0; _write_index = 0
        return arr.duplicate(true)
    
    
    func _lifo_retrieve() -> Variant:
        var data: Variant
        match retrieval_mode:
            Mode.POP: 
                data = _data.pop_back()
            _:
                _write_index -= 1
                if _write_index < -_read_index or _write_index == 0: _write_index = -1 
                data = _data[_write_index]
        return data 
    
    
    func _lifo_dump() -> Array:
        var arr := []
        for i in range(_data.size() - 1): arr.push_back(_data[_data.size() - i - 1])
        if retrieval_mode == Mode.POP: _data.clear()
        _read_index = 0; _write_index = 0
        return arr.duplicate(true)


    func set_op_mode(mode: Mode) -> Buffer:
        op_mode = mode
        return self


    func set_retrieval_mode(mode: Mode) -> Buffer:
        retrieval_mode = mode
        return self


    func set_overflow_mode(mode: Mode) -> Buffer:
        overflow_mode = mode
        return self


    func set_max_size(size: int) -> Buffer:
        max_size = size
        if max_size == -1: _max_count = -1
        else: _max_count = size - 1
        return self


    func push(value) -> Buffer:
        if overflow_mode == Mode.DROP and _is_buffer_full(): 
            _data.pop_front()
            _data.push_back(value) 
            return self
        if _is_buffer_full(): 
            printerr("Buffer is full"); 
            return self
        _data.push_back(value)
        _write_index = _data.size() - 1
        return self


    func retrieve() -> Variant:
        match op_mode:
            Mode.FIFO: return _fifo_retrieve()
            Mode.LIFO: return _lifo_retrieve()
            _: printerr("not a recognized operation mode"); return _nav


    func dump() -> Variant:
        match op_mode:
            Mode.FIFO: return _fifo_dump()
            Mode.LIFO: return _lifo_dump()
            _: printerr("not a recognized operation mode"); return _nav            
    
