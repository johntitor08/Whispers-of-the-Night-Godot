class_name EnemyData
extends EnemyDataFields

var DisplayName: String:
	get:
		return Loc.Pick(d.get("enemyName"), d.get("enemyNameTR"))

var DisplayDescription: String:
	get:
		return Loc.Pick(d.get("description"), d.get("descriptionTR"))
