extends Node

# Source: https://www.youtube.com/watch?v=MfS73MPZBrM
enum QTE_STATES { START, RUNNING, FAILED, SUCCESS, STOPPED }
var QTE_STATUS : QTE_STATES = QTE_STATES.STOPPED

var QTE_LAYER : Node
var QTE_TIMER_LABEL: Label
var QTE_ACTION_TIMER_LABEL: Label
var QTE_LABEL : Label
var QTE_PLAYER_LABEL: Label
var QTE_FEEDBACK: Label

var POSSIBLE_ACTIONS : Array = [
	"by_button"
]
var CURRENT_QTE : Array = []
var PLAYER_QTE : Array = []

var QTE_SIZE : int = 1
var QTE_MAX_SIZE : int = 8
var QTE_INCREMENTER : int = 0

var QTE_TIME_LIMIT : float = 10 #seconds to finish the qte
var QTE_ACTION_TIME_LIMIT : float = 5 #seconds between the actions
var QTE_TIMER : float = 10
var QTE_ACTION_TIMER : float = 5

signal success_qte
signal failed_qte

func _ready() -> void:
	QTE_LAYER = %QTE_LAYER
	
func _input(event : InputEvent) -> void:
	if QTE_STATUS == QTE_STATES.RUNNING:
		if PLAYER_QTE == CURRENT_QTE:
			print("Success")
			QTE_STATUS = QTE_STATES.SUCCESS
			QTE_INCREMENTER += 1
			if QTE_INCREMENTER > QTE_MAX_SIZE:
				QTE_INCREMENTER = QTE_MAX_SIZE
			QTE_SIZE = QTE_SIZE + floor(QTE_INCREMENTER / 2)
			success_qte.emit()
			if QTE_LAYER:
				if QTE_FEEDBACK:
					QTE_FEEDBACK.text = "YIPPIE"
				await get_tree().create_timer(1).timeout
				var Instance = get_tree().root.find_child("QTE_LAYER", true, false)
				Instance.queue_free()
				stop_qte()
				#STOP QTE
		elif Input.is_action_just_pressed(CURRENT_QTE[PLAYER_QTE.size()]):
			PLAYER_QTE.push_back(CURRENT_QTE[PLAYER_QTE.size()])
			print(PLAYER_QTE)
			if QTE_PLAYER_LABEL:
				QTE_PLAYER_LABEL.text = str(PLAYER_QTE)
			QTE_ACTION_TIMER = QTE_ACTION_TIME_LIMIT
			
func _process(delta:float) -> void:
	if QTE_STATUS == QTE_STATES.RUNNING:
		QTE_TIMER -= delta
		QTE_ACTION_TIMER -= delta
		if QTE_TIMER_LABEL:
			QTE_TIMER_LABEL.text = "QTE TINER: " + str(floor(QTE_TIMER * 100) / 100)
		if QTE_ACTION_TIMER_LABEL:
			QTE_ACTION_TIMER_LABEL.text = "QTE NEXT ACTION: " + str(floor(QTE_ACTION_TIMER * 100) / 100)
		if PLAYER_QTE != CURRENT_QTE && (QTE_TIMER <= 0 || QTE_ACTION_TIMER <= 0):
			print("FAILED!!! :'(")
			QTE_STATUS = QTE_STATES.FAILED
			QTE_FEEDBACK.text = "FAILED!! :("
			failed_qte.emit()
			stop_qte()
			
func stop_qte() -> void:
	await get_tree().create_timer(2).timeout
	QTE_STATUS = QTE_STATES.STOPPED
	var Instance = get_tree().root.find_child("QTE_LAYER", true, false)
	if Instance:
			Instance.queue_free()
			
func start_qte() -> void:
	if QTE_STATUS != QTE_STATES.STOPPED:
		return
	
	if QTE_LAYER:
		var Instance = QTE_LAYER
		QTE_TIMER_LABEL = Instance.find_child("QTE_TIMER", true, false)
		QTE_ACTION_TIMER_LABEL = Instance.find_child("QTE_ACTION_TIMER", true, false)
		QTE_PLAYER_LABEL = Instance.find_child("QTE_PLAYER", true, false)
		QTE_LABEL = Instance.find_child("QTE", true, false)
		QTE_FEEDBACK = Instance.find_child("QTE_FEEDBACK", true, false)
		print("QTE initialized")
		
		
	QTE_STATUS = QTE_STATES.START
	QTE_TIMER = QTE_TIME_LIMIT
	QTE_ACTION_TIMER = QTE_ACTION_TIME_LIMIT
	CURRENT_QTE = []
	PLAYER_QTE = []
	for length in QTE_SIZE:
		CURRENT_QTE.push_back(POSSIBLE_ACTIONS.pick_random())
	
	if QTE_LABEL:
		QTE_LABEL.text = str(CURRENT_QTE)
		
	if QTE_FEEDBACK:
		QTE_FEEDBACK.text = "GET READY!"
		
	await get_tree().create_timer(1).timeout
	
	if QTE_FEEDBACK:
		QTE_FEEDBACK.text = "Go!"
		
	QTE_STATUS = QTE_STATES.RUNNING
	pass
