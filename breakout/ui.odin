package breakout

import "core:fmt"
import rl "vendor:raylib"

draw_ui :: proc() {
	// Display UI elements - num_lives and score in the upper left corner
	num_lives_text := fmt.ctprint(num_lives)
	score_text := fmt.ctprint(score)
	rl.DrawText(num_lives_text, 5, 5, 10, rl.DARKPURPLE)
	rl.DrawText(score_text, 5, 15, 10, rl.WHITE)

	// Display 'Game Over' and Score
	if game_over {
		game_over_text := fmt.ctprint("Game Over")
		game_over_text_width := rl.MeasureText(game_over_text, 24)
		game_over_score_text := fmt.ctprintf("Score: %v  SPACE to restart", score)
		game_over_score_text_width := rl.MeasureText(game_over_score_text, 15)
		rl.DrawText(
			game_over_text,
			SCREEN_SIZE / 2 - game_over_text_width / 2,
			PADDLE_POS_Y - 60,
			24,
			rl.RED,
		)
		rl.DrawText(
			game_over_score_text,
			SCREEN_SIZE / 2 - game_over_score_text_width / 2,
			PADDLE_POS_Y - 30,
			15,
			rl.WHITE,
		)
	}
}
