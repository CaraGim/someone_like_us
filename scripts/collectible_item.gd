extends Interactable
class_name CollectibleItem

## A quest/theme-field item the player picks up by interacting with it (F key
## or click, per the standard Interactable flow). Adds itself to Inventory
## and removes itself from the world -- no pickup animation/effect yet,
## matching this sprint's "collect the quest item" scope only.

@export var item_id: String = "" ## Matches Game Data.txt "Collectable (interactable) object item" ids, e.g. "seed", "skull".
@export var display_name: String = ""

func interact(_player: Node) -> void:
	Inventory.add_item(item_id)
	queue_free()

func get_prompt() -> String:
	return "F key to collect " + display_name
