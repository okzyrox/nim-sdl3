# Bindings for SDL3 // https://wiki.libsdl.org/SDL3/FrontPage
# SDL3 Version: 3.2.16

{.push warning[user]: off}
when defined(emscripten):
  const LibName* = "libSDL3.so"
  proc emscripten_set_main_loop* ( f: proc() {.cdecl.}, fps: cint, simulate_infinite_loop: bool ) {.importc.}
  proc emscripten_cancel_main_loop* ()  {.importc.}
elif defined(windows):
  const LibName* = "SDL3.dll"
elif defined(macosx):
  const LibName* = "libSDL3.dylib"
else:
  const LibName* = "libSDL3.so"
{.pop.}

when defined(emscripten):
  {.push callConv: cdecl.}
else:
  {.push callConv: cdecl, dynlib: LibName.}


type stub = distinct


## Section: SDL_version.h

const
  SDL_MAJOR_VERSION* = 3
  SDL_MINOR_VERSION* = 2
  SDL_MICRO_VERSION* = 16

template SDL_VERSION_NUM* (major, minor, patch): cint = 
  ((major) * 1000000 + (minor) * 1000 + (patch))
template SDL_VERSION_NUM_MAJOR* (version): cint = 
  ((version) / 1000000)
template SDL_VERSION_NUM_MINOR* (version): cint = 
  (((version) / 1000) mod 1000)
template SDL_VERSION_NUM_MICRO* (version): cint = 
  ((version) mod 1000)

const SDL_VERSION* =  SDL_VERSION_NUM(
  SDL_MAJOR_VERSION, 
  SDL_MINOR_VERSION, 
  SDL_MICRO_VERSION
  )
template SDL_VERSION_ATLEAST* (X, Y, Z): bool = 
  SDL_VERSION >= SDL_VERSIONNUM(X, Y, Z)

proc SDL_GetVersion* (): cint {.importc.}
proc SDL_GetRevision* (): cstring {.importc.}

## Section: SDL_asyncio.h

type
  AsyncIOPtr* = ptr object
  AsyncIOQueuePtr* = ptr object
  AsyncIOTaskType* {.size: sizeof(cint).} = enum
    Read
    Write
    Close
  AsyncIOResult* {.size: sizeof(cint).} = enum
    Complete
    Failure
    Canceled
  AsyncIOOutcomePtr* = ptr AsyncIOOutcome
  AsyncIOOutcome* {.bycopy.} = object
    asyncio*: AsyncIOPtr
    `type`*: AsyncIOTaskType
    result*: AsyncIOResult
    buffer*: pointer
    offset*: uint64
    bytesRequested*: uint64
    bytesTransferred*: uint64
    userdata*: pointer

proc AsyncIOFromFile*(file, mode: cstring): AsyncIOPtr {.importc: "SDL_AsyncIOFromFile".}
proc newAsyncIOFromFile*(file, mode: cstring): AsyncIOPtr =
  AsyncIOFromFile(file, mode)
proc getAsyncIOSize*(asyncio: AsyncIOPtr): int64 {.importc: "SDL_GetAsyncIOSize".}
proc getSize*(asyncio: AsyncIOPtr): int64 =
  getAsyncIOSize(asyncio)
proc readAsyncIO*(asyncio: AsyncIOPtr, readPtr: pointer, offset, size: uint64, queue: AsyncIOQueuePtr, userdata: pointer): bool {.importc: "SDL_ReadAsyncIO".}
proc read*(asyncio: AsyncIOPtr, readPtr: pointer, offset, size: uint64, queue: AsyncIOQueuePtr, userdata: pointer): bool =
  readAsyncIO(asyncio, readPtr, offset, size, queue, userdata)
proc writeAsyncIO*(asyncio: AsyncIOPtr, writePtr: pointer, offset, size: uint64, queue: AsyncIOQueuePtr, userdata: pointer): bool {.importc: "SDL_WriteAsyncIO".}
proc write*(asyncio: AsyncIOPtr, writePtr: pointer, offset, size: uint64, queue: AsyncIOQueuePtr, userdata: pointer): bool =
  writeAsyncIO(asyncio, writePtr, offset, size, queue, userdata)
proc closeAsyncIO*(asyncio: AsyncIOPtr, flush: bool, queue: AsyncIOQueuePtr, userdata: pointer): bool {.importc: "SDL_CloseAsyncIO".}
proc close*(asyncio: AsyncIOPtr, flush: bool, queue: AsyncIOQueuePtr, userdata: pointer): bool =
  closeAsyncIO(asyncio, flush, queue, userdata)

proc createAsyncIOQueue*(): AsyncIOQueuePtr {.importc: "SDL_CreateAsyncIOQueue".}
proc newAsyncIOQueue*(): AsyncIOQueuePtr =
  createAsyncIOQueue()
proc destroyAsyncIOQueue*(asyncioQueue: AsyncIOQueuePtr): void {.importc: "SDL_DestroyAsyncIOQueue".}
proc destroy*(asyncioQueue: AsyncIOQueuePtr): void =
  destroyAsyncIOQueue(asyncioQueue)
proc getAsyncIOResult*(asyncioQueue: AsyncIOQueuePtr, outPtr: AsyncIOOutcomePtr): bool {.importc: "SDL_GetAsyncIOResult".}
proc getResult*(asyncioQueue: AsyncIOQueuePtr, outPtr: AsyncIOOutcomePtr): bool =
  getAsyncIOResult(asyncioQueue, outPtr)
proc waitAsyncIOResult*(asyncioQueue: AsyncIOQueuePtr, outPtr: AsyncIOOutcomePtr, timeoutMs: int32): bool {.importc: "SDL_WaitAsyncIOResult".}
proc waitResult*(asyncioQueue: AsyncIOQueuePtr, outPtr: AsyncIOOutcomePtr, timeoutMs: int32): bool =
  waitAsyncIOResult(asyncioQueue, outPtr, timeoutMs)
proc signalAsyncIOQueue*(asyncioQueue: AsyncIOQueuePtr): void {.importc: "SDL_SignalAsyncIOQueue".}
proc signal*(asyncioQueue: AsyncIOQueuePtr): void =
  signalAsyncIOQueue(asyncioQueue)
proc loadFileAsync*(file: cstring, queue: AsyncIOQueuePtr, userdata: pointer): bool {.importc: "SDL_LoadFileAsync".}

## Section: SDL_atomic.h

type
  SpinLock* = distinct cint
  SpinLockPtr* = ptr SpinLock
  AtomicIntPtr* = ptr AtomicInt
  AtomicInt* = distinct cint
  AtomicU32Ptr* = ptr AtomicU32
  AtomicU32* = distinct uint32

proc tryLockSpinLock*(lock: SpinLockPtr): bool {.importc: "SDL_TryLockSpinLock".}
proc tryLock*(lock: SpinLockPtr): bool =
  tryLockSpinLock(lock)
proc lockSpinLock*(lock: SpinLockPtr): void {.importc: "SDL_LockSpinLock".}
proc lock*(lock: SpinLockPtr): void =
  lockSpinLock(lock)
proc unlockSpinLock*(lock: SpinLockPtr): void {.importc: "SDL_UnlockSpinLock".}
proc unlock*(lock: SpinLockPtr): void =
  unlockSpinLock(lock)

proc memoryBarrierReleaseFunction*(): void {.importc: "SDL_MemoryBarrierReleaseFunction".}
proc memoryBarrierAcquireFunction*(): void {.importc: "SDL_MemoryBarrierAcquireFunction".}

proc compareAndSwapAtomicU32*(atom: AtomicU32Ptr, oldValue, newValue: uint32): bool {.importc: "SDL_CompareAndSwapAtomicU32".}
proc compareAndSwap*(atom: AtomicU32Ptr, oldValue, newValue: uint32): bool =
  compareAndSwapAtomicU32(atom, oldValue, newValue)
proc setAtomicU32*(atom: AtomicU32Ptr, value: uint32): uint32 {.importc: "SDL_SetAtomicU32".}
proc set*(atom: AtomicU32Ptr, value: uint32): uint32 =
  setAtomicU32(atom, value)
proc getAtomicU32*(atom: AtomicU32Ptr): uint32 {.importc: "SDL_GetAtomicU32".}
proc get*(atom: AtomicU32Ptr): uint32 =
  getAtomicU32(atom)
proc addAtomicU32*(atom: AtomicU32Ptr, value: uint32): uint32 {.importc: "SDL_AddAtomicU32".}
proc add*(atom: AtomicU32Ptr, value: uint32): uint32 =
  addAtomicU32(atom, value)
proc compareAndSwapAtomicPointer*(atom: AtomicIntPtr, oldValue, newValue: pointer): bool {.importc: "SDL_CompareAndSwapAtomicPointer".}
proc compareAndSwap*(atom: AtomicIntPtr, oldValue, newValue: pointer): bool =
  compareAndSwapAtomicPointer(atom, oldValue, newValue)
proc setAtomicPointer*(atom: AtomicIntPtr, value: pointer): pointer {.importc: "SDL_SetAtomicPointer".}
proc set*(atom: AtomicIntPtr, value: pointer): pointer =
  setAtomicPointer(atom, value)
proc getAtomicPointer*(atom: AtomicIntPtr): pointer {.importc: "SDL_GetAtomicPointer".}
proc get*(atom: AtomicIntPtr): pointer =
  getAtomicPointer(atom)

## Section: SDL_properties.h

type
  PropertiesId* = distinct uint32
  PropertyType* {.size: sizeof(cint).} = enum
    Invalid
    Pointer
    String
    Number
    Float
    Boolean
  
  CleanupPropertyCb* = proc(userdata, value: pointer) {.cdecl.}
  EnumeratePropertiesCb* = proc(userdata: pointer, props: PropertiesId, name: cstring) {.cdecl.}

proc getGlobalProperties*(): PropertiesId {.importc: "SDL_GetGlobalProperties".}
proc createProperties*(): PropertiesId {.importc: "SDL_CreateProperties".}
proc newProperties*(): PropertiesId =
  createProperties()
proc hasProperty*(props: PropertiesId, name: cstring): bool {.importc: "SDL_HasProperty".}
proc getPropertyType*(props: PropertiesId, name: cstring): PropertyType {.importc: "SDL_GetPropertyType".}

proc getPointerProperty*(props: PropertiesId, name: cstring, defaultValue: pointer): pointer {.importc: "SDL_GetPointerProperty".}
proc getStringProperty*(props: PropertiesId, name, defaultValue: cstring): cstring {.importc: "SDL_GetStringProperty".}
proc getNumberProperty*(props: PropertiesId, name: cstring, defaultValue: int64): int64 {.importc: "SDL_GetNumberProperty".}
proc getFloatProperty*(props: PropertiesId, name: cstring, defaultValue: float32): float32 {.importc: "SDL_GetFloatProperty".}
proc getBooleanProperty*(props: PropertiesId, name: cstring, defaultValue: bool): bool {.importc: "SDL_GetBooleanProperty".}

proc setPointerProperty*(props: PropertiesId, name: cstring, value: pointer): bool {.importc: "SDL_SetPointerProperty".}
proc setPointerProperty*(props: PropertiesId, name: cstring, value: pointer, cleanupCb: CleanupPropertyCb, userdata: pointer): bool {.importc: "SDL_SetPointerPropertyWithCleanup".}
proc setStringProperty*(props: PropertiesId, name, value: cstring): bool {.importc: "SDL_SetStringProperty".}
proc setNumberProperty*(props: PropertiesId, name: cstring, value: int64): bool {.importc: "SDL_SetNumberProperty".}
proc setFloatProperty*(props: PropertiesId, name: cstring, value: float32): bool {.importc: "SDL_SetFloatProperty".}
proc setBooleanProperty*(props: PropertiesId, name: cstring, value: bool): bool {.importc: "SDL_SetBooleanProperty".}

proc enumerateProperties*(props: PropertiesId, enumCb: EnumeratePropertiesCb, userdata: pointer): void {.importc: "SDL_EnumerateProperties".}
proc clearProperty*(props: PropertiesId, name: cstring): bool {.importc: "SDL_ClearProperty".}
proc clear*(props: PropertiesId, name: cstring): bool =
  clearProperty(props, name)

proc copy*(srcProps, dstProps: PropertiesId): bool {.importc: "SDL_CopyProperties".}
proc lock*(props: PropertiesId): bool {.importc: "SDL_LockProperties".}
proc unlock*(props: PropertiesId): void {.importc: "SDL_UnlockProperties".}
proc destroy*(props: PropertiesId): void {.importc: "SDL_DestroyProperties".}

## Section: SDL_iostream.h

type  
  IOStatusPtr* = ptr IOStatus
  IOStatus* {.size: sizeof(cint).} = enum
    Ready
    Error
    EndOfFile
    NotReady
    ReadOnly
    WriteOnly
  IOWhence* {.size: sizeof(cint).} = enum
    Set
    Current
    End
  
  IOStreamPtr* = ptr object
  IOStreamInterfaceSizeCb* = proc(userdata: pointer): int64 {.cdecl.}
  IOStreamInterfaceSeekCb* = proc(userdata: pointer, offset: int64, whence: IOWhence): int64 {.cdecl.}
  IOStreamInterfaceReadCb* = proc(userdata, locPtr: pointer, size: uint, status: IOStatusPtr): uint {.cdecl.}
  IOStreamInterfaceWriteCb* = proc(userdata, locPtr: pointer, size: uint, status: IOStatusPtr): uint {.cdecl.}
  IOStreamInterfaceFlushCb* = proc(userdata: pointer, status: IOStatusPtr): bool {.cdecl.}
  IOStreamInterfaceCloseCb* = proc(userdata: pointer): bool {.cdecl.}
  IOStreamInterfacePtr* = ptr IOStreamInterface
  IOStreamInterface* {.bycopy.} = object
    version: uint32
    size: IOStreamInterfaceSizeCb
    seek: IOStreamInterfaceSeekCb
    read: IOStreamInterfaceReadCb
    write: IOStreamInterfaceWriteCb
    flush: IOStreamInterfaceFlushCb
    close: IOStreamInterfaceCloseCb

const
  IOSTREAM_WINDOWS_HANDLE_POINTER* = "SDL.iostream.windows.handle"
  IOSTREAM_STDIO_FILE_POINTER* = "SDL.iostream.stdio.file"
  IOSTREAM_FILE_DESCRIPTOR_NUMBER* = "SDL.iostream.file_descriptor"
  IOSTREAM_ANDROID_AASSET_POINTER* = "SDL.iostream.android.aasset"
  IOSTREAM_MEMORY_POINTER* = "SDL.iostream.memory.base"
  IOSTREAM_MEMORY_SIZE_NUMBER* = "SDL.iostream.memory.size"
  IOSTREAM_MEMORY_FREE_FUNC_POINTER* = "SDL.iostream.memory.free"
  IOSTREAM_DYNAMIC_MEMORY_POINTER* = "SDL.iostream.dynamic.memory"
  IOSTREAM_DYNAMIC_CHUNKSIZE_NUMBER* = "SDL.iostream.dynamic.chunksize"

proc IOFromFile*(file, mode: cstring): IOStreamPtr {.importc: "SDL_IOFromFile".}
proc newIOStream*(file, mode: cstring): IOStreamPtr =
  IOFromFile(file, mode)
proc IOFromMemory*(memPtr: pointer, size: uint): IOStreamPtr {.importc: "SDL_IOFromMem".}
proc newIOStreamFromMemory*(memPtr: pointer, size: uint): IOStreamPtr =
  IOFromMemory(memPtr, size)
proc IOFromConstMemory*(memPtr: pointer, size: uint): IOStreamPtr {.importc: "SDL_IOFromConstMem".}
proc newIOStreamFromConstMemory*(memPtr: pointer, size: uint): IOStreamPtr =
  IOFromConstMemory(memPtr, size)
proc IOFromDynamicMem*(): IOStreamPtr {.importc: "SDL_IOFromDynamicMem".}
proc newIOStreamFromDynamicMem*(): IOStreamPtr =
  IOFromDynamicMem()

proc openIO*(iface: IOStreamInterfacePtr, userdata: pointer): IOStreamPtr {.importc: "SDL_OpenIO".}
proc open*(iface: IOStreamInterfacePtr, userdata: pointer): IOStreamPtr =
  openIO(iface, userdata)
proc closeIO*(iostream: IOStreamPtr): void {.importc: "SDL_CloseIO".}
proc close*(iostream: IOStreamPtr): void =
  closeIO(iostream)

