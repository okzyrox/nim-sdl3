import ../src/nim_sdl3


proc main() =
  if initSDL(Video, Events):
    echo "SDL initialised successfully!"
  else:
    echo "Failed to initialise SDL: ", getError()

  let (window, renderer) = createWindowAndRenderer("Test", 400, 400, OpenGl)
  if window.isNil:
    echo "Failed to create window"
    quitSDL()
  elif renderer.isNil:
    echo "Failed to create renderer"
    quitSDL()
  else:
    echo "Window and Renderer created successfully!"

  echo "Renderer: " & $renderer.getName()

  var surface: SurfacePtr = nil

  var
    pixels1: uint8
    pixels2: uint8
    pixels3: uint8
    pixels4: uint8

  discard readSurfacePixel(surface, 0, 0, addr pixels1, addr pixels2, addr pixels3, addr pixels4)

  surface.readPixel(0, 0, addr pixels1, addr pixels2, addr pixels3, addr pixels4)

  (pixels1, pixels2, pixels3, pixels4) = surface.readPixel(0, 0)

  var evt: Event
  var quit = false

  while not quit:
    while pollEvent(evt):
      if evt.eventType == Quit:
        quit = true

    renderer.setDrawColor(0, 0, 0, 255)
    renderer.clear()

    renderer.setDrawColor(255, 255, 255, 255)
    renderer.debugText(10, 10, "Hello SDL3 from Nim!")

    renderer.present()
  quitSDL()

when isMainModule:
  main()