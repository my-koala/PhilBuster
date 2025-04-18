extends CanvasLayer
class_name MoneyDisplay

@onready
var _money_label: Label = $money_label

@onready
var _flyout_spawner: FlyoutSpawner = $flyout_spawner

var _game_stats: GameStats
var _cached_money: int = 0

func init(game_stats: GameStats) -> void:
	_game_stats = game_stats
	update_money(game_stats.get_money(), 0)
	if !_game_stats.money_added.is_connected(_on_money_changed):
		_game_stats.money_added.connect(_on_money_changed)
	if !_game_stats.money_removed.is_connected(_on_money_changed):
		_game_stats.money_removed.connect(_on_money_changed)

func update_money(amount: int, offset: int) -> void:
	_money_label.text = "$%d" % _game_stats.get_money()
	
	if (offset == 0):
		return
	
	var offset_text: String = "$%d" % offset if offset >= 0 else "-$%d" % abs(offset)
	var offset_color: Color = Color.GREEN_YELLOW if offset >= 0 else Color.INDIAN_RED
	
	_flyout_spawner.spawn_flyout(offset_text, offset_color)
	_cached_money = _game_stats.get_money()
	
func _on_money_changed(amount: int) -> void:
	var new_money: int = _game_stats.get_money()
	var offset: int = new_money - _cached_money
	
	update_money(new_money, offset)