proc getIOProperties*(iostream: IOStreamPtr): PropertiesId {.importc: "SDL_GetIOProperties".}
proc getProperties*(iostream: IOStreamPtr): PropertiesId =
  getIOProperties(iostream)
proc getIOStatus*(iostream: IOStreamPtr): IOStatus {.importc: "SDL_GetIOStatus".}
proc getStatus*(iostream: IOStreamPtr): IOStatus =
  getIOStatus(iostream)
proc getIOSize*(iostream: IOStreamPtr): int64 {.importc: "SDL_GetIOSize".}
proc getSize*(iostream: IOStreamPtr): int64 =
  getIOSize(iostream)

proc seekIO*(iostream: IOStreamPtr, offset: int64, whence: IOWhence): int64 {.importc: "SDL_SeekIO".}
proc seek*(iostream: IOStreamPtr, offset: int64, whence: IOWhence): int64 =
  seekIO(iostream, offset, whence)
proc tellIO*(iostream: IOStreamPtr): int64 {.importc: "SDL_TellIO".}
proc tell*(iostream: IOStreamPtr): int64 =
  tellIO(iostream)
proc readIO*(iostream: IOStreamPtr, readPtr: pointer, size: uint): uint {.importc: "SDL_ReadIO".}
proc read*(iostream: IOStreamPtr, readPtr: pointer, size: uint): uint =
  readIO(iostream, readPtr, size)
proc writeIO*(iostream: IOStreamPtr, writePtr: pointer, size: uint): uint {.importc: "SDL_WriteIO".}
proc write*(iostream: IOStreamPtr, writePtr: pointer, size: uint): uint =
  writeIO(iostream, writePtr, size)
proc flushIO*(iostream: IOStreamPtr): bool {.importc: "SDL_FlushIO".}
proc flush*(iostream: IOStreamPtr): bool =
  flushIO(iostream)

# proc printf*(iostream)
# proc vprintf*(iostream)

proc loadFile*(srcIoStream: IOStreamPtr, datasize: ptr uint, closeIo: bool): pointer {.importc: "SDL_LoadFile_IO".}
proc loadFile*(file: cstring, datasize: ptr uint): pointer {.importc: "SDL_LoadFile".}
proc saveFile*(srcIoStream: IOStreamPtr, data: pointer, datasize: uint, closeIo: bool): bool {.importc: "SDL_SaveFile_IO".}
proc saveFile*(file: cstring, data: pointer, datasize: uint): bool {.importc: "SDL_SaveFile".}

proc readU8*(iostream: IOStreamPtr, outVal: ptr uint8): bool {.importc: "SDL_ReadU8".}
# proc readU8*(iostream: IOStreamPtr): ptr uint8 =
  # var val: uint8
  # if readU8(iostream, addr val):
  #   return addr val
  # else:
  #   return nil

proc readS8*(iostream: IOStreamPtr, outVal: ptr int8): bool {.importc: "SDL_ReadS8".}
# proc readS8*(iostream: IOStreamPtr): ptr int8 =
#   var val: int8
#   if readS8(iostream, addr val):
#     return addr val
#   else:
#     return nil

## TODO: more overloads, maybe write a template so that I dont have to repeat this like 20 times over

proc readU16LE*(iostream: IOStreamPtr, outVal: ptr uint16): bool {.importc: "SDL_ReadU16LE".}
proc readS16LE*(iostream: IOStreamPtr, outVal: ptr int16): bool {.importc: "SDL_ReadS16LE".}
proc readU16BE*(iostream: IOStreamPtr, outVal: ptr uint16): bool {.importc: "SDL_ReadU16BE".}
proc readS16BE*(iostream: IOStreamPtr, outVal: ptr int16): bool {.importc: "SDL_ReadS16BE".}
proc readU32LE*(iostream: IOStreamPtr, outVal: ptr uint32): bool {.importc: "SDL_ReadU32LE".}
proc readS32LE*(iostream: IOStreamPtr, outVal: ptr int32): bool {.importc: "SDL_ReadS32LE".}
proc readU32BE*(iostream: IOStreamPtr, outVal: ptr uint32): bool {.importc: "SDL_ReadU32BE".}
proc readS32BE*(iostream: IOStreamPtr, outVal: ptr int32): bool {.importc: "SDL_ReadS32BE".}
proc readU64LE*(iostream: IOStreamPtr, outVal: ptr uint64): bool {.importc: "SDL_ReadU64LE".}
proc readS64LE*(iostream: IOStreamPtr, outVal: ptr int64): bool {.importc: "SDL_ReadS64LE".}
proc readU64BE*(iostream: IOStreamPtr, outVal: ptr uint64): bool {.importc: "SDL_ReadU64BE".}
proc readS64BE*(iostream: IOStreamPtr, outVal: ptr int64): bool {.importc: "SDL_ReadS64BE".}

proc writeU8*(iostream: IOStreamPtr, value: uint8): bool {.importc: "SDL_WriteU8".}
proc writeS8*(iostream: IOStreamPtr, value: int8): bool {.importc: "SDL_WriteS8".}
proc writeU16LE*(iostream: IOStreamPtr, value: uint16): bool {.importc: "SDL_WriteU16LE".}
proc writeS16LE*(iostream: IOStreamPtr, value: int16): bool {.importc: "SDL_WriteS16LE".}
proc writeU16BE*(iostream: IOStreamPtr, value: uint16): bool {.importc: "SDL_WriteU16BE".}
proc writeS16BE*(iostream: IOStreamPtr, value: int16): bool {.importc: "SDL_WriteS16BE".}
proc writeU32LE*(iostream: IOStreamPtr, value: uint32): bool {.importc: "SDL_WriteU32LE".}
proc writeS32LE*(iostream: IOStreamPtr, value: int32): bool {.importc: "SDL_WriteS32LE".}
proc writeU32BE*(iostream: IOStreamPtr, value: uint32): bool {.importc: "SDL_WriteU32BE".}
proc writeS32BE*(iostream: IOStreamPtr, value: int32): bool {.importc: "SDL_WriteS32BE".}
proc writeU64LE*(iostream: IOStreamPtr, value: uint64): bool {.importc: "SDL_WriteU64LE".}
proc writeS64LE*(iostream: IOStreamPtr, value: int64): bool {.importc: "SDL_WriteS64LE".}
proc writeU64BE*(iostream: IOStreamPtr, value: uint64): bool {.importc: "SDL_WriteU64BE".}
proc writeS64BE*(iostream: IOStreamPtr, value: int64): bool {.importc: "SDL_WriteS64BE".}


## Section: SDL_audio.h

type
  AudioFormat* {.size: sizeof(cint).} = enum
    Unknown = 0x0000,
    U8 = 0x0008,
    S8 = 0x8008,
    S16LE = 0x8010,
    S32LE = 0x8020,
    F32LE = 0x8120,
    S16BE = 0x9010,
    S32BE = 0x9020,
    F32BE = 0x9120 

  AudioDeviceID* = distinct uint32
  AudioSpecPtr* = ptr AudioSpec
  AudioSpec* {.bycopy.} = object
    format*: AudioFormat
    channels*: cint
    freq*: cint
  
  AudioStreamPtr = ptr object
  AudioStreamCb* = proc(userdata: pointer, stream: AudioStreamPtr, additionalAmount, totalAmount: cint): void {.cdecl.}
  AudioStreamDataCompleteCb* = proc(userdata, buffer: pointer, bufferLen: cint): void {.cdecl.}
  AudioPostmixCb* = proc(userdata: pointer, spec: AudioSpecPtr, buffer: ptr float, bufferLen: cint): void {.cdecl.}

const
  AUDIO_S16* = AudioFormat.S16LE
  AUDIO_S32* = AudioFormat.S32LE
  AUDIO_F32* = AudioFormat.F32LE

  DEVICE_DEFAULT_PLAYBACK* = AudioDeviceID(0xFFFFFFFF)
  DEVICE_DEFAULT_RECORDING* = AudioDeviceID(0xFFFFFFFE)

proc getNumAudioDrivers*(): cint {.importc: "SDL_GetNumAudioDrivers".}
proc getAudioDriver*(index: cint): cstring {.importc: "SDL_GetAudioDriver".}
proc getCurrentAudioDriver*(): cstring {.importc: "SDL_GetCurrentAudioDriver".}
proc getAudioPlaybackDevices*(count: ptr cint): ptr AudioDeviceID {.importc: "SDL_GetAudioPlaybackDevices".}
proc getAudioRecordingDevices*(count: ptr cint): ptr AudioDeviceID {.importc: "SDL_GetAudioRecordingDevices".}
proc getAudioRecordingDevices*(): seq[AudioDeviceID] =
  var count: cint
  let devicesPtr = getAudioRecordingDevices(addr count)
  result = newSeq[AudioDeviceID](count)
  var arr = cast[ptr UncheckedArray[AudioDeviceID]](devicesPtr)
  for i in 0 ..< count:
    result[i] = arr[i]

## will do more of these, but only once ive finished the rest of the modules

proc getAudioDeviceName*(deviceID: AudioDeviceID): cstring {.importc: "SDL_GetAudioDeviceName".}
proc getName*(deviceID: AudioDeviceID): cstring =
  getAudioDeviceName(deviceID)
proc getAudioDeviceFormat*(deviceID: AudioDeviceId, spec: AudioSpecPtr, sampleFrames: ptr cint): bool {.importc: "SDL_GetAudioDeviceFormat".}
proc getFormat*(deviceID: AudioDeviceId, spec: AudioSpecPtr, sampleFrames: ptr cint): bool =
  getAudioDeviceFormat(deviceID, spec, sampleFrames)
proc getAudioDeviceChannelMap*(deviceID: AudioDeviceId, count: ptr cint): ptr cint {.importc: "SDL_GetAudioDeviceChannelMap".}
proc getChannelMap*(deviceID: AudioDeviceId, count: ptr cint): ptr cint =
  getAudioDeviceChannelMap(deviceID, count)

proc openAudioDevice*(deviceID: AudioDeviceId, spec: AudioSpecPtr): AudioDeviceID {.importc: "SDL_OpenAudioDevice".}
proc open*(deviceID: AudioDeviceId, spec: AudioSpecPtr): AudioDeviceID =
  openAudioDevice(deviceID, spec)

proc isAudioDevicePhysical*(deviceID: AudioDeviceID): bool {.importc: "SDL_IsAudioDevicePhysical".}
proc isPhysical*(deviceID: AudioDeviceID): bool =
  isAudioDevicePhysical(deviceID)
proc isAudioDevicePlayback*(deviceID: AudioDeviceID): bool {.importc: "SDL_IsAudioDevicePlayback".}
proc isPlayback*(deviceID: AudioDeviceID): bool =
  isAudioDevicePlayback(deviceID)
proc pauseAudioDevice*(deviceID: AudioDeviceID): bool {.importc: "SDL_PauseAudioDevice".}
proc pause*(deviceID: AudioDeviceID): bool =
  pauseAudioDevice(deviceID)
proc resumeAudioDevice*(deviceID: AudioDeviceID): bool {.importc: "SDL_ResumeAudioDevice".}
proc resume*(deviceID: AudioDeviceID): bool =
  resumeAudioDevice(deviceID)
proc audioDevicePaused*(deviceID: AudioDeviceID): bool {.importc: "SDL_AudioDevicePaused".}
proc isPaused*(deviceID: AudioDeviceID): bool =
  audioDevicePaused(deviceID)

proc getAudioDeviceGain*(deviceID: AudioDeviceId): float32 {.importc: "SDL_GetAudioDeviceGain".}
proc getGain*(deviceID: AudioDeviceId): float32 =
  getAudioDeviceGain(deviceID)
proc `gain`*(deviceID: AudioDeviceId): float32 =
  getAudioDeviceGain(deviceID)
proc setAudioDeviceGain*(deviceID: AudioDeviceId, gain: float32): bool {.importc: "SDL_SetAudioDeviceGain".}
proc setGain*(deviceID: AudioDeviceId, gain: float32): bool {.discardable.} =
  setAudioDeviceGain(deviceID, gain)
proc `gain=`*(deviceID: AudioDeviceId, gain: float32): bool {.discardable.} =
  setAudioDeviceGain(deviceID, gain)

proc closeAudioDevice*(deviceID: AudioDeviceID): void {.importc: "SDL_CloseAudioDevice".}
proc close*(deviceID: AudioDeviceID): void =
  closeAudioDevice(deviceID)

proc bindAudioStreams*(deviceID: AudioDeviceID, streams: ptr AudioStreamPtr, numStreams: cint): bool {.importc: "SDL_BindAudioStreams".}
proc bindStreams*(deviceID: AudioDeviceID, streams: ptr AudioStreamPtr, numStreams: cint): bool =
  bindAudioStreams(deviceID, streams, numStreams)
proc bindAudioStream*(deviceID: AudioDeviceID, stream: AudioStreamPtr): bool {.importc: "SDL_BindAudioStream".}
proc bindStream*(deviceID: AudioDeviceID, stream: AudioStreamPtr): bool =
  bindAudioStream(deviceID, stream)
proc unbindAudioStreams*(streams: ptr AudioStreamPtr, numStreams: cint): void {.importc: "SDL_UnbindAudioStreams".}
proc unbindStreams*(streams: ptr AudioStreamPtr, numStreams: cint): void =
  unbindAudioStreams(streams, numStreams)
proc unbindAudioStream*(stream: AudioStreamPtr): void {.importc: "SDL_UnbindAudioStream".}
proc unbindStream*(stream: AudioStreamPtr): void =
  unbindAudioStream(stream)

proc getAudioStreamDevice*(stream: AudioStreamPtr): AudioDeviceID {.importc: "SDL_GetAudioStreamDevice".}
proc getDevice*(stream: AudioStreamPtr): AudioDeviceID =
  getAudioStreamDevice(stream)

proc createAudioStream*(srcSpec, dstSpec: AudioSpecPtr): AudioStreamPtr {.importc: "SDL_CreateAudioStream".}
proc newAudioStream*(srcSpec, dstSpec: AudioSpecPtr): AudioStreamPtr =
  createAudioStream(srcSpec, dstSpec)

proc getAudioStreamProperties*(stream: AudioStreamPtr): PropertiesId {.importc: "SDL_GetAudioStreamProperties".}
proc getProperties*(stream: AudioStreamPtr): PropertiesId =
  getAudioStreamProperties(stream)

proc getAudioStreamFormat*(stream: AudioStreamPtr, srcSpec, dstSpec: AudioSpecPtr): bool {.importc: "SDL_GetAudioStreamFormat".}
proc getFormat*(stream: AudioStreamPtr, srcSpec, dstSpec: AudioSpecPtr): bool =
  getAudioStreamFormat(stream, srcSpec, dstSpec)
proc setAudioStreamFormat*(stream: AudioStreamPtr, srcSpec, dstSpec: AudioSpecPtr): bool {.importc: "SDL_SetAudioStreamFormat".}
proc setFormat*(stream: AudioStreamPtr, srcSpec, dstSpec: AudioSpecPtr): bool {.discardable.} =
  setAudioStreamFormat(stream, srcSpec, dstSpec)

proc getAudioStreamFrequencyRatio*(stream: AudioStreamPtr): float32 {.importc: "SDL_GetAudioStreamFrequencyRatio".}
proc getFrequencyRatio*(stream: AudioStreamPtr): float32 =
  getAudioStreamFrequencyRatio(stream)
proc setAudioStreamFrequencyRatio*(stream: AudioStreamPtr, ratio: float32): bool {.importc: "SDL_SetAudioStreamFrequencyRatio".}
proc setFrequencyRatio*(stream: AudioStreamPtr, ratio: float32): bool {.discardable.} =
  setAudioStreamFrequencyRatio(stream, ratio)
proc `frequencyRatio=`*(stream: AudioStreamPtr, ratio: float32): bool {.discardable.} =
  setAudioStreamFrequencyRatio(stream, ratio)

proc getAudioStreamGain*(stream: AudioStreamPtr): float32 {.importc: "SDL_GetAudioStreamGain".}
proc getGain*(stream: AudioStreamPtr): float32 =
  getAudioStreamGain(stream)
proc `gain`*(stream: AudioStreamPtr): float32 =
  getAudioStreamGain(stream)
