package breakout

import "core:fmt"
import rl "vendor:raylib"

// Define some constant for fontsizes
FS_SCORE :: 24
FS_LIVES :: 8
FS_HIGHSCORE :: 8
FS_GAMEOVER :: 24
FS_RESTART :: 12

draw_ui :: proc() {

	// Display UI elements - num_lives and score in the upper left corner
	score_text := fmt.ctprintf("%03d", score)
	rl.DrawText(score_text, center_text(score_text, FS_SCORE, SCREEN_SIZE), 5, FS_SCORE, rl.WHITE)

	num_lives_text := fmt.ctprintf("Lives: %d", num_lives)
	rl.DrawText(num_lives_text, 5, 5, FS_LIVES, rl.WHITE)

	// Display highscore in upper right corner
	highscore_text := fmt.ctprintf("High: %03d", highscore)
	highscore_text_width := rl.MeasureText(highscore_text, FS_HIGHSCORE)
	rl.DrawText(highscore_text, SCREEN_SIZE - highscore_text_width - 5, 5, FS_HIGHSCORE, rl.WHITE)

	// Display 'Game Over' and Score
	if game_over {
		game_over_text := fmt.ctprint("Game Over")
		rl.DrawText(
			game_over_text,
			center_text(game_over_text, FS_GAMEOVER, SCREEN_SIZE),
			PADDLE_POS_Y - 60,
			FS_GAMEOVER,
			rl.RED,
		)
		game_over_restart_text := fmt.ctprint("SPACE to restart")
		rl.DrawText(
			game_over_restart_text,
			center_text(game_over_restart_text, FS_RESTART, SCREEN_SIZE),
			PADDLE_POS_Y - 30,
			FS_RESTART,
			rl.WHITE,
		)
	}
}

center_text :: proc(text: cstring, font_size, screen_size: int) -> i32 {
	text_width := rl.MeasureText(text, i32(font_size))
	return i32(screen_size / 2) - text_width / 2
}
