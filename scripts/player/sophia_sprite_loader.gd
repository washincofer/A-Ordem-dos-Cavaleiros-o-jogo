class_name SophiaSpriteLoader
extends RefCounted

const FRAME_SIZE := Vector2i(320, 320)
const FRAME_BASELINE_Y := 306
const MAX_CONTENT_WIDTH := 300
const MAX_CONTENT_HEIGHT := 296

const IDLE_PATH := "res://assets/art/characters/sophia/sprites/atlases/sophia_idle_20f.png"
const WALK_PATH := "res://assets/art/characters/sophia/sprites/atlases/sophia_walk_20f.png"

# The current approved source sheets are not a perfectly uniform grid.
# These rectangles isolate each complete pose from the transparent source PNG
# and are normalized at runtime into fixed 320x320 frames.
const IDLE_RECTS := [
	Rect2i(34, 7, 242, 273),
	Rect2i(312, 7, 237, 274),
	Rect2i(584, 7, 232, 274),
	Rect2i(853, 7, 234, 273),
	Rect2i(1115, 7, 241, 273),
	Rect2i(28, 284, 248, 273),
	Rect2i(314, 284, 242, 273),
	Rect2i(581, 288, 241, 270),
	Rect2i(852, 288, 237, 270),
	Rect2i(1115, 288, 243, 269),
	Rect2i(33, 562, 259, 268),
	Rect2i(312, 560, 249, 270),
	Rect2i(576, 562, 257, 268),
	Rect2i(848, 561, 258, 269),
	Rect2i(1121, 560, 255, 269),
	Rect2i(31, 834, 245, 271),
	Rect2i(311, 834, 240, 271),
	Rect2i(581, 835, 240, 270),
	Rect2i(852, 835, 245, 271),
	Rect2i(1117, 836, 253, 269)
]

const WALK_RECTS := [
	Rect2i(17, 6, 234, 292),
	Rect2i(282, 6, 234, 292),
	Rect2i(567, 6, 240, 291),
	Rect2i(842, 6, 246, 291),
	Rect2i(1122, 6, 236, 292),
	Rect2i(19, 305, 251, 291),
	Rect2i(285, 305, 247, 291),
	Rect2i(569, 305, 242, 293),
	Rect2i(838, 305, 253, 293),
	Rect2i(1121, 305, 249, 292),
	Rect2i(19, 596, 246, 288),
	Rect2i(288, 597, 243, 286),
	Rect2i(572, 596, 244, 289),
	Rect2i(846, 598, 250, 287),
	Rect2i(1125, 596, 242, 289),
	Rect2i(33, 876, 225, 246),
	Rect2i(297, 877, 228, 245),
	Rect2i(580, 876, 225, 246),
	Rect2i(851, 876, 232, 246),
	Rect2i(1133, 876, 226, 246)
]

static func build() -> SpriteFrames:
	var frames := SpriteFrames.new()

	if frames.has_animation(&"default"):
		frames.remove_animation(&"default")

	_add_normalized_animation(frames, &"idle", IDLE_PATH, IDLE_RECTS, 6.0, true)
	_add_normalized_animation(frames, &"walk", WALK_PATH, WALK_RECTS, 14.0, true)

	return frames

static func assets_available() -> bool:
	return ResourceLoader.exists(IDLE_PATH) and ResourceLoader.exists(WALK_PATH)

static func _add_normalized_animation(
	sprite_frames: SpriteFrames,
	animation_name: StringName,
	texture_path: String,
	frame_rects: Array,
	fps: float,
	looped: bool
) -> void:
	if not ResourceLoader.exists(texture_path):
		return

	var texture := load(texture_path) as Texture2D
	if texture == null:
		return

	var source_image := texture.get_image()
	if source_image == null or source_image.is_empty():
		return

	var max_source_width: int = 1
	var max_source_height: int = 1
	for rect_variant in frame_rects:
		var source_rect: Rect2i = rect_variant
		max_source_width = maxi(max_source_width, source_rect.size.x)
		max_source_height = maxi(max_source_height, source_rect.size.y)

	var width_scale := float(MAX_CONTENT_WIDTH) / float(max_source_width)
	var height_scale := float(MAX_CONTENT_HEIGHT) / float(max_source_height)
	var scale_factor := minf(minf(width_scale, height_scale), 1.0)

	sprite_frames.add_animation(animation_name)
	sprite_frames.set_animation_speed(animation_name, fps)
	sprite_frames.set_animation_loop(animation_name, looped)

	for rect_variant in frame_rects:
		var source_rect: Rect2i = rect_variant
		var frame_image := source_image.get_region(source_rect)

		var target_width := maxi(1, roundi(float(frame_image.get_width()) * scale_factor))
		var target_height := maxi(1, roundi(float(frame_image.get_height()) * scale_factor))

		if target_width != frame_image.get_width() or target_height != frame_image.get_height():
			frame_image.resize(target_width, target_height, Image.INTERPOLATE_LANCZOS)

		var normalized := Image.create(
			FRAME_SIZE.x,
			FRAME_SIZE.y,
			false,
			Image.FORMAT_RGBA8
		)
		normalized.fill(Color(0.0, 0.0, 0.0, 0.0))

		var target_x := int((FRAME_SIZE.x - target_width) / 2)
		var target_y := FRAME_BASELINE_Y - target_height
		target_y = clampi(target_y, 0, FRAME_SIZE.y - target_height)

		normalized.blend_rect(
			frame_image,
			Rect2i(Vector2i.ZERO, frame_image.get_size()),
			Vector2i(target_x, target_y)
		)

		var frame_texture := ImageTexture.create_from_image(normalized)
		sprite_frames.add_frame(animation_name, frame_texture)
