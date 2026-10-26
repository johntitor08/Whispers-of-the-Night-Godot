class_name BrushSettingsFields
extends SO

var activeTool:
	get:
		return d.get("activeTool", ToolType.Brush)
	set(v):
		d["activeTool"] = v

var activeShape:
	get:
		return d.get("activeShape", ShapeType.Line)
	set(v):
		d["activeShape"] = v

var size:
	get:
		return d.get("size", 8)
	set(v):
		d["size"] = v

var opacity:
	get:
		return d.get("opacity", 1.0)
	set(v):
		d["opacity"] = v

var hardness:
	get:
		return d.get("hardness", 1.0)
	set(v):
		d["hardness"] = v

var color:
	get:
		return d.get("color", Color.BLACK)
	set(v):
		d["color"] = v

var blendMode:
	get:
		return d.get("blendMode", null)
	set(v):
		d["blendMode"] = v

var eraserSize:
	get:
		return d.get("eraserSize", 16)
	set(v):
		d["eraserSize"] = v
