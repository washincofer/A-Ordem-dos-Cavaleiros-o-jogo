class_name SophiaSpriteLoader
extends RefCounted

const CELL_SIZE := Vector2i(192, 192)
const COLUMNS := 5
const FRAME_COUNT := 20

const IDLE_PATH := "res://assets/art/characters/sophia/sprites/atlases/sophia_idle_20f.png"
const WALK_PATH := "res://assets/art/characters/sophia/sprites/atlases/sophia_walk_20f.png"

static func build() -> SpriteFrames:
	var frames := SpriteFrames.new()

	if frames.has_animation(&"default"):
		frames.remove_animation(&"default")

	_add_animation(frames, &"idle", IDLE_PATH, 6.0, true)
	_add_animation(frames, &"walk", WALK_PATH, 14.0, true)

	return frames

static func assets_available() -> bool:
	return ResourceLoader.exists(IDLE_PATH) and ResourceLoader.exists(WALK_PATH)

static func _add_animation(
	sprite_frames: SpriteFrames,
	animation_name: StringName,
	texture_path: String,
	fps: float,
	looped: bool
) -> void:
	if not ResourceLoader.exists(texture_path):
		return

	var texture := load(texture_path) as Texture2D
	if texture == null:
		return

	sprite_frames.add_animation(animation_name)
	sprite_frames.set_animation_speed(animation_name, fps)
	sprite_frames.set_animation_loop(animation_name, looped)

	for index in range(FRAME_COUNT):
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		var column: int = index % COLUMNS
		var row: int = int(index / COLUMNS)
		atlas.region = Rect2(
			column * CELL_SIZE.x,
			row * CELL_SIZE.y,
			CELL_SIZE.x,
			CELL_SIZE.y
		)
		sprite_frames.add_frame(animation_name, atlas)
