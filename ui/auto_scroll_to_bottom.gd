extends ScrollContainer


var max_scroll_length = 0

@onready var scrollbar = self.get_v_scroll_bar()


func _ready():
    # auto scrolling
    scrollbar.changed.connect(handle_scrollbar_changed)
    max_scroll_length = scrollbar.max_value


func handle_scrollbar_changed():
    if max_scroll_length != scrollbar.max_value:
        max_scroll_length = scrollbar.max_value

        scroll_vertical = max_scroll_length