proc setAudioStreamGain*(stream: AudioStreamPtr, gain: float32): bool {.importc: "SDL_SetAudioStreamGain".}
proc setGain*(stream: AudioStreamPtr, gain: float32): bool {.discardable.} =
  setAudioStreamGain(stream, gain)
proc `gain=`*(stream: AudioStreamPtr, gain: float32): bool {.discardable.} =
  setAudioStreamGain(stream, gain)

proc getAudioStreamInputChannelMap*(stream: AudioStreamPtr, count: ptr cint): ptr cint {.importc: "SDL_GetAudioStreamInputChannelMap".}
proc getInputChannelMap*(stream: AudioStreamPtr, count: ptr cint): ptr cint =
  getAudioStreamInputChannelMap(stream, count)
proc getAudioStreamOutputChannelMap*(stream: AudioStreamPtr, count: ptr cint): ptr cint {.importc: "SDL_GetAudioStreamOutputChannelMap".}
proc getOutputChannelMap*(stream: AudioStreamPtr, count: ptr cint): ptr cint =
  getAudioStreamOutputChannelMap(stream, count)
proc setAudioStreamInputChannelMap*(stream: AudioStreamPtr, chMap: ptr cint, count: cint): bool {.importc: "SDL_SetAudioStreamInputChannelMap".}
proc setInputChannelMap*(stream: AudioStreamPtr, chMap: ptr cint, count: cint): bool {.discardable.} =
  setAudioStreamInputChannelMap(stream, chMap, count)
proc setAudioStreamOutputChannelMap*(stream: AudioStreamPtr, chMap: ptr cint, count: cint): bool {.importc: "SDL_SetAudioStreamOutputChannelMap".}
proc setOutputChannelMap*(stream: AudioStreamPtr, chMap: ptr cint, count: cint): bool {.discardable.} =
  setAudioStreamOutputChannelMap(stream, chMap, count)

proc putAudioStreamData*(stream: AudioStreamPtr, buf: pointer, len: cint): bool {.importc: "SDL_PutAudioStreamData".}
proc putData*(stream: AudioStreamPtr, buf: pointer, len: cint): bool =
  putAudioStreamData(stream, buf, len)
proc putAudioStreamDataNoCopy*(stream: AudioStreamPtr, buf: pointer, len: cint, callback: AudioStreamDataCompleteCb, userdata: pointer): bool {.importc: "SDL_PutAudioStreamDataNoCopy".}
proc putDataNoCopy*(stream: AudioStreamPtr, buf: pointer, len: cint, callback: AudioStreamDataCompleteCb, userdata: pointer): bool =
  putAudioStreamDataNoCopy(stream, buf, len, callback, userdata)
proc putAudioStreamPlanarData*(stream: AudioStreamPtr, channelBuffers: ptr pointer, numChannels, numSamples: cint): bool {.importc: "SDL_PutAudioStreamPlanarData".}
proc putPlanarData*(stream: AudioStreamPtr, channelBuffers: ptr pointer, numChannels, numSamples: cint): bool =
  putAudioStreamPlanarData(stream, channelBuffers, numChannels, numSamples)

proc getAudioStreamData*(stream: AudioStreamPtr, buf: pointer, len: cint): cint {.importc: "SDL_GetAudioStreamData".}
proc getData*(stream: AudioStreamPtr, buf: pointer, len: cint): cint =
  getAudioStreamData(stream, buf, len)

proc getAudioStreamAvailable*(stream: AudioStreamPtr): cint {.importc: "SDL_GetAudioStreamAvailable".}
proc getAvailable*(stream: AudioStreamPtr): cint =
  getAudioStreamAvailable(stream)

proc getAudioStreamQueued*(stream: AudioStreamPtr): cint {.importc: "SDL_GetAudioStreamQueued".}
proc getQueued*(stream: AudioStreamPtr): cint =
  getAudioStreamQueued(stream)

proc flushAudioStream*(stream: AudioStreamPtr): bool {.importc: "SDL_FlushAudioStream".}
proc flush*(stream: AudioStreamPtr): bool =
  flushAudioStream(stream)
proc clearAudioStream*(stream: AudioStreamPtr): bool {.importc: "SDL_ClearAudioStream".}
proc clear*(stream: AudioStreamPtr): bool =
  clearAudioStream(stream)

proc pauseAudioStreamDevice*(stream: AudioStreamPtr): bool {.importc: "SDL_PauseAudioStreamDevice".}
proc pauseDevice*(stream: AudioStreamPtr): bool =
  pauseAudioStreamDevice(stream)
proc pause*(stream: AudioStreamPtr): bool =
  pauseAudioStreamDevice(stream)
proc resumeAudioStreamDevice*(stream: AudioStreamPtr): bool {.importc: "SDL_ResumeAudioStreamDevice".}
proc resumeDevice*(stream: AudioStreamPtr): bool =
  resumeAudioStreamDevice(stream)
proc resume*(stream: AudioStreamPtr): bool =
  resumeAudioStreamDevice(stream)
proc audioStreamDevicePaused*(stream: AudioStreamPtr): bool {.importc: "SDL_AudioStreamDevicePaused".}
proc isDevicePaused*(stream: AudioStreamPtr): bool =
  audioStreamDevicePaused(stream)
proc paused*(stream: AudioStreamPtr): bool =
  audioStreamDevicePaused(stream)

proc lockAudioStream*(stream: AudioStreamPtr): bool {.importc: "SDL_LockAudioStream".}
proc lock*(stream: AudioStreamPtr): bool =
  lockAudioStream(stream)
proc unlockAudioStream*(stream: AudioStreamPtr): bool {.importc: "SDL_UnlockAudioStream".}
proc unlock*(stream: AudioStreamPtr): bool =
  unlockAudioStream(stream)

proc setAudioStreamGetCallback*(stream: AudioStreamPtr, callback: AudioStreamCb, userdata: pointer): bool {.importc: "SDL_SetAudioStreamGetCallback".}
proc setGetCallback*(stream: AudioStreamPtr, callback: AudioStreamCb, userdata: pointer): bool =
  setAudioStreamGetCallback(stream, callback, userdata)
proc setAudioStreamPutCallback*(stream: AudioStreamPtr, callback: AudioStreamCb, userdata: pointer): bool {.importc: "SDL_SetAudioStreamPutCallback".}
proc setPutCallback*(stream: AudioStreamPtr, callback: AudioStreamCb, userdata: pointer): bool =
  setAudioStreamPutCallback(stream, callback, userdata)
proc setAudioPostMixCallback*(deviceID: AudioDeviceID, callback: AudioPostmixCb, userdata: pointer): bool {.importc: "SDL_SetAudioPostmixCallback".}
proc setPostMixCallback*(deviceID: AudioDeviceID, callback: AudioPostmixCb, userdata: pointer): bool =
  setAudioPostMixCallback(deviceID, callback, userdata)

proc destroyAudioStream*(stream: AudioStreamPtr): void {.importc: "SDL_DestroyAudioStream".}
proc destroy*(stream: AudioStreamPtr): void =
  destroyAudioStream(stream)

proc openAudioDeviceStream*(deviceID: AudioDeviceID, spec: AudioSpecPtr, callback: AudioStreamCb, userdata: pointer): AudioStreamPtr {.importc: "SDL_OpenAudioDeviceStream".}
proc openStream*(deviceID: AudioDeviceID, spec: AudioSpecPtr, callback: AudioStreamCb, userdata: pointer): AudioStreamPtr =
  openAudioDeviceStream(deviceID, spec, callback, userdata)

proc loadWavIO*(src: IOStreamPtr, closeIo: bool, spec: AudioSpecPtr, audioBuf: ptr UncheckedArray[ptr uint8], audioLen: ptr uint32): bool {.importc: "SDL_LoadWAV_IO".}
proc loadWav*(src: IOStreamPtr, spec: AudioSpecPtr, closeIo: bool, audioBuf: ptr UncheckedArray[ptr uint8], audioLen: ptr uint32): bool =
  loadWavIO(src, closeIo, spec, audioBuf, audioLen)
proc loadWav*(path: cstring, spec: AudioSpecPtr, audioBuf: ptr UncheckedArray[ptr uint8], audioLen: ptr uint32): bool {.importc: "SDL_LoadWAV".}
proc mixAudio*(dst, src: ptr uint8, format: AudioFormat, len: uint32, volume: float32): bool {.importc: "SDL_MixAudio".}
proc convertAudioSamples*(srcSpec: AudioSpecPtr, srcData: ptr uint8, srcLen: cint, dstSpec: AudioSpecPtr, dstData: ptr UncheckedArray[ptr uint8], dstLen: ptr cint): bool {.importc: "SDL_ConvertAudioSamples".}

proc getAudioFormatName*(format: AudioFormat): cstring {.importc: "SDL_GetAudioFormatName".}
proc getName*(format: AudioFormat): cstring =
  getAudioFormatName(format)
proc getSilenceValueForFormat*(format: AudioFormat): cint {.importc: "SDL_GetSilenceValueForFormat".}
proc getSilenceValue*(format: AudioFormat): cint =
  getSilenceValueForFormat(format)

## Section: SDL_bits.h

template mostSignificantBitIndex32*(x: uint32): cint =
  const b = [0x2, 0xC, 0xF0, 0xFF00, 0xFFFF0000]
  const S = [1, 2, 4, 8, 16]

  var msbIndex = 0
  var i: int

  if x == 0:
    return -1
  for i in countdown(4, 0):
    if (x and b[i]) != 0:
      x = x shr S[i]
      msbIndex = msbIndex or S[i]

  return msbIndex

template hasExactlyOneBitSet32*(x: uint32): bool =
  return (x != 0) and ((x and (x - 1)) == 0)

## Section: SDL_blendmode.h

type
  BlendMode* = distinct uint32
  BlendOperation* {.size: sizeof(cint).} = enum
    Add
    Subtract
    RevSubtract
    Minimum
    Maximum
  BlendFactor* {.size: sizeof(cint).} = enum
    Zero
    One
    SrcColor
    OneMinusSrcColor
    SrcAlpha
    OneMinusSrcAlpha
    DstColor
    OneMinusDstColor
    DstAlpha
    OneMinusDstAlpha

const
  BLENDMODE_NONE* = BlendMode(0x00000000)
  BLENDMODE_BLEND* = BlendMode(0x00000001)
  BLENDMODE_BLEND_PREMULTIPLIED* = BlendMode(0x00000010)
  BLENDMODE_ADD* = BlendMode(0x00000002)
  BLENDMODE_ADD_PREMULTIPLIED* = BlendMode(0x00000020)
  BLENDMODE_MOD* = BlendMode(0x00000004)
  BLENDMODE_MUL* = BlendMode(0x00000008)
  BLENDMODE_INVALID* = BlendMode(0x7FFFFFFF)

proc composeCustomBlendMode*(
  srcColorFactor: BlendFactor,
  dstColorFactor: BlendFactor,
  colorOperation: BlendOperation,
  srcAlphaFactor: BlendFactor,
  dstAlphaFactor: BlendFactor,
  alphaOperation: BlendOperation
): BlendMode {.importc: "SDL_ComposeCustomBlendMode".}

## Section: SDL_pixels.h

type
  PixelType* {.size: sizeof(cint).} = enum
    Unknown
    Index1,
    Index4,
    Index8,
    Packed8,
    Packed16,
    Packed32,
    ArrayU8,
    ArrayU16,
    ArrayU32,
    ArrayF16,
    ArrayF32,
    Index2
  BitmapOrder* {.size: sizeof(cint).} = enum
    None
    Order4321 
    Order1234 
  PackedOrder* {.size: sizeof(cint).} = enum
    None
    XRGB
    RGBX
    ARGB
    RGBA
    XBGR
    BGRX
    ABGR
    BGRA
  ArrayOrder* {.size: sizeof(cint).} = enum
    None
    RGB
    RGBA
    BGR
    BGRA
    ABGR
  PackedLayout* {.size: sizeof(cint).} = enum
    None
    Layout332
    Layout4444
    Layout1555
    Layout5551
    Layout565
    Layout8888
    Layout2101010
    Layout1010102
  PixelFormat* {.size: sizeof(cint).} = enum
    Unknown = 0
    Index1LSB = 0x11100100
    Index1MSB = 0x11200100
    Index2LSB = 0x1c100200
    Index2MSB = 0x1c200200
    Index4LSB = 0x12100400
    Index4MSB = 0x12200400
    Index8 = 0x13000801
    RGB332 = 0x14110801
    XRGB4444 = 0x15120c02
    XBGR4444 = 0x15520c02
    XRGB1555 = 0x15130f02
    XBGR1555 = 0x15530f02
    ARGB4444 = 0x15321002
    RGBA4444 = 0x15421002
    ABGR4444 = 0x15721002
    BGRA4444 = 0x15821002
    ARGB1555 = 0x15331002
    RGBA5551 = 0x15441002
    ABGR1555 = 0x15731002
    BGRA5551 = 0x15841002
    RGB565 = 0x15151002
    BGR565 = 0x15551002
    RGB24 = 0x17101803
    BGR24 = 0x17401803
    XRGB8888 = 0x16161804
    RGBX8888 = 0x16261804
    XBGR8888 = 0x16561804
    BGRX8888 = 0x16661804
    ARGB8888 = 0x16362004
    RGBA8888 = 0x16462004
    ABGR8888 = 0x16762004
    BGRA8888 = 0x16862004
    XRGB2101010 = 0x16172004
    XBGR2101010 = 0x16572004
    ARGB2101010 = 0x16372004
    ABGR2101010 = 0x16772004
    RGB48 = 0x18103006
    BGR48 = 0x18403006
    RGBA64 = 0x18204008
    ARGB64 = 0x18304008
    BGRA64 = 0x18504008
    ABGR64 = 0x18604008
    RGB48Float = 0x1a103006
    BGR48Float = 0x1a403006
    RGBA64Float = 0x1a204008
    ARGB64Float = 0x1a304008
    BGRA64Float = 0x1a504008
    ABGR64Float = 0x1a604008
    RGB96Float = 0x1b10600c
    BGR96Float = 0x1b40600c
    RGBA128Float = 0x1b208010
    ARGB128Float = 0x1b308010
    BGRA128Float = 0x1b508010
    ABGR128Float = 0x1b608010
    YV12 = 0x32315659
    IYUV = 0x56555949
    YUY2 = 0x32595559
    UYVY = 0x59565955
    YVYU = 0x55595659
    NV12 = 0x3231564e
    NV21 = 0x3132564e
    P010 = 0x30313050
    EXTERNAL_OES = 0x2053454f
    MJPG = 0x47504a4d

    # RGBA32 = RGBA8888 # when BIG_ENDIAN else ABGR8888
    # ARGB32 = ARGB8888 # when BIG_ENDIAN else BGRA8888
    # BGRA32 = BGRA8888 # when BIG_ENDIAN else ARGB8888
    # ABGR32 = ABGR8888 # when BIG_ENDIAN else RGBA8888
    # RGBX32 = RGBX8888 # when BIG_ENDIAN else XBGR8888
    # XRGB32 = XRGB8888 # when BIG_ENDIAN else BGRX8888
    # BGRX32 = BGRX8888 # when BIG_ENDIAN else XRGB8888
    # XBGR32 = XBGR8888 # when BIG_ENDIAN else RGBX8888
  
  ColorType* {.size: sizeof(cint).} = enum
    Unknown
    RGB
    YCBCR
  ColorRange* {.size: sizeof(cint).} = enum
    Unknown 
    Limited
    Full
  ColorPrimaries* {.size: sizeof(cint).} = enum
    Unknown = 0
    BT709 = 1
    Unspecified = 2
    BT470M = 4
    BT470BG = 5
    BT601 = 6
    SMPTE240 = 7
    GenericFilm = 8
    BT2020 = 9
    XYZ = 10
    SMPTE431 = 11
    SMPTE432 = 12
    EBU3213 = 22
    Custom = 31
  TransferCharacteristics* {.size: sizeof(cint).} = enum
    Unknown = 0
    BT709 = 1
    Unspecified = 2
    Gamma22 = 4
    Gamma28 = 5
    BT601 = 6
    SMPTE240 = 7
    Linear = 8
    Log100 = 9
    Log100Sqrt10 = 10
    IEC61966 = 11
    BT1361 = 12
    SRGB = 13
    BT2020_10Bit = 14
    BT2020_12Bit = 15
    PQ = 16
    SMPTE428 = 17
    HLG = 18
    Custom = 31
  MatrixCoefficients* {.size: sizeof(cint).} = enum
    Identity = 0
    BT709 = 1
    Unspecified = 2
    FCC = 4
    BT470BG = 5
    BT601 = 6
    SMPTE240 = 7
    YCgCo
    BT2020_NCL = 9
    BT2020_CL = 10
    SMPTE2085 = 11
    ChromaticityDerivedNCL = 12
    ChromaticityDerivedCL = 13
    ICtCp = 14
    Custom = 31
  ChromaLocation* {.size: sizeof(cint).} = enum
    Unknown = 0
    Left = 1
    Center = 2
    TopLeft = 3
  ColorSpace* {.size: sizeof(cint).} = enum
    Unknown = 0
    SRGB = 0x120005a0
    SRGBLinear = 0x12000500
    HDR10 = 0x12002600
    Jpeg = 0x220004c6
    BT601Limited = 0x211018c6
    BT601Full = 0x221018c6
    BT709Limited = 0x21100421
    BT709Full = 0x22100421
    BT2020Limited = 0x21102609
    BT2020Full = 0x22102609
  
  Color* {.bycopy.} = object
    r*, g*, b*, a*: uint8
  ColorPtr* = ptr Color
  FColor* {.bycopy.} = object
    r*, g*, b*, a*: float32
  FColorPtr* = ptr FColor
  Palette* {.bycopy.} = object
    numColors*: cint
    colors*: ptr Color
    refCount*: cint
    version: uint32
  PalettePtr* = ptr Palette
  PixelFormatDetails* {.bycopy.} = object
    format*: PixelFormat
    bitsPerPixel*: uint8
    bytesPerPixel*: uint8
    padding*: array[2, uint8]
    rMask*, gMask*, bMask*, aMask*: uint32
    rBits*, gBits*, bBits*, aBits*: uint8
    rShift*, gShift*, bShift*, aShift*: uint8
  PixelFormatDetailsPtr* = ptr PixelFormatDetails

