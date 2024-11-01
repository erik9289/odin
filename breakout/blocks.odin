package breakout

import "core:fmt"
import rl "vendor:raylib"

NUM_BLOCKS_X :: 10
NUM_BLOCKS_Y :: 8
BLOCK_WIDTH :: 28
BLOCK_HEIGHT :: 10
NUM_LEVELS :: 2

Block_Color :: enum {
	Yellow,
	Green,
	Orange,
	Red,
}

block_color_values := [Block_Color]rl.Color {
	.Yellow = {253, 249, 150, 255},
	.Green  = {180, 245, 190, 255},
	.Orange = {170, 120, 250, 255},
	.Red    = {250, 90, 85, 255},
}

block_color_score := [Block_Color]int {
	.Yellow = 2,
	.Green  = 4,
	.Orange = 6,
	.Red    = 8,
}

row_colors := [NUM_BLOCKS_Y]Block_Color {
	.Red,
	.Red,
	.Orange,
	.Orange,
	.Green,
	.Green,
	.Yellow,
	.Yellow,
}

Block :: struct {
	color:   Block_Color,
	shields: int,
	visible: bool,
}


calc_block_rect :: proc(x, y: int) -> rl.Rectangle {
	return {
		f32(20 + x * BLOCK_WIDTH),
		f32(40 + y * BLOCK_HEIGHT),
		BLOCK_WIDTH - 1,
		BLOCK_HEIGHT - 1,
	}
}

block_exists :: proc(x, y: int) -> bool {
	if x < 0 || y < 0 || x >= NUM_BLOCKS_X || y >= NUM_BLOCKS_Y {
		return false
	}
	return levels[level_current][x][y].visible
}

check_block_collision :: proc(previous_ball_pos: rl.Vector2) {

	// Check for collisions with blocks
	block_x_loop: for x in 0 ..< NUM_BLOCKS_X {
		for y in 0 ..< NUM_BLOCKS_Y {
			if !levels[level_current][x][y].visible {
				continue
			}
			block_rect := calc_block_rect(x, y)
			if rl.CheckCollisionCircleRec(ball_pos, BALL_RADIUS, block_rect) {
				collision_normal: rl.Vector2
				// Ball is above block
				if previous_ball_pos.y < block_rect.y {
					collision_normal += {0, -1}
				}
				// Ball is below the blocks
				if previous_ball_pos.y > block_rect.y + block_rect.height {
					collision_normal += {0, 1}
				}
				// Ball is on the left side of a blocks
				if previous_ball_pos.x < block_rect.x {
					collision_normal += {-1, 0}
				}
				// Ball is on the right sidde of a blocks
				if previous_ball_pos.x > block_rect.x + block_rect.width {
					collision_normal += {1, 0}
				}

				// Check if there where blocks left or right of current blocks by checking
				// the collsion_normal. This prevents 'horizontal' reflections when hitting a corner
				if block_exists(x + int(collision_normal.x), y) {
					collision_normal.x = 0
				}
				// Also for above and beneath
				if block_exists(x, y + int(collision_normal.y)) {
					collision_normal.y = 0
				}

				// Apply the accumulated collision_normal and calculate the reflection
				if collision_normal != 0 {
					ball_dir = reflect(ball_dir, collision_normal)
				}

				// Now lower the shield or destroy the block!
				levels[level_current][x][y].shields -= 1
				if levels[level_current][x][y].shields < 1 {
					levels[level_current][x][y].visible = false
				}

				// Update the score based on block row_colors
				row_color := row_colors[y]
				score += block_color_score[row_color]
				if score > highscore {
					highscore = score
				}

				break block_x_loop // Breaking outer loop, preventing multiple collsions per frame
			}
		}
	}

}

draw_blocks :: proc() {
	for x in 0 ..< NUM_BLOCKS_X {
		for y in 0 ..< NUM_BLOCKS_Y {
			if !levels[level_current][x][y].visible {
				continue // Skip blocks that are hit
			}
			block_rect := calc_block_rect(x, y)

			// rl.DrawRectangleRec(block_rect, block_color_values[row_colors[y]])
			rl.DrawRectangleRec(block_rect, block_color_values[levels[level_current][x][y].color])
			top_left := rl.Vector2{block_rect.x, block_rect.y}
			top_right := rl.Vector2{block_rect.x + block_rect.width, block_rect.y}
			bottom_left := rl.Vector2{block_rect.x, block_rect.y + block_rect.height}
			bottom_right := rl.Vector2 {
				block_rect.x + block_rect.width,
				block_rect.y + block_rect.height,
			}
			rl.DrawLineEx(top_left, top_right, 1, {255, 255, 150, 100})
			rl.DrawLineEx(top_left, bottom_left, 1, {255, 255, 150, 100})
			rl.DrawLineEx(bottom_left, bottom_right, 1, {0, 0, 50, 100})
			rl.DrawLineEx(top_right, bottom_right, 1, {0, 0, 50, 100})
		}
	}
}
