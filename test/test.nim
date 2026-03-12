import ../src/nim_sdl3


if init(flags(Video, Events)):
  echo "SDL initialised successfully!"
else:
  echo "Failed to initialise SDL: ", getError()


let windowFlags = flags(OpenGL)
let window = createWindow("Test", 800, 800, windowFlags)
if window.isNil:
  echo "Failed to create window: ", getError()
else:
  echo "Window created successfully!"

var evt: Event
var quit = false

while not quit:
  while pollEvent(evt):
    case evt.eventType:
      of Quit:
        quit = true
      else:
        echo "Event: ", $evt.eventType.ord
