# druid.node API

> at /druid/base/node.lua

Component for stretching a GUI node through its size or position without changing its scale.

## Functions

- [init](#init)
- [set_size_stretch](#set_size_stretch)
- [set_pos_stretch](#set_pos_stretch)

## Fields

- [node](#node)



### init

---
```lua
node:init(node)
```

Create a Node component.

- **Parameters:**
	- `node` *(node|string)*: The GUI node or node id

### set_size_stretch

---
```lua
node:set_size_stretch(stretch_x, stretch_y)
```

Stretch the node through its size instead of its scale.

- **Parameters:**
	- `stretch_x` *(boolean)*: Stretch the width
	- `stretch_y` *(boolean)*: Stretch the height

- **Returns:**
	- `self` *(druid.node)*: The node component itself for chaining

### set_pos_stretch

---
```lua
node:set_pos_stretch(stretch_x, stretch_y)
```

Stretch the node position without changing its scale.

- **Parameters:**
	- `stretch_x` *(boolean)*: Stretch the horizontal position
	- `stretch_y` *(boolean)*: Stretch the vertical position

- **Returns:**
	- `self` *(druid.node)*: The node component itself for chaining
