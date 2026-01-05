class_name Player extends CharacterBody2D

@export var speed: float = 3000
@export var speed_boost: float = 2

@onready var animator_hatted := $AnimatedSpriteHatted
@onready var animator_no_hat := $AnimatedSpriteNoHat

var hatted: bool = false
var current_direction: String = "front"
var is_attacking: bool = false

func _physics_process(delta) -> void:
    if is_attacking:
        return

    _movement(delta)
    _animations()

# Movimiento
func _movement(dt: float) -> void:
    # Movimiento básico
    var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
    velocity = direction * speed * dt

    # Sprint con flechas y con tecla
    if Input.is_action_pressed("sprint"):
        _sprint(direction, dt)

    move_and_slide()

# Maneja el sprint para que funcione con la tecla dedicada o con flechas
func _sprint(direction, dt) -> void:
    if direction != Vector2.ZERO:
        velocity *= speed_boost
        return

    match current_direction:
        "front":
            velocity = Vector2.DOWN * speed * dt * speed_boost
        "back":
            velocity = Vector2.UP * speed * dt * speed_boost
        "side":
            var is_right_direction: bool = not (animator_hatted.flip_h or animator_no_hat.flip_h)
            velocity = (Vector2.RIGHT if is_right_direction else Vector2.LEFT) * speed * dt * speed_boost

# Animaciones
func _animations() -> void:
    var current_animation: String = ""

    # Cambio de atuendo
    if Input.is_action_just_pressed("change"):
        hatted = not hatted

    # Establece el estilo
    animator_hatted.visible = hatted
    animator_no_hat.visible = not hatted

    # Orientación horizontal (ambos estilos)
    if velocity.x < 0:
        animator_hatted.flip_h = true
        animator_no_hat.flip_h = true
    elif velocity.x > 0:
        animator_hatted.flip_h = false
        animator_no_hat.flip_h = false

    # Orientación
    if velocity.x != 0:
        current_direction = "side"
    elif velocity.y > 0:
        current_direction = "front"
    elif velocity.y < 0:
        current_direction = "back"

    # Ataque
    if Input.is_action_just_pressed("attack"):
        current_animation = "attack"
        is_attacking = true
        _execute_animations(current_animation)
        return

    # Sprint
    if Input.is_action_pressed("sprint"):
        current_animation = "sprint_" + current_direction
        _execute_animations(current_animation)
        return

    # Movimiento
    if velocity != Vector2.ZERO:
        current_animation = "walk_" + current_direction
        _execute_animations(current_animation)
    else:
        current_animation = "idle_" + current_direction
        _execute_animations(current_animation)

    return

# Ejecuta las animaciones en ambos
func _execute_animations(animation: String) -> void:
    if hatted:
        animator_hatted.play(animation)
    else:
        animator_no_hat.play(animation)

# Cuando finaliza la animación de ataque con gorro
# Llamado con una señal
func _on_animated_sprite_hatted_animation_finished() -> void:
    if animator_hatted.animation == "attack":
        is_attacking = false

# Cuando finaliza la animación de ataque sin gorro
# Llamado con una señal
func _on_animated_sprite_no_hat_animation_finished() -> void:
    if animator_no_hat.animation == "attack":
        is_attacking = false
