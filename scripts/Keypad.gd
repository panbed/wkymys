extends Interactable

const PowerType = preload("uid://c7iq8laid2oq5").PowerType

var broken = false

func interact(by: Node) -> void:
    print("interacted with keypad...")
    if broken:
        print("keypad already broken, do nothing")
        return
    
    if by.dead == true and by.active_power == PowerType.ELECTRIC:
        print("keypad is now broken! doors opening...")
        broken = true
    else:
        print("incorrect password")


