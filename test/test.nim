import ../src/nim_sdl3


if init(flags(Video, Events)):
  echo "SDL initialised successfully!"
else:
  echo "Failed to initialise SDL: ", getError()

let ram = getSystemRAM()
echo "System RAM: ", ram, " MB"