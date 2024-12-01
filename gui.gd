extends Control


@onready var lives = %LivesGui
@onready var lives_label = %LivesLabel
@onready var level = %LevelGui
@onready var level_label = %LevelLabel
@onready var points = %PointsGui
@onready var points_label = %PointsLabel
@onready var fadeout = %FadeOut
@onready var circout = %CircleOut
@onready var cineup = %UpperCineBar
@onready var cinedown = %LowerCineBar
@onready var overlay = %Overlay


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Main.gui = self
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
