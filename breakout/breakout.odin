package breakout

import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:mem"
import rl "vendor:raylib"

SCREEN_SIZE :: 320
MAX_LIVES :: 3
PADDLE_WIDTH :: 50
PADDLE_HEIGHT :: 6
PADDLE_POS_Y :: 260
PADDLE_SPEED :: 200 // Speed in pixels per second
BALL_SPEED :: 260
BALL_RADIUS :: 4
BALL_START_Y :: 160

paddle_pos_x: f32
ball_pos: rl.Vector2
ball_dir: rl.Vector2

started: bool
game_over: bool
score: int
highscore: int
num_lives := MAX_LIVES

level_current: int
level_cnt: int

game_over_snd: rl.Sound
hit_paddle_snd: rl.Sound
hit_block_snd: rl.Sound
lives_img: rl.Texture

restart :: proc(reset: bool) {
	paddle_pos_x = SCREEN_SIZE / 2 - PADDLE_WIDTH / 2
	ball_pos = {SCREEN_SIZE / 2, BALL_START_Y}
	started = false

	// Reset the blocks if no lives left or at the start
	if reset {
		// TODO: Check if we need to do this (here)
		// for x in 0 ..< NUM_BLOCKS_X {
		// 	for y in 0 ..< NUM_BLOCKS_Y {
		// 		levels[level_current][x][y].visible = true
		// 	}
		// }
		num_lives = MAX_LIVES
		score = 0
		game_over = false
		level_current = 0
		level_cnt = 0

		free_levels()
		init_levels()
	}
}

reflect :: proc(dir, normal: rl.Vector2) -> rl.Vector2 {
	new_direction := linalg.reflect(dir, linalg.normalize(normal))
	return linalg.normalize(new_direction)
}


main :: proc() {
	// Debug
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			if len(track.bad_free_array) > 0 {
				fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
				for entry in track.bad_free_array {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
			fmt.println("End of debug defer call")
		}
	}

	rl.SetConfigFlags({.VSYNC_HINT})
	rl.InitWindow(640, 640, "Breakout!")
	defer rl.CloseWindow()

	rl.InitAudioDevice()
	defer rl.CloseAudioDevice()
	hit_paddle_snd = rl.LoadSound("assets/hit_paddle.wav")
	game_over_snd = rl.LoadSound("assets/game_over.wav")
	hit_block_snd = rl.LoadSound("assets/hit_block.wav")

	lives_img = rl.LoadTexture("assets/heart_32.png")

	rl.SetTargetFPS(160)


	init_levels()
	defer free_levels()

	restart(true)

	for !rl.WindowShouldClose() {

		// UPDATE
		/////////////////////////////////////////////////////////////////////////////
		dt: f32
		// Keep dt zero ('wait') until SPACEBAR is pressed to start the game
		if !started {
			ball_pos = {
				SCREEN_SIZE / 2 + f32(math.cos(rl.GetTime())) * SCREEN_SIZE / 2.5,
				BALL_START_Y,
			}
			if rl.IsKeyPressed(.SPACE) {
				// Point the ball (vector) to the middle of the paddle
				paddle_middle := rl.Vector2{paddle_pos_x + PADDLE_WIDTH / 2, PADDLE_POS_Y}
				ball_to_paddle := paddle_middle - ball_pos
				ball_dir = linalg.normalize0(ball_to_paddle) // Normalize the direction vector to 1
				started = true
			}
		} else if game_over {
			restart(true)
			if rl.IsKeyPressed(.SPACE) {
				// restart(true)
				started = true
			}
		} else {
			dt = rl.GetFrameTime()
		}

		previous_ball_pos := ball_pos
		ball_pos += ball_dir * BALL_SPEED * dt

		// Check right wall and bounce
		if ball_pos.x + BALL_RADIUS > SCREEN_SIZE {
			ball_pos.x = SCREEN_SIZE - BALL_RADIUS
			ball_dir = reflect(ball_dir, {-1, 0})
		}
		// Check left wall and bounce
		if ball_pos.x - BALL_RADIUS < 0 {
			ball_pos.x = 0 + BALL_RADIUS
			ball_dir = reflect(ball_dir, {1, 0})
		}
		// Check top wall and bounce
		if ball_pos.y - BALL_RADIUS < 0 {
			ball_pos.y = BALL_RADIUS
			ball_dir = reflect(ball_dir, {0, 1})
		}
		// Check bottom, this means game over/restart
		if ball_pos.y + BALL_RADIUS * 6 > SCREEN_SIZE {
			num_lives -= 1
			if num_lives == 0 {
				rl.PlaySound(game_over_snd)
				game_over = true
			}
			restart(false)
		}

		paddle_move_velocity: f32
		if rl.IsKeyDown(.LEFT) {
			paddle_move_velocity -= PADDLE_SPEED
		}
		if rl.IsKeyDown(.RIGHT) {
			paddle_move_velocity += PADDLE_SPEED
		}
		paddle_pos_x += paddle_move_velocity * dt
		paddle_pos_x = clamp(paddle_pos_x, 0, SCREEN_SIZE - PADDLE_WIDTH)

		paddle_rect := rl.Rectangle{paddle_pos_x, PADDLE_POS_Y, PADDLE_WIDTH, PADDLE_HEIGHT}

		// Check for collision between ball and paddle
		if rl.CheckCollisionCircleRec(ball_pos, BALL_RADIUS, paddle_rect) {
			collision_normal: rl.Vector2
			if previous_ball_pos.y < paddle_rect.y + paddle_rect.height {
				collision_normal += {0, -1}
				ball_pos.y = paddle_rect.y - BALL_RADIUS
			}
			// In case the ball hits the bottom of the paddle
			if previous_ball_pos.y > paddle_rect.y + paddle_rect.height {
				collision_normal += {0, 1}
				ball_pos.y = paddle_rect.y + paddle_rect.height + BALL_RADIUS
			}
			// From the left of the paddle
			if previous_ball_pos.x < paddle_rect.x {
				collision_normal += {-1, 0}
			}
			// From the right of the paddle
			if previous_ball_pos.x > paddle_rect.x + paddle_rect.width {
				collision_normal += {1, 0}
			}
			// Apply the accumulated collision_normal and calculate the reflection
			if collision_normal != 0 {
				ball_dir = reflect(ball_dir, collision_normal)
			}
			rl.PlaySound(hit_paddle_snd)
		}

		// Check for collision with a block
		check_block_collision(previous_ball_pos)


		// Draw
		/////////////////////////////////////////////////////////////////////////////
		camera := rl.Camera2D {
			zoom = f32(rl.GetScreenHeight() / SCREEN_SIZE),
		}

		rl.BeginDrawing()
		rl.ClearBackground({150, 190, 220, 255})
		rl.BeginMode2D(camera)

		rl.DrawRectangleRec(paddle_rect, {50, 150, 90, 255}) // draw the paddle
		rl.DrawCircleV(ball_pos, BALL_RADIUS, {200, 90, 20, 255}) // draw the ball
		draw_blocks()
		draw_ui()

		rl.EndMode2D()
		rl.EndDrawing()

		free_all(context.temp_allocator)
	}
}