const
  COLORSPACE_RGB_DEFAULT* = ColorSpace.SRGB
  COLORSPACE_YUV_DEFAULT* = ColorSpace.BT601Limited

  AlPHA_OPAQUE* = 255
  ALPHA_OPAQUE_FLOAT* = 1.0'f32
  ALPHA_TRANSPARENT* = 0
  ALPHA_TRANSPARENT_FLOAT* = 0.0'f32

proc getPixelFormatName*(format: PixelFormat): cstring {.importc: "SDL_GetPixelFormatName".}
proc getName*(format: PixelFormat): cstring =
  getPixelFormatName(format)

proc getMasksForPixelFormat*(format: PixelFormat, bpp: ptr cint, rMask, gMask, bMask, aMask: ptr uint32): bool {.importc: "SDL_GetMasksForPixelFormat".}
proc getMasks*(format: PixelFormat, bpp: ptr cint, rMask, gMask, bMask, aMask: ptr uint32): bool =
  getMasksForPixelFormat(format, bpp, rMask, gMask, bMask, aMask)
proc getPixelFormatForMasks*(bpp: cint, rMask, gMask, bMask, aMask: uint32): PixelFormat {.importc: "SDL_GetPixelFormatForMasks".}
proc getFormat*(bpp: cint, rMask, gMask, bMask, aMask: uint32): PixelFormat =
  getPixelFormatForMasks(bpp, rMask, gMask, bMask, aMask)
proc getPixelFormatDetails*(format: PixelFormat): PixelFormatDetailsPtr {.importc: "SDL_GetPixelFormatDetails".}
proc getDetails*(format: PixelFormat): PixelFormatDetailsPtr =
  getPixelFormatDetails(format)

proc createPalette*(numColors: cint): PalettePtr {.importc: "SDL_CreatePalette".}
proc newPalette*(numColors: cint): PalettePtr =
  createPalette(numColors)

proc setPalleteColors*(palette: PalettePtr, colors: ptr Color, firstColor: cint, numColors: cint): bool {.importc: "SDL_SetPaletteColors".}
proc setColors*(palette: PalettePtr, colors: ptr Color, firstColor: cint, numColors: cint): bool {.discardable.} =
  setPalleteColors(palette, colors, firstColor, numColors)

proc destroyPalette*(palette: PalettePtr): void {.importc: "SDL_DestroyPalette".}
proc destroy*(palette: PalettePtr): void =
  destroyPalette(palette)

proc mapRGB*(format: PixelFormatDetailsPtr, palette: PalettePtr, r, g, b: uint8): uint32 {.importc: "SDL_MapRGB".}
proc map*(format: PixelFormatDetailsPtr, palette: PalettePtr, r, g, b: uint8): uint32 =
  mapRGB(format, palette, r, g, b)
proc mapRGBA*(format: PixelFormatDetailsPtr, palette: PalettePtr, r, g, b, a: uint8): uint32 {.importc: "SDL_MapRGBA".}
proc map*(format: PixelFormatDetailsPtr, palette: PalettePtr, r, g, b, a: uint8): uint32 =
  mapRGBA(format, palette, r, g, b, a)

proc getRGB*(pixelvalue: uint32, format: PixelFormatDetailsPtr, palette: PalettePtr, r, g, b: ptr uint8): void {.importc: "SDL_GetRGB".}
proc getRGB*(pixelvalue: uint32, format: PixelFormatDetailsPtr, palette: PalettePtr): (uint8, uint8, uint8) =
  var r, g, b: uint8
  getRGB(pixelvalue, format, palette, addr r, addr g, addr b)
  return (r, g, b)
proc getRGBA*(pixelvalue: uint32, format: PixelFormatDetailsPtr, palette: PalettePtr, r, g, b, a: ptr uint8): void {.importc: "SDL_GetRGBA".}
proc getRGBA*(pixelvalue: uint32, format: PixelFormatDetailsPtr, palette: PalettePtr): (uint8, uint8, uint8, uint8) =
  var r, g, b, a: uint8
  getRGBA(pixelvalue, format, palette, addr r, addr g, addr b, addr a)
  return (r, g, b, a)

## Section: SDL_clipboard.h

type
  ClipboardDataCb* = proc(userdata: pointer, mimeType: cstring, size: ptr uint): pointer {.cdecl.}
  ClipboardCleanupCb* = proc(userdata: pointer): void {.cdecl.}

proc setClipboardText*(text: cstring): bool {.importc: "SDL_SetClipboardText".}
proc getClipboardText*(): ptr uint8 {.importc: "SDL_GetClipboardText".}
proc getClipboardTextS*(): cstring =
  let textPtr = getClipboardText()
  if textPtr == nil:
    return nil
  else:
    return cast[cstring](textPtr)
proc hasClipboardText*(): bool {.importc: "SDL_HasClipboardText".}

proc setPrimarySelectionText*(text: cstring): bool {.importc: "SDL_SetPrimarySelectionText".}
proc getPrimarySelectionText*(): ptr uint8 {.importc: "SDL_GetPrimarySelectionText".}
proc getPrimarySelectionTextS*(): cstring =
  let textPtr = getPrimarySelectionText()
  if textPtr == nil:
    return nil
  else:
    return cast[cstring](textPtr)
proc hasPrimarySelectionText*(): bool {.importc: "SDL_HasPrimarySelectionText".}

proc setClipboardData*(callback: ClipboardDataCb, cleanupCallback: ClipboardCleanupCb, userdata: pointer, mimeTypes: ptr cstring, numMimeTypes: uint): bool {.importc: "SDL_SetClipboardData".}
proc clearClipboardData*(): void {.importc: "SDL_ClearClipboardData".}
proc getClipboardData*(mimeType: cstring, size: ptr uint): pointer {.importc: "SDL_GetClipboardData".}
proc hasClipboardData*(mimeType: cstring): bool {.importc: "SDL_HasClipboardData".}
proc getClipboardMimeTypes*(numMimeTypes: ptr uint): ptr UncheckedArray[ptr uint8] {.importc: "SDL_GetClipboardMimeTypes".}

## Section: SDL_cpuinfo.h

const
  CACHELINE_SIZE* = 128

proc getNumLogicalCPUCores*(): cint {.importc: "SDL_GetNumLogicalCPUCores".}
proc getCPUCacheLineSize*(): cint {.importc: "SDL_GetCPUCacheLineSize".}
proc hasAltiVec*(): bool {.importc: "SDL_HasAltiVec".}
proc hasMMX*(): bool {.importc: "SDL_HasMMX".}
proc hasSSE*(): bool {.importc: "SDL_HasSSE".}
proc hasSSE2*(): bool {.importc: "SDL_HasSSE2".}
proc hasSSE3*(): bool {.importc: "SDL_HasSSE3".}
proc hasSSE41*(): bool {.importc: "SDL_HasSSE41".}
proc hasSSE42*(): bool {.importc: "SDL_HasSSE42".}
proc hasAVX*(): bool {.importc: "SDL_HasAVX".}
proc hasAVX2*(): bool {.importc: "SDL_HasAVX2".}
proc hasAVX512F*(): bool {.importc: "SDL_HasAVX512F".}
proc hasARMSIMD*(): bool {.importc: "SDL_HasARMSIMD".}
proc hasNeon*(): bool {.importc: "SDL_HasNEON".}
proc hasLSX*(): bool {.importc: "SDL_HasLSX".}
proc hasLASX*(): bool {.importc: "SDL_HasLASX".}
proc getSystemRAM*(): cint {.importc: "SDL_GetSystemRAM".}
proc getSIMDAlignment*(): cint {.importc: "SDL_GetSIMDAlignment".}
proc getSystemPageSize*(): cint {.importc: "SDL_GetSystemPageSize".}

## Section: SDL_error.h

#TODO: figure out c varargs
# proc setError*(fmt: cstring, args: varargs[auto]): bool {.importc: "SDL_SetError".}
# proc setErrorVa*(fmt: cstring, args: varargs[auto]): bool {.importc: "SDL_SetErrorVa".}

# template Unsupported() =
  # setError("That operation is not supported")

# template InvalidParamError*(param: typed): bool =
  # setError("Parameter '%s' is invalid", $(param))

proc outOfMemory*(): void {.importc: "SDL_OutOfMemory".}
proc getError*(): cstring {.importc: "SDL_GetError".}
proc clearError*(): void {.importc: "SDL_ClearError".}

## Section: SDL_filesystem.h

type
  Folder* {.size: sizeof(cint).} = enum
    Home
    Desktop
    Documents
    Downloads
    Music
    Pictures
    PublicShare
    SavedGames
    Screenshots
    Templates
    Videos
    Count
  PathType* {.size: sizeof(cint).} = enum
    None
    File
    Directory
    Other
  EnumerationResult* {.size: sizeof(cint).} = enum
    Continue
    Success
    Failure
  GlobFlag* {.size: sizeof(uint32).} = enum
    CaseSensitive = 0

  PathInfo* {.bycopy.} = object
    `type`*: PathType
    size*: uint64
    createTime*, accessTime*, modifyTime*: uint64

  EnumerateDirectoryCb* = proc(userdata: pointer, dirName, fileName: cstring): EnumerationResult {.cdecl.}

proc getBasePath*(): cstring {.importc: "SDL_GetBasePath".}
proc getPrefPath*(org, app: cstring): ptr uint8 {.importc: "SDL_GetPrefPath".}
proc getPrefPathS*(org, app: cstring): cstring =
  let prefPathPtr = getPrefPath(org, app)
  if prefPathPtr == nil:
    return nil
  else:
    return cast[cstring](prefPathPtr)
proc getUserFolder*(folder: Folder): cstring {.importc: "SDL_GetUserFolder".}

proc createDirectory*(dirPath: cstring): bool {.importc: "SDL_CreateDirectory".}
proc enumerateDirectory*(dirPath: cstring, callback: EnumerateDirectoryCb, userdata: pointer): bool {.importc: "SDL_EnumerateDirectory".}
proc removePath*(path: cstring): bool {.importc: "SDL_RemovePath".}
proc renamePath*(oldPath, newPath: cstring): bool {.importc: "SDL_RenamePath".}
proc copyFile*(srcPath, dstPath: cstring): bool {.importc: "SDL_CopyFile".}
proc getPathInfo*(path: cstring, info: ptr PathInfo): bool {.importc: "SDL_GetPathInfo".}
proc getPathInfo*(path: cstring): PathInfo =
  var info: PathInfo
  if getPathInfo(path, addr info):
    return info
  else:
    echo getError()
    return PathInfo(type: PathType.None)
proc globDirectory*(path, pattern: cstring, flags: GlobFlag, count: ptr cint): ptr UncheckedArray[ptr uint8] {.importc: "SDL_GlobDirectory".}

## Section: SDL_rect.h

type
  Point* {.bycopy.} = object
    x*, y*: cint
  FPoint* {.bycopy.} = object
    x*, y*: float32
  Rect* {.bycopy.} = object
    x*, y*, w*, h*: cint
  FRect* {.bycopy.} = object
    x*, y*, w*, h*: float32

proc toFRect*(rect: Rect, frect: ptr FRect): void =
  frect.x = float32(rect.x)
  frect.y = float32(rect.y)
  frect.w = float32(rect.w)
  frect.h = float32(rect.h)
proc toFRect*(rect: Rect): FRect =
  FRect(x: float32(rect.x), y: float32(rect.y), w: float32(rect.w), h: float32(rect.h))

proc inRect*(point: Point, rect: Rect): bool =
  (point.x >= rect.x) and (point.x < rect.x + rect.w) and (point.y >= rect.y) and (point.y < rect.y + rect.h)
proc inRect*(point: FPoint, rect: FRect): bool =
  (point.x >= rect.x) and (point.x < rect.x + rect.w) and (point.y >= rect.y) and (point.y < rect.y + rect.h)
proc empty*(rect: Rect): bool =
  (rect.w <= 0) or (rect.h <= 0)
proc empty*(rect: FRect): bool =
  (rect.w <= 0.0) or (rect.h <= 0.0)
proc `==`*(r1, r2: Rect): bool =
  (r1.x == r2.x) and (r1.y == r2.y) and (r1.w == r2.w) and (r1.h == r2.h)
proc `==`*(r1, r2: FRect): bool =
  (r1.x == r2.x) and (r1.y == r2.y) and (r1.w == r2.w) and (r1.h == r2.h)

proc hasIntersection*(r1, r2: Rect): bool {.importc: "SDL_HasRectIntersection".}
proc hasIntersection*(r1, r2: FRect): bool {.importc: "SDL_HasRectIntersectionFloat".}

proc getIntersection*(r1, r2: Rect, result: ptr Rect): bool {.importc: "SDL_GetRectIntersection".}
proc getIntersection*(r1, r2: FRect, result: ptr FRect): bool {.importc: "SDL_GetRectIntersectionFloat".}
proc getIntersection*(r1, r2: Rect): Rect =
  discard getIntersection(r1, r2, addr result)
proc getIntersection*(r1, r2: FRect): FRect =
  discard getIntersection(r1, r2, addr result)

proc getUnion*(r1, r2: Rect, result: ptr Rect): void {.importc: "SDL_GetRectUnion".}
proc getUnion*(r1, r2: FRect, result: ptr FRect): void {.importc: "SDL_GetRectUnionFloat".}

proc getEnclosingPoints*(points: ptr Point, count: cint, clipRect: Rect, result: ptr Rect): bool {.importc: "SDL_GetRectEnclosingPoints".}
proc getEnclosingPoints*(points: ptr FPoint, count: cint, clipRect: FRect, result: ptr FRect): bool {.importc: "SDL_GetRectEnclosingPointsFloat".}

proc getIntersectionAndLine*(rect: Rect, x1, y1, x2, y2: ptr cint): bool {.importc: "SDL_GetRectAndLineIntersection".}
proc getIntersectionAndLine*(rect: FRect, x1, y1, x2, y2: ptr float32): bool {.importc: "SDL_GetRectAndLineIntersectionFloat".}

## Section: SDL_surface.h

type
  SurfaceFlag* {.size: sizeof(uint32).} = enum
    Preallocated = 0
    LockNeeded = 1
    Locked = 2
    SimdAligned = 3
  ScaleMode* {.size: sizeof(cint).} = enum
    Invalid = -1
    Nearest
    Linear
    Best
  FlipMode* {.size: sizeof(cint).} = enum
    None = 0
    Horizontal = 1
    Vertical = 2
    Both = 3
  Surface* {.bycopy.} = object
    flags*: set[SurfaceFlag]
    format*: PixelFormat
    w*, h*: cint
    pitch*: cint
    pixels*: pointer

    refCount*: cint
    reserved*: pointer
  SurfacePtr* = ptr Surface


