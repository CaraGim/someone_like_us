extends Resource
class_name QuestData

## Static definition of one main-quest entry, per the "Quest data" tables in
## Game Mechanism.txt and Game Data.txt. Describes what a quest IS -- request
## items, location, flavor text -- not a player's progress against it; quest
## state (accepted / in progress / completed) is tracked separately per
## player/save, not here.

@export var id: int = 0
@export var title: String = ""
@export var location_name: String = ""
@export var request_items: Array[String] = [] ## Collectable item ids required to complete the quest (see Game Data.txt "Collectable (interactable) object item").
@export var puzzle_description: String = ""
@export var enemy_attack_pattern: String = ""
@export var enemy_murder_action: String = ""
@export var reward_blueprint_id: String = "" ## Blueprint id granted on completion (see Game Data.txt "Blueprint for prop list").
@export_multiline var thematic_note: String = "" ## The "-> The chapter N quest shows..." design-intent line from Game Mechanism.txt, kept with the data so it isn't lost when quests are authored/edited in the editor.
