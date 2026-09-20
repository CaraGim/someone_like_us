extends Node

## Player's collected-item list. Minimal for now -- just an id per item, no
## quantities/metadata beyond what's already in Game Data.txt's
## "Collectable (interactable) object item" table. Later quest-completion
## checks should read has_item()/items directly rather than each quest
## re-implementing its own collected-item tracking.

signal item_added(item_id: String)

var items: Array[String] = []

func add_item(item_id: String) -> void:
	items.append(item_id)
	item_added.emit(item_id)
	print("Collected: ", item_id)

func has_item(item_id: String) -> bool:
	return items.has(item_id)

func item_count(item_id: String) -> int:
	return items.count(item_id)