proc mustLock*(surface: SurfacePtr): bool =
  SurfaceFlag.LockNeeded in surface.flags

proc createSurface*(width, height: cint, format: PixelFormat): SurfacePtr {.importc: "SDL_CreateSurface".}
proc createSurface*(width, height: cint, format: PixelFormat, pixels: pointer, pitch: cint): SurfacePtr {.importc: "SDL_CreateSurfaceFrom".}
proc destroySurface*(surface: SurfacePtr): void {.importc: "SDL_DestroySurface".}
proc destroy*(surface: SurfacePtr): void =
  destroySurface(surface)

proc getSurfaceProperties*(surface: SurfacePtr): PropertiesID {.importc: "SDL_GetSurfaceProperties".}
proc getProperties*(surface: SurfacePtr): PropertiesID =
  getSurfaceProperties(surface)

proc setSurfaceColorspace*(surface: SurfacePtr, colorspace: ColorSpace): bool {.importc: "SDL_SetSurfaceColorspace".}
proc setColorspace*(surface: SurfacePtr, colorspace: ColorSpace): bool {.discardable.} =
  setSurfaceColorspace(surface, colorspace)
proc `colorspace=`*(surface: SurfacePtr, colorspace: ColorSpace): bool {.discardable.} =
  setSurfaceColorspace(surface, colorspace)

proc getSurfaceColorspace*(surface: SurfacePtr): ColorSpace {.importc: "SDL_GetSurfaceColorspace".}
proc getColorspace*(surface: SurfacePtr): ColorSpace =
  getSurfaceColorspace(surface)
proc `colorspace`*(surface: SurfacePtr): ColorSpace =
  getSurfaceColorspace(surface)

proc createSurfacePalette*(surface: SurfacePtr): PalettePtr {.importc: "SDL_CreateSurfacePalette".}
proc createPalette*(surface: SurfacePtr): PalettePtr =
  createSurfacePalette(surface)

proc setSurfacePalette*(surface: SurfacePtr, palette: PalettePtr): bool {.importc: "SDL_SetSurfacePalette".}
proc setPalette*(surface: SurfacePtr, palette: PalettePtr): bool {.discardable.} =
  setSurfacePalette(surface, palette)
proc `palette=`*(surface: SurfacePtr, palette: PalettePtr): bool {.discardable.} =
  setSurfacePalette(surface, palette)

proc getSurfacePalette*(surface: SurfacePtr): PalettePtr {.importc: "SDL_GetSurfacePalette".}
proc getPalette*(surface: SurfacePtr): PalettePtr =
  getSurfacePalette(surface)
proc `palette`*(surface: SurfacePtr): PalettePtr =
  getSurfacePalette(surface)

proc addSurfaceAlternateImage*(surface, image: SurfacePtr): bool {.importc: "SDL_AddSurfaceAlternateImage".}
proc addAlternateImage*(surface, image: SurfacePtr): bool {.discardable.} =
  addSurfaceAlternateImage(surface, image)
proc surfaceHasAlternateImages*(surface: SurfacePtr): bool {.importc: "SDL_SurfaceHasAlternateImages".}
proc hasAlternateImages*(surface: SurfacePtr): bool =
  surfaceHasAlternateImages(surface)
proc getSurfaceImages*(surface: SurfacePtr, count: ptr cint): ptr SurfacePtr {.importc: "SDL_GetSurfaceImages".}
proc getImages*(surface: SurfacePtr, count: ptr cint): ptr SurfacePtr =
  getSurfaceImages(surface, count)
proc `images`*(surface: SurfacePtr, count: ptr cint): ptr SurfacePtr =
  getSurfaceImages(surface, count)
proc removeSurfaceAlternateImages*(surface: SurfacePtr): void {.importc: "SDL_RemoveSurfaceAlternateImages".}
proc removeAlternateImages*(surface: SurfacePtr): void =
  removeSurfaceAlternateImages(surface)

proc lockSurface*(surface: SurfacePtr): bool {.importc: "SDL_LockSurface".}
proc lock*(surface: SurfacePtr): bool =
  lockSurface(surface)
proc unlockSurface*(surface: SurfacePtr): void {.importc: "SDL_UnlockSurface".}
proc unlock*(surface: SurfacePtr): void =
  unlockSurface(surface)

proc loadSurface*(src: IOStreamPtr, closeIo: bool): SurfacePtr {.importc: "SDL_LoadSurface_IO".}
proc loadSurface*(file: cstring): SurfacePtr {.importc: "SDL_LoadSurface".}

proc loadBMP*(src: IOStreamPtr, closeIo: bool): SurfacePtr {.importc: "SDL_LoadBMP_IO".}
proc loadBMP*(file: cstring): SurfacePtr {.importc: "SDL_LoadBMP".}
proc saveBMP*(surface: SurfacePtr, dst: IOStreamPtr, closeIo: bool): bool {.importc: "SDL_SaveBMP_IO".}
proc saveBMP*(surface: SurfacePtr, file: cstring): bool {.importc: "SDL_SaveBMP".}
proc loadPNG*(src: IOStreamPtr, closeIo: bool): SurfacePtr {.importc: "SDL_LoadPNG_IO".}
proc loadPNG*(file: cstring): SurfacePtr {.importc: "SDL_LoadPNG".}
proc savePNG*(surface: SurfacePtr, dst: IOStreamPtr, closeIo: bool): bool {.importc: "SDL_SavePNG_IO".}
proc savePNG*(surface: SurfacePtr, file: cstring): bool {.importc: "SDL_SavePNG".}

proc setSurfaceRLE*(surface: SurfacePtr, enabled: bool): bool {.importc: "SDL_SetSurfaceRLE".}
proc setRLE*(surface: SurfacePtr, enabled: bool): bool {.discardable.} =
  setSurfaceRLE(surface, enabled)
proc surfaceHasRLE*(surface: SurfacePtr): bool {.importc: "SDL_SurfaceHasRLE".}
proc hasRLE*(surface: SurfacePtr): bool =
  surfaceHasRLE(surface)

proc setSurfaceColorKey*(surface: SurfacePtr, enabled: bool, key: uint32): bool {.importc: "SDL_SetSurfaceColorKey".}
proc setColorKey*(surface: SurfacePtr, enabled: bool, key: uint32): bool {.discardable.} =
  setSurfaceColorKey(surface, enabled, key)
proc `colorKey=`*(surface: SurfacePtr, enabled: bool, key: uint32): bool {.discardable.} =
  setSurfaceColorKey(surface, enabled, key)

proc surfaceHasColorKey*(surface: SurfacePtr): bool {.importc: "SDL_SurfaceHasColorKey".}
proc hasColorKey*(surface: SurfacePtr): bool =
  surfaceHasColorKey(surface)
proc getSurfaceColorKey*(surface: SurfacePtr, key: ptr uint32): bool {.importc: "SDL_GetSurfaceColorKey".}
proc getSurfaceColorKey*(surface: SurfacePtr): uint32 =
  var key: uint32
  if getSurfaceColorKey(surface, addr key):
    return key
  else:
    echo getError()
    return 0
proc getColorKey*(surface: SurfacePtr, key: ptr uint32): bool {.discardable.} =
  getSurfaceColorKey(surface, key)
proc getColorKey*(surface: SurfacePtr): uint32 =
  getSurfaceColorKey(surface)
proc `colorKey`*(surface: SurfacePtr): uint32 =
  getSurfaceColorKey(surface)

proc setSurfaceColorMod*(surface: SurfacePtr, r, g, b: uint8): bool {.importc: "SDL_SetSurfaceColorMod".}
proc setColorMod*(surface: SurfacePtr, r, g, b: uint8): bool {.discardable.} =
  setSurfaceColorMod(surface, r, g, b)
proc getSurfaceColorMod*(surface: SurfacePtr, r, g, b: ptr uint8): bool {.importc: "SDL_GetSurfaceColorMod".}
proc getColorMod*(surface: SurfacePtr, r, g, b: ptr uint8): bool {.discardable.} =
  getSurfaceColorMod(surface, r, g, b)
proc getColorMod*(surface: SurfacePtr): (uint8, uint8, uint8) =
  var r, g, b: uint8
  if getSurfaceColorMod(surface, addr r, addr g, addr b):
    return (r, g, b)
  else:
    echo getError()
    return (0, 0, 0)

proc setSurfaceAlphaMod*(surface: SurfacePtr, alpha: uint8): bool {.importc: "SDL_SetSurfaceAlphaMod".}
proc setAlphaMod*(surface: SurfacePtr, alpha: uint8): bool {.discardable.} =
  setSurfaceAlphaMod(surface, alpha)
proc `alphaMod=`*(surface: SurfacePtr, alpha: uint8): bool {.discardable.} =
  setSurfaceAlphaMod(surface, alpha)
proc getSurfaceAlphaMod*(surface: SurfacePtr, alpha: ptr uint8): bool {.importc: "SDL_GetSurfaceAlphaMod".}
proc getAlphaMod*(surface: SurfacePtr, alpha: ptr uint8): bool {.discardable.} = 
  getSurfaceAlphaMod(surface, alpha)
proc getAlphaMod*(surface: SurfacePtr): uint8 =
  var alpha: uint8
  if getSurfaceAlphaMod(surface, addr alpha):
    return alpha
  else:
    echo getError()
    return 0
proc `alphaMod`*(surface: SurfacePtr): uint8 =
  getAlphaMod(surface)

proc setSurfaceBlendMode*(surface: SurfacePtr, blendMode: BlendMode): bool {.importc: "SDL_SetSurfaceBlendMode".}
proc setBlendMode*(surface: SurfacePtr, blendMode: BlendMode): bool {.discardable.} =
  setSurfaceBlendMode(surface, blendMode)
proc `blendMode=`*(surface: SurfacePtr, blendMode: BlendMode): bool {.discardable.} =
  setSurfaceBlendMode(surface, blendMode)
proc getSurfaceBlendMode*(surface: SurfacePtr, blendMode: ptr BlendMode): bool {.importc: "SDL_GetSurfaceBlendMode".}
proc getBlendMode*(surface: SurfacePtr, blendMode: ptr BlendMode): bool {.discardable.} =
  getSurfaceBlendMode(surface, blendMode)
proc getBlendMode*(surface: SurfacePtr): BlendMode =
  var blendMode: BlendMode
  if getSurfaceBlendMode(surface, addr blendMode):
    return blendMode
  else:
    echo getError()
    return BLENDMODE_NONE
proc `blendMode`*(surface: SurfacePtr): BlendMode =
  getBlendMode(surface)

proc setSurfaceClipRect*(surface: SurfacePtr, rect: ptr Rect = nil): bool {.importc: "SDL_SetSurfaceClipRect".}
proc setClipRect*(surface: SurfacePtr, rect: ptr Rect = nil): bool {.discardable.} =
  setSurfaceClipRect(surface, rect)
proc getSurfaceClipRect*(surface: SurfacePtr, rect: ptr Rect): bool {.importc: "SDL_GetSurfaceClipRect".}
proc getClipRect*(surface: SurfacePtr, rect: ptr Rect): bool {.discardable.} =
  getSurfaceClipRect(surface, rect)
proc getClipRect*(surface: SurfacePtr): ptr Rect =
  var rect: Rect
  if getSurfaceClipRect(surface, addr rect):
    return addr rect
  else:
    echo getError()
    return nil

proc flipSurface*(surface: SurfacePtr, flip: FlipMode): bool {.importc: "SDL_FlipSurface".}
proc flip*(surface: SurfacePtr, flip: FlipMode): bool {.discardable.} =
  flipSurface(surface, flip)
proc rotateSurface*(surface: SurfacePtr, angle: float32): SurfacePtr {.importc: "SDL_RotateSurface".}
proc rotate*(surface: SurfacePtr, angle: float32): SurfacePtr =
  rotateSurface(surface, angle)
proc duplicateSurface*(surface: SurfacePtr): SurfacePtr {.importc: "SDL_DuplicateSurface".}
proc duplicate*(surface: SurfacePtr): SurfacePtr =
  duplicateSurface(surface)
proc scaleSurface*(surface: SurfacePtr, width, height: cint, scaleMode: ScaleMode): SurfacePtr {.importc: "SDL_ScaleSurface".}
proc scale*(surface: SurfacePtr, width, height: cint, scaleMode: ScaleMode): SurfacePtr =
  scaleSurface(surface, width, height, scaleMode)

proc convertSurface*(surface: SurfacePtr, format: PixelFormat): SurfacePtr {.importc: "SDL_ConvertSurface".}
proc convert*(surface: SurfacePtr, format: PixelFormat): SurfacePtr =
  convertSurface(surface, format)
proc convertSurfaceAndColorspace*(surface: SurfacePtr, format: PixelFormat, palette: PalettePtr, colorspace: ColorSpace, props: PropertiesID): SurfacePtr {.importc: "SDL_ConvertSurfaceAndColorspace".}
proc convert*(surface: SurfacePtr, format: PixelFormat, palette: PalettePtr, colorspace: ColorSpace, props: PropertiesID): SurfacePtr =
  convertSurfaceAndColorspace(surface, format, palette, colorspace, props)
proc convertPixels*(width, height: cint, srcFormat: PixelFormat, src: pointer, srcPitch: cint, dstFormat: PixelFormat, dst: pointer, dstPitch: cint): bool {.importc: "SDL_ConvertPixels".}
proc convert*(width, height: cint, srcFormat: PixelFormat, src: pointer, srcPitch: cint, dstFormat: PixelFormat, dst: pointer, dstPitch: cint): bool =
  convertPixels(width, height, srcFormat, src, srcPitch, dstFormat, dst, dstPitch)
proc convertPixelsAndColorspace*(width, height: cint, srcFormat: PixelFormat, srcColorspace: ColorSpace, srcProps: PropertiesID, src: pointer, srcPitch: cint, dstFormat: PixelFormat, dstColorspace: ColorSpace, dstProps: PropertiesID, dst: pointer, dstPitch: cint): bool {.importc: "SDL_ConvertPixelsAndColorspace".}
proc convert*(width, height: cint, srcFormat: PixelFormat, srcColorspace: ColorSpace, srcProps: PropertiesID, src: pointer, srcPitch: cint, dstFormat: PixelFormat, dstColorspace: ColorSpace, dstProps: PropertiesID, dst: pointer, dstPitch: cint): bool =
  convertPixelsAndColorspace(width, height, srcFormat, srcColorspace, srcProps, src, srcPitch, dstFormat, dstColorspace, dstProps, dst, dstPitch)

proc premultiplyAlpha*(width, height: cint, srcFormat: PixelFormat, src: pointer, srcPitch: cint, dstFormat: PixelFormat, dst: pointer, dstPitch: cint, linear: bool): bool {.importc: "SDL_PremultiplyAlpha".}
proc premultiplySurfaceAlpha*(surface: SurfacePtr, linear: bool): bool {.importc: "SDL_PremultiplySurfaceAlpha".}
proc premultiplyAlpha*(surface: SurfacePtr, linear: bool): bool =
  premultiplySurfaceAlpha(surface, linear)

proc clearSurface*(surface: SurfacePtr, r, g, b, a: float32): bool {.importc: "SDL_ClearSurface".}
proc clear*(surface: SurfacePtr, r, g, b, a: float32): bool =
  clearSurface(surface, r, g, b, a)

proc fillSurfaceRect*(surface: SurfacePtr, rect: ptr Rect = nil, color: uint32): bool {.importc: "SDL_FillSurfaceRect".}
proc fillRect*(surface: SurfacePtr, rect: ptr Rect = nil, color: uint32): bool {.discardable.} =
  fillSurfaceRect(surface, rect, color)
proc fillSurfaceRects*(surface: SurfacePtr, rects: ptr UncheckedArray[Rect], count: cint, color: uint32): bool {.importc: "SDL_FillSurfaceRects".}
proc fillRects*(surface: SurfacePtr, rects: ptr UncheckedArray[Rect], count: cint, color: uint32): bool {.discardable.} =
  fillSurfaceRects(surface, rects, count, color)

proc blitSurface*(src: SurfacePtr, srcRect: ptr Rect = nil, dst: SurfacePtr, dstRect: ptr Rect = nil): bool {.importc: "SDL_BlitSurface".}
proc blit*(src: SurfacePtr, srcRect: ptr Rect = nil, dst: SurfacePtr, dstRect: ptr Rect = nil): bool {.discardable.} =
  blitSurface(src, srcRect, dst, dstRect)
