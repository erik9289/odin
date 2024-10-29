package breakout

import "core:fmt"
import rl "vendor:raylib"

// Define some constant for fontsizes
FS_SCORE :: 24
FS_LIVES :: 8
FS_HIGHSCORE :: 8
FS_GAMEOVER :: 24
FS_RESTART :: 15

draw_ui :: proc() {

	// Display UI elements - num_lives and score in the upper left corner
	scoreText := fmt.ctprintf("%03d", score)
	rl.DrawText(scoreText, centerText(scoreText, FS_SCORE, SCREEN_SIZE), 5, FS_SCORE, rl.WHITE)

	numLivesText := fmt.ctprintf("Lives: %d", num_lives)
	rl.DrawText(numLivesText, 5, 5, FS_LIVES, rl.WHITE)

	// Display highscore in upper right corner
	highscoreText := fmt.ctprintf("High: %03d", highscore)
	highscoreTextWidth := rl.MeasureText(highscoreText, FS_HIGHSCORE)
	rl.DrawText(highscoreText, SCREEN_SIZE - highscoreTextWidth - 5, 5, FS_HIGHSCORE, rl.WHITE)

	// Display 'Game Over' and Score
	if game_over {
		gameOverText := fmt.ctprint("Game Over")
		gameOverTextWidth := rl.MeasureText(gameOverText, FS_GAMEOVER)
		rl.DrawText(
			gameOverText,
			centerText(gameOverText, FS_GAMEOVER, SCREEN_SIZE),
			PADDLE_POS_Y - 60,
			FS_GAMEOVER,
			rl.RED,
		)
		gameOverRestartText := fmt.ctprint("SPACE to restart")
		gameOverRestartTextWidth := rl.MeasureText(gameOverRestartText, FS_RESTART)
		rl.DrawText(
			gameOverRestartText,
			centerText(gameOverRestartText, 15, SCREEN_SIZE),
			PADDLE_POS_Y - 30,
			FS_RESTART,
			rl.WHITE,
		)
	}
}

centerText :: proc(text: cstring, fontSize, screenSize: int) -> i32 {
	textWidth := rl.MeasureText(text, i32(fontSize))
	return i32(screenSize / 2) - textWidth / 2
}
