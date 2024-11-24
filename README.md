# TurnStyle

TurnStyle is a framework for implementing simultaneous-turn (WeGo) multiplayer games. Given some functions that describe how your game works and is displayed, TurnStyle can run it as a server or client.

See `examples/rps.rkt` for example usage. To run a program that uses `start-turnstyle-from-command-line-args!`, run the server with the command-line arguments `-p [port]` and the clients with `-p [port] [server-address]`.

---

The required functions are:

### For the server side:

- `apply-commands : (State Command Command -> State)` updates the state based on commands (moves) from the clients. Same idea as `on-*` from universe.
- `render-state-for-client : (State ClientIdx -> RenderedState)` renders the game state from the perspective of the client. Rendering here has more to do with representing relative information (e.g. 'you are winning') and hiding information that the player shouldn't know. The rendered state will be sent over TCP before being shown to the player by `display-rendered-state`.

### For the client side:

- `get-command : (-> RawCommand)` gets a raw command (string input, button press, etc) from the user.
- `parse-command : (RawCommand -> (Or Command InvalidMoveError))` parses a raw command into a normalized form, or returns `(invalid-move "reason")`. If the command is invalid, TurnStyle will get a new command.
- `display-rendered-state : (RenderedState ->)` displays the rendered game state.
