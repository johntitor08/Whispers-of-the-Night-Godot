class_name SceneProgress

enum { Scene1, Scene2, Scene3, Scene4, Scene5, Scene6, Scene7, Scene8, Scene9, SceneHome, SceneMarket, SceneGym, SceneOffice, SceneChurch }

const NAMES := ["Scene1", "Scene2", "Scene3", "Scene4", "Scene5", "Scene6", "Scene7", "Scene8", "Scene9", "SceneHome", "SceneMarket", "SceneGym", "SceneOffice", "SceneChurch"]

static func name_of(v: int) -> String:
	return NAMES[v] if v >= 0 and v < NAMES.size() else str(v)
