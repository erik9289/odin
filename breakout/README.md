# Breakout

This is a classic `Breakout` game implementation, adapted from the excellent Youtube video: [Odin + Raylib: Breakout game from start to finish](https://www.youtube.com/watch?v=vfgZOEvO0kM)  by Karl Zylinski.

![Breakout!](./Screenshot.png)

## Compile and run the game
- [Install the Odin compiler](https://odin-lang.org/docs/install/) (I just ran `brew install odin` on my Mac)
- Enter the `breakout` folder and run:
  ```
  odin run .
  ```
  This will compile and run the breakout code.
- assets like sounds and images are expected in the assets folder

## TODO

- ~Add sound(s)~
- Highscore
  - ~Add to UI~
  - Persist Highscore
  - Add usernames for highscores
- Levels
  - ~After clearing a level, go to a new/next one~
  - ~Create different (shapes) of levels~
- Blocks
  - ~'hard' blocks that must be hit more than once~
  - blocks that drop a special token, when hit with the paddle it will be enabled:
    - 'extra life' block
    - 'multiple balls' block
    - 'extended paddle' block
- Refactor code
- Controller support