proc blitSurfaceUnchecked*(src: SurfacePtr, srcRect: ptr Rect = nil, dst: SurfacePtr, dstRect: ptr Rect = nil): bool {.importc: "SDL_BlitSurfaceUnchecked".}
proc blitUnchecked*(src: SurfacePtr, srcRect: ptr Rect = nil, dst: SurfacePtr, dstRect: ptr Rect = nil): bool {.discardable.} =
  blitSurfaceUnchecked(src, srcRect, dst, dstRect)

proc blitSurfaceScaled*(src: SurfacePtr, srcRect: ptr Rect = nil, dst: SurfacePtr, dstRect: ptr Rect = nil, scaleMode: ScaleMode): bool {.importc: "SDL_BlitSurfaceScaled".}
proc blitScaled*(src: SurfacePtr, srcRect: ptr Rect = nil, dst: SurfacePtr, dstRect: ptr Rect = nil, scaleMode: ScaleMode): bool {.discardable.} =
  blitSurfaceScaled(src, srcRect, dst, dstRect, scaleMode)
proc blitSurfaceUncheckedScaled*(src: SurfacePtr, srcRect: ptr Rect = nil, dst: SurfacePtr, dstRect: ptr Rect = nil, scaleMode: ScaleMode): bool {.importc: "SDL_BlitSurfaceUncheckedScaled".}
proc blitUncheckedScaled*(src: SurfacePtr, srcRect: ptr Rect = nil, dst: SurfacePtr, dstRect: ptr Rect = nil, scaleMode: ScaleMode): bool {.discardable.} =
  blitSurfaceUncheckedScaled(src, srcRect, dst, dstRect, scaleMode)

proc blitSurfaceTiled*(src: SurfacePtr, srcRect: ptr Rect = nil, dst: SurfacePtr, dstRect: ptr Rect = nil): bool {.importc: "SDL_BlitSurfaceTiled".}
proc blitTiled*(src: SurfacePtr, srcRect: ptr Rect = nil, dst: SurfacePtr, dstRect: ptr Rect = nil): bool {.discardable.} =
  blitSurfaceTiled(src, srcRect, dst, dstRect)
proc blitSurfaceTiledWithScale*(src: SurfacePtr, srcRect: ptr Rect = nil, scale: float32, scaleMode: ScaleMode, dst: SurfacePtr, dstRect: ptr Rect = nil): bool {.importc: "SDL_BlitSurfaceTiledWithScale".}
proc blitTiledWithScale*(src: SurfacePtr, srcRect: ptr Rect = nil, scale: float32, scaleMode: ScaleMode, dst: SurfacePtr, dstRect: ptr Rect = nil): bool {.discardable.} =
  blitSurfaceTiledWithScale(src, srcRect, scale, scaleMode, dst, dstRect)
proc blitSurface9Grid*(src: SurfacePtr, srcRect: ptr Rect = nil, leftWidth, rightWidth, topHeight, bottomHeight: cint, scale: float32, scaleMode: ScaleMode, dst: SurfacePtr, dstRect: ptr Rect = nil): bool {.importc: "SDL_BlitSurface9Grid".}
proc blit9Grid*(src: SurfacePtr, srcRect: ptr Rect = nil, leftWidth, rightWidth, topHeight, bottomHeight: cint, scale: float32, scaleMode: ScaleMode, dst: SurfacePtr, dstRect: ptr Rect = nil): bool {.discardable.} =
  blitSurface9Grid(src, srcRect, leftWidth, rightWidth, topHeight, bottomHeight, scale, scaleMode, dst, dstRect)

proc stretchSurface*(src: SurfacePtr, srcRect: ptr Rect = nil, dst: SurfacePtr, dstRect: ptr Rect = nil, scaleMode: ScaleMode): bool {.importc: "SDL_StretchSurface".}
proc stretch*(src: SurfacePtr, srcRect: ptr Rect = nil, dst: SurfacePtr, dstRect: ptr Rect = nil, scaleMode: ScaleMode): bool {.discardable.} =
  stretchSurface(src, srcRect, dst, dstRect, scaleMode)

proc mapSurfaceRGB*(surface: SurfacePtr, r, g, b: uint8): uint32 {.importc: "SDL_MapSurfaceRGB".}
proc mapRGB*(surface: SurfacePtr, r, g, b: uint8): uint32 =
  mapSurfaceRGB(surface, r, g, b)

proc mapSurfaceRGBA*(surface: SurfacePtr, r, g, b, a: uint8): uint32 {.importc: "SDL_MapSurfaceRGBA".}
proc mapRGBA*(surface: SurfacePtr, r, g, b, a: uint8): uint32 =
  mapSurfaceRGBA(surface, r, g, b, a)

proc readSurfacePixel*(surface: SurfacePtr, x, y: cint, r, g, b, a: ptr uint8): bool {.importc: "SDL_ReadSurfacePixel".}
proc readPixel*(surface: SurfacePtr, x, y: cint, r, g, b, a: ptr uint8): bool {.discardable.} =
  readSurfacePixel(surface, x, y, r, g, b, a)
proc readPixel*(surface: SurfacePtr, x, y: cint): (uint8, uint8, uint8, uint8) =
  var r, g, b, a: uint8
  if readSurfacePixel(surface, x, y, addr r, addr g, addr b, addr a):
    return (r, g, b, a)
  else:
    echo getError()
    return (0, 0, 0, 0)

proc readSurfacePixelFloat*(surface: SurfacePtr, x, y: cint, r, g, b, a: ptr float32): bool {.importc: "SDL_ReadSurfacePixelFloat".}
proc readPixelFloat*(surface: SurfacePtr, x, y: cint, r, g, b, a: ptr float32): bool {.discardable.} =
  readSurfacePixelFloat(surface, x, y, r, g, b, a)
proc readPixelFloat*(surface: SurfacePtr, x, y: cint): (float32, float32, float32, float32) =
  var r, g, b, a: float32
  if readSurfacePixelFloat(surface, x, y, addr r, addr g, addr b, addr a):
    return (r, g, b, a)
  else:
    echo getError()
    return (0.0, 0.0, 0.0, 0.0)

proc writeSurfacePixel*(surface: SurfacePtr, x, y: cint, r, g, b, a: uint8): bool {.importc: "SDL_WriteSurfacePixel".}
proc writePixel*(surface: SurfacePtr, x, y: cint, r, g, b, a: uint8): bool {.discardable.} =
  writeSurfacePixel(surface, x, y, r, g, b, a)

proc writeSurfacePixelFloat*(surface: SurfacePtr, x, y: cint, r, g, b, a: float32): bool {.importc: "SDL_WriteSurfacePixelFloat".}
proc writePixelFloat*(surface: SurfacePtr, x, y: cint, r, g, b, a: float32): bool {.discardable.} =
  writeSurfacePixelFloat(surface, x, y, r, g, b, a)

## Section: SDL_video.h

type
  DisplayID* = distinct uint32
  WindowID* = distinct uint32
  SystemTheme* {.size: sizeof(cint).} = enum
    Unknown
    Light
    Dark
  DisplayOrientation* {.size: sizeof(cint).} = enum
    Unknown
    Landscape
    LandscapeFlipped
    Portrait
    PortraitFlipped
  FlashOperation* {.size: sizeof(cint).} = enum
    Cancel
    Briefly
    UntilFocused
  ProgressState* {.size: sizeof(cint).} = enum
    Invalid = -1
    None
    Indeterminate
    Normal
    Paused
    Error
  WindowFlag* {.size: sizeof(uint64).} = enum
    Fullscreen = 0
    OpenGL = 1
    Occluded = 2
    Hidden = 3
    Borderless = 4
    Resizable = 5
    Minimized = 6
    Maximized = 7
    MouseGrabbed = 8
    InputFocus = 9
    MouseFocus = 10
    External = 11
    Modal = 12
    HighPixelDensity = 13
    MouseCapture = 14
    MouseRelativeMode = 15
    AlwaysOnTop = 16
    Utility = 17
    Tooltip = 18
    PopupMenu = 19
    KeyboardGrabbed = 20
    FillDocument = 21

    Vulkan = 28
    Metal = 29
    Transparent = 30
    NotFocusable = 31
  WindowFlags* = distinct uint64

  ## GL
  EGLDisplay* = distinct pointer
  EGLConfig* = distinct pointer
  EGLSurface* = distinct pointer
  EGLAttrib* = distinct pointer
  EGLint* = distinct cint

  EGLAttribArrayCb* = proc(userdata: pointer): ptr EGLAttrib {.cdecl.}
  EGLintArrayCb* = proc(userdata: pointer, display: EGLDisplay, config: EGLConfig): ptr UncheckedArray[EGLint] {.cdecl.}

  GLAttr* {.size: sizeof(cint).} = enum
    RedSize
    GreenSize
    BlueSize
    AlphaSize
    BufferSize
    DoubleBuffer
    DepthSize
    StencilSize
    AccumRedSize
    AccumGreenSize
    AccumBlueSize
    AccumAlphaSize
    Stereo
    MultisampleBuffers
    MultisampleSamples
    AcceleratedVisual
    RetainedBacking
    ContextMajorVersion
    ContextMinorVersion
    ContextFlags
    ContextProfileMask
    ShareWithCurrentContext
    FramebufferSRGBCapable
    ContextReleaseBehavior
    ContextResetNotification
    ContextNoError
    FloatBuffers
    EGLPlatform
  GLProfileFlag* {.size: sizeof(uint32).} = enum
    Core = 0
    Compatibility = 1
    ES = 2
  GLProfileFlags* = distinct set[GLProfileFlag]
  GLContextFlag* {.size: sizeof(uint32).} = enum
    Debug = 0
    ForwardCompatible = 1
    RobustAccess = 2
    ResetIsolation = 3
  GLContextFlags* = distinct set[GLContextFlag]
  GLContextReleaseFlagBit* {.size: sizeof(uint32).} = enum
    Flush = 0
  GLContextReleaseFlags* = distinct set[GLContextReleaseFlagBit]
  GLContextResetNotificationFlag* {.size: sizeof(uint32).} = enum
    LoseContext = 0
  GLContextResetNotificationFlags* = distinct set[GLContextResetNotificationFlag]

  ## HitTest
  HitTestResult* {.size: sizeof(cint).} = enum
    Normal
    Draggable
    ResizeTopLeft
    ResizeTop
    ResizeTopRight
    ResizeRight
    ResizeBottomRight
    ResizeBottom
    ResizeBottomLeft
    ResizeLeft
  
  DisplayModeData* = pointer
  DisplayMode* {.bycopy.} = object
    displayID*: DisplayID
    format*: PixelFormat
    w*, h*: cint
    pixelDensity, refreshRate*: float32
    refreshRateNumerator, refreshRateDenominator*: cint

    internal: DisplayModeData
  
  WindowPtr* = pointer

