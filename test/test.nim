import ../src/nim_sdl3

proc drawTriangle(renderer: RendererPtr): void =
  var xy: seq[float32] = @[
    400, 100,
    200, 500,
    600, 500
  ]

  var colors: seq[FColor] = @[
    FColor(r: 1, g: 0, b: 0, a: 1),
    FColor(r: 0, g: 1, b: 0, a: 1),
    FColor(r: 0, g: 0, b: 1, a: 1)
  ]

  renderer.renderGeometryRaw(
    nil,
    xy,
    float32.sizeof * 4, # Technically "should" be * 2, but it looks cool like this
    colors,
    FColor.sizeof.cint,
    @[],
    0,
    3, # vertices
    @[],
    0,
    0
  )

proc main() =
  if initSDL(Video, Events):
    echo "SDL initialised successfully!"
  else:
    echo "Failed to initialise SDL: ", getError()

  let (window, renderer) = createWindowAndRenderer("Test", 640, 480, OpenGl)
  if window.isNil:
    echo "Failed to create window"
    quitSDL()
  elif renderer.isNil:
    echo "Failed to create renderer"
    quitSDL()
  else:
    echo "Window and Renderer created successfully!"

  let device = createGPUDevice([Spirv], true, nil)
  if device.isNil:
    echo "Failed to create GPU device"
    quitSDL()
  else:
    echo "GPU Device created successfully!"
    echo "GPU Driver: ", device.getDriver()

  var evt: Event
  var quit = false

  while not quit:
    while pollEvent(evt):
      if evt.eventType == Quit:
        quit = true

    renderer.setDrawColor(0, 0, 0, 255)
    renderer.clear()

    renderer.setDrawColor(255, 255, 255, 255)

    renderer.drawTriangle()

    renderer.debugText(10, 10, "Hello SDL3 from Nim!")
    renderer.debugTextFormat(10, 30, "Current time: %llu seconds", getTicks() div 1000)

    renderer.setDrawColor(255, 255, 255)
    renderer.debugText(224, 150, "This is some debug text.")

    renderer.setDrawColor(51, 102, 255)
    renderer.debugText(184, 200, "You can do it in different colors.")
    renderer.setDrawColor(255, 255, 255)

    renderer.setScale(4, 4)
    renderer.debugText(14, 65, "It can be scaled.")
    renderer.setScale(1, 1)
    renderer.debugText(64, 350, "This only does ASCII chars. So this laughing emoji won't draw: 🤣")

    renderer.present()
  quitSDL()

when isMainModule:
  main()