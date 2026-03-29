# SDL3 Bindings for Nim
### SDL Version: <u>3.2.16</u>

> [!WARNING]
> Currently an unfinished bindings implementation, you can see what sections have been completed in the [TODO list](./todo.txt)

### Example
```nim
import nim_sdl3 # From wherever

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
```

### Bindings

> [!NOTE]
> With the bindings, there are function overloads either to simplify the function name, or to simplify the output. I mainly did this out of inspiration of other Nim bindings like Naylib. <br>
> Example:
```nim
proc readSurfacePixel(surface: SurfacePtr, x, y: cint, r, g, b, a: ptr uint8): bool # Refers to SDL_ReadSurfacePixel
proc readPixel(surface: SurfacePtr, x, y: cint, r, g, b, a: ptr uint8): bool # Generic simplification, implicitly discardable
proc readPixel(surface: SurfacePtr, x, y: cint): (uint8, uint8, uint8, uint8) # Pointer simplification

# In some cases where the function returns a boolean, a `.` call function is provided as well. Ex: `window.position` == `SDL_GetWindowPosition(window)`

# All of these do the same thing
# ...
var
  pixels1: uint8
  pixels2: uint8
  pixels3: uint8
  pixels4: uint8

discard readSurfacePixel(surface, 0, 0, addr pixels1, addr pixels2, addr pixels3, addr pixels4)

surface.readPixel(0, 0, addr pixels1, addr pixels2, addr pixels3, addr pixels4)

(pixels1, pixels2, pixels3, pixels4) = surface.readPixel(0, 0)

```