proc flags*(e: varargs[WindowFlag]): WindowFlags {.inline.} =
  var res: uint64 = 0
  for val in items(e):
    res = res or (1'u64 shl uint64(val))
  WindowFlags(res)


proc getNumVideoDrivers*(): cint {.importc: "SDL_GetNumVideoDrivers".}
proc getVideoDriver*(index: cint): cstring {.importc: "SDL_GetVideoDriver".}
proc getCurrentVideoDriver*(): cstring {.importc: "SDL_GetCurrentVideoDriver".}
proc getSystemTheme*(): SystemTheme {.importc: "SDL_GetSystemTheme".}
proc getDisplays*(count: ptr cint): ptr UncheckedArray[ptr DisplayID] {.importc: "SDL_GetDisplays".}
proc getPrimaryDisplay*(): DisplayID {.importc: "SDL_GetPrimaryDisplay".}

proc getDisplayProperties*(displayID: DisplayID): PropertiesID {.importc: "SDL_GetDisplayProperties".}
proc getDisplayName*(displayID: DisplayID): cstring {.importc: "SDL_GetDisplayName".}
proc getDisplayBounds*(displayID: DisplayID, rect: ptr Rect): bool {.importc: "SDL_GetDisplayBounds".}
proc getDisplayUsableBounds*(displayID: DisplayID, rect: ptr Rect): bool {.importc: "SDL_GetDisplayUsableBounds".}
proc getNaturalDisplayOrientation*(displayID: DisplayID): DisplayOrientation {.importc: "SDL_GetNaturalDisplayOrientation".}
proc getCurrentDisplayOrientation*(displayID: DisplayID): DisplayOrientation {.importc: "SDL_GetCurrentDisplayOrientation".}
proc getDisplayContentScale*(displayID: DisplayID): float32 {.importc: "SDL_GetDisplayContentScale".}

proc getFullscreenDisplayModes*(displayID: DisplayID, count: ptr cint): ptr UncheckedArray[ptr DisplayMode] {.importc: "SDL_GetFullscreenDisplayModes".}
proc getFullscreenDisplayModes*(displayID: DisplayID): seq[ptr DisplayMode] =
  var count: cint
  var modes = getFullscreenDisplayModes(displayID, addr count)
  result = newSeqOfCap[ptr DisplayMode](count)
  for i in 0 ..< count:
    result.add(modes[i])

proc getClosestFullscreenDisplayMode*(displayID: DisplayID, width, height: cint, refreshRate: float32, includeHighDensityModes: bool, closest: ptr DisplayMode): bool {.importc: "SDL_GetClosestFullscreenDisplayMode".}
proc getDesktopDisplayMode*(displayID: DisplayID): ptr DisplayMode {.importc: "SDL_GetDesktopDisplayMode".}
proc getCurrentDisplayMode*(displayID: DisplayID): ptr DisplayMode {.importc: "SDL_GetCurrentDisplayMode".}

proc getDisplayForPoint*(point: ptr Point): DisplayID {.importc: "SDL_GetDisplayForPoint".}
proc getDisplayForRect*(rect: ptr Rect): DisplayID {.importc: "SDL_GetDisplayForRect".}
proc getDisplayForWindow*(window: WindowPtr): DisplayID {.importc: "SDL_GetDisplayForWindow".}

proc getWindowPixelDensity*(window: WindowPtr): float32 {.importc: "SDL_GetWindowPixelDensity".}
proc getWindowDisplayScale*(window: WindowPtr): float32 {.importc: "SDL_GetWindowDisplayScale".}

proc setWindowFullscreenMode*(window: WindowPtr, mode: ptr DisplayMode): bool {.importc: "SDL_SetWindowFullscreenMode".}
proc setFullscreenMode*(window: WindowPtr, mode: ptr DisplayMode): bool {.discardable.} =
  setWindowFullscreenMode(window, mode)
proc `fullscreenMode=`*(window: WindowPtr, mode: ptr DisplayMode): bool {.discardable.} =
  setWindowFullscreenMode(window, mode)

proc getWindowFullscreenMode*(window: WindowPtr): ptr DisplayMode {.importc: "SDL_GetWindowFullscreenMode".}

proc getWindowICCProfile*(window: WindowPtr, size: ptr uint): ptr {.importc: "SDL_GetWindowICCProfile".}
proc getWindowPixelFormat*(window: WindowPtr): PixelFormat {.importc: "SDL_GetWindowPixelFormat".}
proc getWindows*(count: ptr cint): ptr UncheckedArray[WindowPtr] {.importc: "SDL_GetWindows".}
proc getWindows*(): seq[WindowPtr] =
  var count: cint
  var windows = getWindows(addr count)
  result = newSeqOfCap[WindowPtr](count)
  for i in 0 ..< count:
    result.add(windows[i])

proc createWindow*(title: cstring, w, h: cint, flags: WindowFlags): WindowPtr {.importc: "SDL_CreateWindow".}
proc createPopupWindow*(parent: WindowPtr, offsetX, offsetY: cint, width, height: cint, flags: WindowFlags): WindowPtr {.importc: "SDL_CreatePopupWindow".}
proc createWindowWithProperties*(props: PropertiesID): WindowPtr {.importc: "SDL_CreateWindowWithProperties".}

proc getWindowID*(window: WindowPtr): WindowID {.importc: "SDL_GetWindowID".}
proc getWindowFromID*(id: WindowID): WindowPtr {.importc: "SDL_GetWindowFromID".}

proc getWindowParent*(window: WindowPtr): WindowPtr {.importc: "SDL_GetWindowParent".}
proc getWindowProperties*(window: WindowPtr): PropertiesID {.importc: "SDL_GetWindowProperties".}
proc getWindowFlags*(window: WindowPtr): WindowFlags {.importc: "SDL_GetWindowFlags".}

proc setWindowTitle*(window: WindowPtr, title: cstring): bool {.importc: "SDL_SetWindowTitle".}
proc setTitle*(window: WindowPtr, title: cstring): bool {.discardable.} =
  setWindowTitle(window, title)
proc `title=`*(window: WindowPtr, title: cstring): bool {.discardable.} =
  setWindowTitle(window, title)

proc getWindowTitle*(window: WindowPtr): cstring {.importc: "SDL_GetWindowTitle".}
proc getTitle*(window: WindowPtr): cstring {.discardable.} =
  getWindowTitle(window)
proc `title`*(window: WindowPtr): cstring {.discardable.} =
  getWindowTitle(window)

proc setWindowIcon*(window: WindowPtr, icon: SurfacePtr): bool {.importc: "SDL_SetWindowIcon".}
proc setIcon*(window: WindowPtr, icon: SurfacePtr): bool {.discardable.} =
  setWindowIcon(window, icon)
proc `icon=`*(window: WindowPtr, icon: SurfacePtr): bool {.discardable.} =
  setWindowIcon(window, icon)

proc setWindowPosition*(window: WindowPtr, x, y: cint): bool {.importc: "SDL_SetWindowPosition".}
proc setPosition*(window: WindowPtr, x, y: cint): bool {.discardable.} =
  setWindowPosition(window, x, y)

proc getWindowPosition*(window: WindowPtr, x, y: ptr cint): bool {.importc: "SDL_GetWindowPosition".}
proc getPosition*(window: WindowPtr, x, y: ptr cint): bool {.discardable.} =
  getWindowPosition(window, x, y)
proc getPosition*(window: WindowPtr): (cint, cint) =
  var x, y: cint
  if getWindowPosition(window, addr x, addr y):
    return (x, y)
  else:
    echo getError()
    return (0, 0)
proc `position`*(window: WindowPtr): (cint, cint) =
  getPosition(window)

proc setWindowSize*(window: WindowPtr, w, h: cint): bool {.importc: "SDL_SetWindowSize".}
proc setSize*(window: WindowPtr, w, h: cint): bool {.discardable.} =
  setWindowSize(window, w, h)

proc getWindowSize*(window: WindowPtr, w, h: ptr cint): bool {.importc: "SDL_GetWindowSize".}
proc getSize*(window: WindowPtr, w, h: ptr cint): bool {.discardable.} =
  getWindowSize(window, w, h)
proc getSize*(window: WindowPtr): (cint, cint) =
  var w, h: cint
  if getWindowSize(window, addr w, addr h):
    return (w, h)
  else:
    echo getError()
    return (0, 0)
proc `size`*(window: WindowPtr): (cint, cint) =
  getSize(window)

proc getWindowSafeArea*(window: WindowPtr, rect: ptr Rect): bool {.importc: "SDL_GetWindowSafeArea".}
proc getSafeArea*(window: WindowPtr, rect: ptr Rect): bool {.discardable.} =
  getWindowSafeArea(window, rect)
proc getSafeArea*(window: WindowPtr): Rect =
  var rect: Rect
  if getWindowSafeArea(window, addr rect):
    return rect
  else:
    echo getError()
    return Rect(x: 0, y: 0, w: 0, h: 0)

proc setWindowAspectRatio*(window: WindowPtr, minAspect, maxAspect: float32): bool {.importc: "SDL_SetWindowAspectRatio".}

proc getWindowAspectRatio*(window: WindowPtr, minAspect, maxAspect: ptr float32): bool {.importc: "SDL_GetWindowAspectRatio".}
proc getAspectRatio*(window: WindowPtr, minAspect, maxAspect: ptr float32): bool {.discardable.} =
  getWindowAspectRatio(window, minAspect, maxAspect)
proc getAspectRatio*(window: WindowPtr): (float32, float32) =
  var minAspect, maxAspect: float32
  if getWindowAspectRatio(window, addr minAspect, addr maxAspect):
    return (minAspect, maxAspect)
  else:
    echo getError()
    return (0.0, 0.0)

proc getWindowBordersSize*(window: WindowPtr, top, left, bottom, right: ptr cint): bool {.importc: "SDL_GetWindowBordersSize".}
proc getBordersSize*(window: WindowPtr, top, left, bottom, right: ptr cint): bool {.discardable.} =
  getWindowBordersSize(window, top, left, bottom, right)
proc getBordersSize*(window: WindowPtr): (cint, cint, cint, cint) =
  var top, left, bottom, right: cint
  if getWindowBordersSize(window, addr top, addr left, addr bottom, addr right):
    return (top, left, bottom, right)
  else:
    echo getError()
    return (0, 0, 0, 0)

proc getWindowSizeInPixels*(window: WindowPtr, width, height: ptr cint): bool {.importc: "SDL_GetWindowSizeInPixels".}
proc getSizeInPixels*(window: WindowPtr, width, height: ptr cint): bool {.discardable.} =
  getWindowSizeInPixels(window, width, height)
proc getSizeInPixels*(window: WindowPtr): (cint, cint) =
  var width, height: cint
  if getWindowSizeInPixels(window, addr width, addr height):
    return (width, height)
  else:
    echo getError()
    return (0, 0)

proc setWindowMinimumSize*(window: WindowPtr, minW, minH: cint): bool {.importc: "SDL_SetWindowMinimumSize".}
proc setMinimumSize*(window: WindowPtr, minW, minH: cint): bool {.discardable.} =
  setWindowMinimumSize(window, minW, minH)

proc getWindowMinimumSize*(window: WindowPtr, minW, minH: ptr cint): bool {.importc: "SDL_GetWindowMinimumSize".}
proc getMinimumSize*(window: WindowPtr, minW, minH: ptr cint): bool {.discardable.} =
  getWindowMinimumSize(window, minW, minH)
proc getMinimumSize*(window: WindowPtr): (cint, cint) =
  var minW, minH: cint
  if getWindowMinimumSize(window, addr minW, addr minH):
    return (minW, minH)
  else:
    echo getError()
    return (0, 0)

proc getWindowMaximumSize*(window: WindowPtr, maxW, maxH: ptr cint): bool {.importc: "SDL_GetWindowMaximumSize".}
proc getMaximumSize*(window: WindowPtr, maxW, maxH: ptr cint): bool {.discardable.} =
  getWindowMaximumSize(window, maxW, maxH)
proc getMaximumSize*(window: WindowPtr): (cint, cint) =
  var maxW, maxH: cint
  if getWindowMaximumSize(window, addr maxW, addr maxH):
    return (maxW, maxH)
  else:
    echo getError()
    return (0, 0)

proc setWindowMaximumSize*(window: WindowPtr, maxW, maxH: cint): bool {.importc: "SDL_SetWindowMaximumSize".}
proc setMaximumSize*(window: WindowPtr, maxW, maxH: cint): bool {.discardable.} =
  setWindowMaximumSize(window, maxW, maxH)

proc setWindowBordered*(window: WindowPtr, bordered: bool): bool {.importc: "SDL_SetWindowBordered".}
proc setBordered*(window: WindowPtr, bordered: bool): bool {.discardable.} =
  setWindowBordered(window, bordered)
proc `bordered=`*(window: WindowPtr, bordered: bool): bool {.discardable.} =
  setWindowBordered(window, bordered)

proc setWindowResizable*(window: WindowPtr, resizable: bool): bool {.importc: "SDL_SetWindowResizable".}
proc setResizable*(window: WindowPtr, resizable: bool): bool {.discardable.} =
  setWindowResizable(window, resizable)
proc `resizable=`*(window: WindowPtr, resizable: bool): bool {.discardable.} =
  setWindowResizable(window, resizable)

proc setWindowAlwaysOnTop*(window: WindowPtr, onTop: bool): bool {.importc: "SDL_SetWindowAlwaysOnTop".}
proc setAlwaysOnTop*(window: WindowPtr, onTop: bool): bool {.discardable.} =
  setWindowAlwaysOnTop(window, onTop)
proc `alwaysOnTop=`*(window: WindowPtr, onTop: bool): bool {.discardable.} =
  setWindowAlwaysOnTop(window, onTop)

proc setWindowFillDocument*(window: WindowPtr, fill: bool): bool {.importc: "SDL_SetWindowFillDocument".}
proc setFillDocument*(window: WindowPtr, fill: bool): bool {.discardable.} =
  setWindowFillDocument(window, fill)
proc `fillDocument=`*(window: WindowPtr, fill: bool): bool {.discardable.} =
  setWindowFillDocument(window, fill)

proc showWindow*(window: WindowPtr): bool {.importc: "SDL_ShowWindow".}
proc show*(window: WindowPtr): bool {.discardable.} =
  showWindow(window)
proc hideWindow*(window: WindowPtr): bool {.importc: "SDL_HideWindow".}
proc hide*(window: WindowPtr): bool {.discardable.} =
  hideWindow(window)
proc raiseWindow*(window: WindowPtr): bool {.importc: "SDL_RaiseWindow".}
proc maximizeWindow*(window: WindowPtr): bool {.importc: "SDL_MaximizeWindow".}
proc maximize*(window: WindowPtr): bool {.discardable.} =
  maximizeWindow(window)
proc minimizeWindow*(window: WindowPtr): bool {.importc: "SDL_MinimizeWindow".}
proc minimize*(window: WindowPtr): bool {.discardable.} =
  minimizeWindow(window)
proc restoreWindow*(window: WindowPtr): bool {.importc: "SDL_RestoreWindow".}
proc restore*(window: WindowPtr): bool {.discardable.} =
  restoreWindow(window)
proc setWindowFullscreen*(window: WindowPtr, fullscreen: bool): bool {.importc: "SDL_SetWindowFullscreen".}
proc setFullscreen*(window: WindowPtr, fullscreen: bool): bool {.discardable.} =
  setWindowFullscreen(window, fullscreen)
proc `fullscreen=`*(window: WindowPtr, fullscreen: bool): bool {.discardable.} =
  setWindowFullscreen(window, fullscreen)

proc syncWindow*(window: WindowPtr): bool {.importc: "SDL_SyncWindow".}
proc sync*(window: WindowPtr): bool {.discardable.} =
  syncWindow(window)

proc windowHasSurface*(window: WindowPtr): bool {.importc: "SDL_WindowHasSurface".}
proc hasSurface*(window: WindowPtr): bool {.discardable.} =
  windowHasSurface(window)
proc getWindowSurface*(window: WindowPtr): SurfacePtr {.importc: "SDL_GetWindowSurface".}
proc getSurface*(window: WindowPtr): SurfacePtr {.discardable.} =
  getWindowSurface(window)
proc `surface`*(window: WindowPtr): SurfacePtr {.discardable.} =
  getWindowSurface(window)

proc setWindowSurfaceVSync*(window: WindowPtr, vsync: cint): bool {.importc: "SDL_SetWindowSurfaceVSync".}
proc setSurfaceVSync*(window: WindowPtr, vsync: cint): bool {.discardable.} =
  setWindowSurfaceVSync(window, vsync)
proc getWindowSurfaceVSync*(window: WindowPtr, vsync: ptr cint): bool {.importc: "SDL_GetWindowSurfaceVSync".}
proc getSurfaceVSync*(window: WindowPtr, vsync: ptr cint): bool {.discardable.} =
  getWindowSurfaceVSync(window, vsync)
proc getSurfaceVSync*(window: WindowPtr): cint =
  var vsync: cint
  if getWindowSurfaceVSync(window, addr vsync):
    return vsync
  else:
    echo getError()
    return 0

proc updateWindowSurface*(window: WindowPtr): bool {.importc: "SDL_UpdateWindowSurface".}
proc updateSurface*(window: WindowPtr): bool {.discardable.} =
  updateWindowSurface(window)
proc updateWindowSurfaceRects*(window: WindowPtr, rects: ptr UncheckedArray[Rect], numRects: cint): bool {.importc: "SDL_UpdateWindowSurfaceRects".}
proc updateSurfaceRects*(window: WindowPtr, rects: ptr UncheckedArray[Rect], numRects: cint): bool {.discardable.} =
  updateWindowSurfaceRects(window, rects, numRects)
proc updateSurfaceRects*(window: WindowPtr, rects: seq[Rect]): bool {.discardable.} =
  result = false
  var rectsArray: ptr UncheckedArray[Rect] = nil
  if rects.len > 0:
    ## aaaaaaaaaaaaaaaaaaaaaaaaaaaaa
    rectsArray = cast[ptr UncheckedArray[Rect]](realloc(rectsArray, Rect.sizeof * rects.len))
    for i in 0 ..< rects.len:
      rectsArray[i] = rects[i]
    result = updateWindowSurfaceRects(window, rectsArray, rects.len.cint)
    defer:
      rectsArray = cast[ptr UncheckedArray[Rect]](realloc(rectsArray, 0))

proc destroyWindowSurface*(window: WindowPtr): bool {.importc: "SDL_DestroyWindowSurface".}
proc destroySurface*(window: WindowPtr): bool {.discardable.} =
  destroyWindowSurface(window)

proc setWindowKeyboardGrab*(window: WindowPtr, grabbed: bool): bool {.importc: "SDL_SetWindowKeyboardGrab".}
proc setKeyboardGrab*(window: WindowPtr, grabbed: bool): bool {.discardable.} =
  setWindowKeyboardGrab(window, grabbed)
proc `keyboardGrab=`*(window: WindowPtr, grabbed: bool): bool {.discardable.} =
  setWindowKeyboardGrab(window, grabbed)

proc getWindowKeyboardGrab*(window: WindowPtr): bool {.importc: "SDL_GetWindowKeyboardGrab".}
proc getKeyboardGrab*(window: WindowPtr): bool {.discardable.} =
  getWindowKeyboardGrab(window)
proc `keyboardGrab`*(window: WindowPtr): bool {.discardable.} =
  getWindowKeyboardGrab(window)

proc setWindowMouseGrab*(window: WindowPtr, grabbed: bool): bool {.importc: "SDL_SetWindowMouseGrab".}
proc setMouseGrab*(window: WindowPtr, grabbed: bool): bool {.discardable.} =
  setWindowMouseGrab(window, grabbed)
proc `mouseGrab=`*(window: WindowPtr, grabbed: bool): bool {.discardable.} =
  setWindowMouseGrab(window, grabbed)

proc getWindowMouseGrab*(window: WindowPtr): bool {.importc: "SDL_GetWindowMouseGrab".}
proc getMouseGrab*(window: WindowPtr): bool {.discardable.} =
  getWindowMouseGrab(window)
proc `mouseGrab`*(window: WindowPtr): bool {.discardable.} =
  getWindowMouseGrab(window)

proc getGrabbedWindow*(): WindowPtr {.importc: "SDL_GetGrabbedWindow".}

proc setWindowMouseRect*(window: WindowPtr, rect: ptr Rect): bool {.importc: "SDL_SetWindowMouseRect".}
proc setMouseRect*(window: WindowPtr, rect: ptr Rect): bool {.discardable.} =
  setWindowMouseRect(window, rect)
proc setMouseRect*(window: WindowPtr, rect: Rect): bool {.discardable.} =
  setWindowMouseRect(window, addr rect)
proc getWindowMouseRect*(window: WindowPtr): ptr Rect {.importc: "SDL_GetWindowMouseRect".}
proc getMouseRect*(window: WindowPtr): ptr Rect {.discardable.} =
  getWindowMouseRect(window)

proc setWindowOpacity*(window: WindowPtr, opacity: float32): bool {.importc: "SDL_SetWindowOpacity".}
proc setOpacity*(window: WindowPtr, opacity: float32): bool {.discardable.} =
  setWindowOpacity(window, opacity)
proc `opacity=`*(window: WindowPtr, opacity: float32): bool {.discardable.} =
  setWindowOpacity(window, opacity)

proc getWindowOpacity*(window: WindowPtr): float32 {.importc: "SDL_GetWindowOpacity".}
proc getOpacity*(window: WindowPtr): float32 {.discardable.} =
  getWindowOpacity(window)
proc `opacity`*(window: WindowPtr): float32 {.discardable.} =
  getWindowOpacity(window)

proc setWindowParent*(window: WindowPtr, parent: WindowPtr): bool {.importc: "SDL_SetWindowParent".}
proc setParent*(window: WindowPtr, parent: WindowPtr): bool {.discardable.} =
  setWindowParent(window, parent)
proc `parent=`*(window: WindowPtr, parent: WindowPtr): bool {.discardable.} =
  setWindowParent(window, parent)

proc setWindowModal*(window: WindowPtr, modal: bool): bool {.importc: "SDL_SetWindowModal".}
proc setModal*(window: WindowPtr, modal: bool): bool {.discardable.} =
  setWindowModal(window, modal)
proc `modal=`*(window: WindowPtr, modal: bool): bool {.discardable.} =
  setWindowModal(window, modal)

proc setWindowFocusable*(window: WindowPtr, focusable: bool): bool {.importc: "SDL_SetWindowFocusable".}
proc setFocusable*(window: WindowPtr, focusable: bool): bool {.discardable.} =
  setWindowFocusable(window, focusable)
proc `focusable=`*(window: WindowPtr, focusable: bool): bool {.discardable.} =
  setWindowFocusable(window, focusable)

proc showWindowSystemMenu*(window: WindowPtr, x, y: cint): bool {.importc: "SDL_ShowWindowSystemMenu".}
proc showSystemMenu*(window: WindowPtr, x, y: cint): bool {.discardable.} =
  showWindowSystemMenu(window, x, y)

## Section: SDL_gpu.h


## Section: SDL_guid.h


## Section: SDL_hidapi.h


## Section: SDL_hints.h


## Section: SDL_sensor.h


## Section: SDL_joystick.h


## Section: SDL_haptic.h


## Section: SDL_gamepad.h


## Section: SDL_scancode.h


## Section: SDL_keycode.h


## Section: SDL_keyboard.h


## Section: SDL_loadso.h


## Section: SDL_locale.h


## Section: SDL_log.h


## Section: SDL_messagebox.h


## Section: SDL_metal.h


## Section: SDL_vulkan.h


## Section: SDL_misc.h


## Section: SDL_mouse.h


## Section: SDL_mutex.h


## Section: SDL_pen.h


## Section: SDL_platform.h


## Section: SDL_process.h


## Section: SDL_storage.h


## Section: SDL_system.h


## Section: SDL_thread.h


## Section: SDL_time.h


## Section: SDL_timer.h


## Section: SDL_tray.h


## Section: SDL_touch.h


## Section: SDL_dialog.h

type
  FileDialogType* {.size: sizeof(cint).} = enum
    OpenFile
    SaveFile
    OpenFolder
  
  DialogFileCallback* = proc(userdata: ptr, filelist: UncheckedArray[cstring], filter: cint) {.cdecl.}

  DialogFileFilter* {.bycopy.} = object
    name*: cstring
    pattern*: cstring

const
  PROP_FILE_DIALOG_FILTERS_POINTER* = "SDL.filedialog.filters"
  PROP_FILE_DIALOG_NFILTERS_NUMBER* = "SDL.filedialog.nfilters"
  PROP_FILE_DIALOG_WINDOW_POINTER*  = "SDL.filedialog.window"
  PROP_FILE_DIALOG_LOCATION_STRING* = "SDL.filedialog.location"
  PROP_FILE_DIALOG_MANY_BOOLEAN*    = "SDL.filedialog.many"
  PROP_FILE_DIALOG_TITLE_STRING*    = "SDL.filedialog.title"
  PROP_FILE_DIALOG_ACCEPT_STRING*   = "SDL.filedialog.accept"
  PROP_FILE_DIALOG_CANCEL_STRING*   = "SDL.filedialog.cancel"

proc showOpenFileDialog*(callback: DialogFileCallback, userdata: ptr, window: WindowPtr, filters: ptr UncheckedArray[DialogFileFilter], nfilters: cint, defaultLocation: cstring, allowMany: bool): bool {.importc: "SDL_ShowOpenFileDialog".}
proc showSaveFileDialog*(callback: DialogFileCallback, userdata: ptr, window: WindowPtr, filters: ptr UncheckedArray[DialogFileFilter], nfilters: cint, defaultLocation: cstring, allowMany: bool): bool {.importc: "SDL_ShowSaveFileDialog".}
proc showOpenFolderDialog*(callback: DialogFileCallback, userdata: ptr, window: WindowPtr, defaultLocation: cstring, allowMany: bool): bool {.importc: "SDL_ShowOpenFolderDialog".}
proc showFileDialogWithProperties*(dialogType: FileDialogType, callback: DialogFileCallback, userdata: ptr, props: PropertiesID): bool {.importc: "SDL_ShowFileDialogWithProperties".}


## Section: SDL_camera.h

type
  CameraID* = distinct uint32

  CameraPosition* {.size: sizeof(cint).} = enum
    Unknown,
    FrontFacing,
    BackFacing

  CameraPtr* = ptr object
  CameraSpec* {.bycopy.} = object
    format: PixelFormat
    colorspace: Colorspace
    width, height: cint
    framerateNumerator, framerateDenominator: cint
  CameraSpecPtr* = ptr CameraSpec

proc getNumCameraDrivers*(): cint {.importc: "SDL_GetNumCameraDrivers".}
proc getCameraDriver*(index: cint): cstring {.importc: "SDL_GetCameraDriver".}
proc getCurrentCameraDriver*(): cstring {.importc: "SDL_GetCurrentCameraDriver".}

proc getCameras*(count: ptr cint): ptr UncheckedArray[CameraID] {.importc: "SDL_GetCameras".}
proc getCameras*(): seq[CameraID] =
  var count: cint
  var cameras = getCameras(addr count)
  result = newSeqOfCap[CameraID](count)
  for i in 0 ..< count:
    result.add(cameras[i])

proc getCameraSupportedFormats*(instanceID: CameraID, count: ptr cint): ptr UncheckedArray[CameraSpecPtr] {.importc: "SDL_GetCameraSupportedFormats".}
proc getCameraSupportedFormats*(instanceID: CameraID): seq[CameraSpecPtr] =
  var count: cint
  var formats = getCameraSupportedFormats(instanceID, addr count)
  result = newSeqOfCap[CameraSpecPtr](count)
  for i in 0 ..< count:
    result.add(formats[i])
  
proc getCameraName*(instanceID: CameraID): cstring {.importc: "SDL_GetCameraName".}
proc getCameraPosition*(instanceID: CameraID): CameraPosition {.importc: "SDL_GetCameraPosition".}

proc openCamera*(instanceID: CameraID, spec: CameraSpecPtr): CameraPtr {.importc: "SDL_OpenCamera".}
proc closeCamera*(camera: CameraPtr): void {.importc: "SDL_CloseCamera".}
proc close*(camera: CameraPtr): void {.discardable.} =
  closeCamera(camera)

proc getCameraPermissionState*(camera: CameraPtr): cint {.importc: "SDL_GetCameraPermissionState".}
proc getCameraID*(camera: CameraPtr): CameraID {.importc: "SDL_GetCameraID".}
proc getCameraProperties*(camera: CameraPtr): PropertiesID {.importc: "SDL_GetCameraProperties".}
proc getCameraFormat*(camera: CameraPtr, spec: CameraSpecPtr): bool {.importc: "SDL_GetCameraFormat".}

proc acquireCameraFrame*(camera: CameraPtr, timestampNS: ptr uint64): SurfacePtr {.importc: "SDL_AcquireCameraFrame".}
proc acquireCameraFrame*(camera: CameraPtr): (SurfacePtr, uint64) =
  var timestampNS: uint64
  var frame = acquireCameraFrame(camera, addr timestampNS)
  if frame.isNil:
    echo getError()
    result = (nil, 0)
  else:
    result = (frame, timestampNS)
proc acquireFrame*(camera: CameraPtr, timestampNS: ptr uint64): SurfacePtr {.discardable.} =
  acquireCameraFrame(camera, timestampNS)
proc acquireFrame*(camera: CameraPtr): (SurfacePtr, uint64) {.discardable.} =
  acquireCameraFrame(camera)

proc releaseCameraFrame*(camera: CameraPtr, frame: SurfacePtr): void {.importc: "SDL_ReleaseCameraFrame".}
proc releaseFrame*(camera: CameraPtr, frame: SurfacePtr): void {.discardable.} =
  releaseCameraFrame(camera, frame)

## Section: SDL_events.h

type
  EventType* {.size: sizeof(cint).} = enum
    FirstUnused = 0,
    ## App Events
    Quit = 256,
    ## Special App Events
    Terminating,
    LowMemory,

    WillEnterBackground,
    DidEnterBackground,

    WillEnterForeground,
    DidEnterForeground,

    LocaleChanged, 
    SystemThemeChanged,

    ## Display Events
    DisplayOrientationChanged = 337,
    DisplayAdded,
    DisplayRemoved,
    DisplayMoved,
    DisplayDesktopModeChanged,
    DisplayCurrentModeChanged,
    DisplayContentScaleChanged,
    DisplayUsableBoundsChanged,
    # DisplayFirst = 337
    # DisplayLast = 344

    ## Window Events
    WindowShown = 514,
    WindowHidden,
    WindowExposed,
    WindowMoved,
    WindowResized,
    PixelSizeChanged,
    MetalViewResized,
    Minimized,
    Maximized,
    Restored,
    MouseEnter,
    MouseLeave,
    FocusGained,
    FocusLost,
    CloseRequested,
    HitTest,
    ICCProfileChanged,
    DisplayChanged,
    DisplayScaleChanged,
    SafeAreaChanged,
    Occluded,
    EnterFullscreen,
    LeaveFullscreen,
    Destroyed
    HDRStateChanged,
    # WindowFirst = 514
    # WindowLast = 538

    ## Keyboard Events
    KeyDown = 768,
    KeyUp,
    TextEditing,
    TextInput,
    KeymapChanged,
    KeyboardAdded,
    KeyboardRemoved,
    TextEditingCandidates,
    ScreenKeyboardShown,
    ScreenKeyboardHidden,

    ## Mouse Events
    MouseMotion = 1024,
    MouseButtonDown,
    MouseButtonUp,
    MouseWheel,
    MouseAdded,
    MouseRemoved

    ## Joystick Events
    JoystickAxisMotion = 1536,
    JoystickBallMotion,
    JoystickHatMotion,
    JoystickButtonDown,
    JoystickButtonUp,
    JoystickAdded,
    JoystickRemoved,
    JoystickBatteryUpdated,
    JoystickUpdateComplete,

    ## Gamepad Events
    GamepadAxisMotion = 1616,
    GamepadButtonDown,
    GamepadButtonUp,
    GamepadAdded,
    GamepadRemoved,
    GamepadRemapped,
    GamepadTouchpadDown,
    GamepadTouchpadMotion,
    GamepadTouchpadUp,
    GamepadSensorUpdate,
    GamepadUpdateComplete,
    GamepadSteamHandleUpdated,

    ## Touch Events
    FingerDown = 1792,
    FingerUp,
    FingerMotion,
    FingerCancelled,

    ## Pinch Events
    PinchBegin = 1808,
    PinchUpdate,
    PinchEnd,

    ## Clipboard Events
    ClipboardUpdate = 2304,

    ## Drag and Drop Events
    DropFile = 4096,
    DropText,
    DropBegin,
    DropComplete,
    DropPosition

    ## Audio hotplug Events
    AudioDeviceAdded = 4352,
    AudioDeviceRemoved,
    AudioDeviceFormatChanged,

    ## Sensor Events
    SensorUpdate = 4608,

    ## Pressuresensitive pen Events
    PenProximityIn = 4864,
    PenProximityOut,
    PenDown,
    PenUp,
    PenButtonDown,
    PenButtonUp,
    PenMotion,
    PenAxis

    ## Camera hotplug Events
    CameraDeviceAdded = 5120,
    CameraDeviceRemoved,
    CameraDeviceApproved,
    CameraDeviceDenied,

    ## Render Events
    RenderTargetsReset = 8192,
    RenderDeviceReset,
    RenderDeviceLost,

    ## Reserved / Internal Events 
    Private0 = 16384,
    Private1,
    Private2,
    Private3,
    PollSentinel = 32512,

    ## User Events
    User = 32768,
    #...
    Last = 65535
  
  CommonEvent* {.bycopy.} = object
    pad: uint32
    timestamp*: uint64
  ## Grahh, this union will look terrible or just be weird
  ## since we cant do case matching after we define more fields
  ## unless I make a template or something,...

  Event* {.bycopy.} = object
    eventType*: EventType
    padding: array[124, uint8]
  EventPtr* = ptr Event
  

proc pollEvent*(event: EventPtr): bool {.importc: "SDL_PollEvent", discardable.}
proc pollEvent*(event: var Event): bool {.inline, discardable.} =
  pollEvent(addr event)

#[

	PumpEvents          :: proc() ---
	PeepEvents          :: proc(events: [^]Event, numevents: c.int, action: EventAction, minType, maxType: EventType) -> int ---
	HasEvent            :: proc(type: EventType) -> bool ---
	HasEvents           :: proc(minType, maxType: EventType) -> bool ---
	FlushEvent          :: proc(type: EventType) ---
	FlushEvents         :: proc(minType, maxType: EventType) ---
	WaitEvent           :: proc(event: ^Event) -> bool ---
	WaitEventTimeout    :: proc(event: ^Event, timeoutMS: Sint32) -> bool ---
	PushEvent           :: proc(event: ^Event) -> bool ---
	SetEventFilter      :: proc(filter: EventFilter, userdata: rawptr) ---
	GetEventFilter      :: proc(filter: ^EventFilter, userdata: ^rawptr) -> bool ---
	AddEventWatch       :: proc(filter: EventFilter, userdata: rawptr) -> bool ---
	RemoveEventWatch    :: proc(filter: EventFilter, userdata: rawptr) ---
	FilterEvents        :: proc(filter: EventFilter, userdata: rawptr) ---
	SetEventEnabled     :: proc(type: EventType, enabled: bool) ---
	EventEnabled        :: proc(type: EventType) -> bool ---
	RegisterEvents      :: proc(numevents: c.int) -> Uint32 ---
	GetWindowFromEvent  :: proc(#by_ptr event: Event) -> ^Window ---
	GetEventDescription :: proc(#by_ptr event: Event, buf: [^]u8, buflen: c.int) -> c.int ---

]#

## Section: SDL_render.h

type
  TextureAccess* {.size: sizeof(cint).} = enum
    Static,
    Streaming,
    Target
  TextureAddressMode* {.size: sizeof(cint).} = enum
    Invalid = -1,
    Auto,
    Clamp,
    Wrap
  RendererLogicalPresentation* {.size: sizeof(cint).} = enum
    Disabled,
    Stretch,
    LetterBox,
    Overscan,
    IntegerScale

## Section: SDL_init.h

type
  InitFlag* {.size: sizeof(uint32).} = enum
    Audio = 4
    Video = 5
    Joystick = 9
    Haptic = 12
    Gamepad = 13
    Events = 14
    Sensor = 15
    Camera = 16
  InitFlags* = distinct uint32

  AppResult* {.size: sizeof(cint).} = enum
    Continue
    Success
    Failure
  AppInitFn* = stub
  AppIterateFn* = stub
  AppEventFn* = stub
  AppQuitFn* = stub
  MainThreadCallback* = stub

## thanks Naylib!
proc flags*(e: varargs[InitFlag]): InitFlags {.inline.} =
  var res: uint32 = 0
  for val in items(e):
    res = res or (1'u32 shl uint32(val))
  InitFlags(res)

proc init*(flags: InitFlags): bool {.importc: "SDL_Init".}
proc initSubSystem*(flags: InitFlags): bool {.importc: "SDL_InitSubSystem".}
proc quitSubSystem*(flags: InitFlags): void {.importc: "SDL_QuitSubSystem".}
proc quit*(): void {.importc: "SDL_Quit".}
proc wasInit*(flags: InitFlags): InitFlags {.importc: "SDL_WasInit".}

proc isMainThread*(): bool {.importc: "SDL_IsMainThread".}
proc runOnMainThread*(callback: MainThreadCallback, userdata: pointer, waitComplete: bool): bool {.importc: "SDL_RunOnMainThread".}

proc setAppMetadata*(appName, appVersion, appIdentifier: cstring): bool {.importc: "SDL_SetAppMetadata".}
proc setAppMetadataProperty*(property: cstring, value: cstring): bool {.importc: "SDL_SetAppMetadataProperty".}
proc getAppMetadataProperty*(property: cstring): cstring {.importc: "SDL_GetAppMetadataProperty".}

{.pop.}