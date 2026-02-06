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

proc loadWavIO*(src: IOStreamPtr, closeIo: bool, spec: AudioSpecPtr, audioBuf: ptr ptr uint8, audioLen: ptr uint32): bool {.importc: "SDL_LoadWAV_IO".}
proc loadWav*(src: IOStreamPtr, spec: AudioSpecPtr, closeIo: bool, audioBuf: ptr ptr uint8, audioLen: ptr uint32): bool =
  loadWavIO(src, closeIo, spec, audioBuf, audioLen)
proc loadWav*(path: cstring, spec: AudioSpecPtr, audioBuf: ptr ptr uint8, audioLen: ptr uint32): bool {.importc: "SDL_LoadWAV".}
proc mixAudio*(dst, src: ptr uint8, format: AudioFormat, len: uint32, volume: float32): bool {.importc: "SDL_MixAudio".}
proc convertAudioSamples*(srcSpec: AudioSpecPtr, srcData: ptr uint8, srcLen: cint, dstSpec: AudioSpecPtr, dstData: ptr ptr uint8, dstLen: ptr cint): bool {.importc: "SDL_ConvertAudioSamples".}

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
proc getClipboardMimeTypes*(numMimeTypes: ptr uint): ptr ptr uint8 {.importc: "SDL_GetClipboardMimeTypes".}

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
proc copyFile*(srdPath, dstPath: cstring): bool {.importc: "SDL_CopyFile".}
proc getPathInfo*(path: cstring, info: ptr PathInfo): bool {.importc: "SDL_GetPathInfo".}
proc getPathInfo*(path: cstring): PathInfo =
  var info: PathInfo
  if getPathInfo(path, addr info):
    return info
  else:
    echo getError()
    return PathInfo(type: PathType.None)
proc globDirectory*(path, pattern: cstring, flags: GlobFlag, count: ptr cint): ptr ptr uint8 {.importc: "SDL_GlobDirectory".}

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

#[ 
	SetSurfaceBlendMode          :: proc(surface: ^Surface, blendMode: BlendMode) -> bool ---
	GetSurfaceBlendMode          :: proc(surface: ^Surface, blendMode: ^BlendMode) -> bool ---
	SetSurfaceClipRect           :: proc(surface: ^Surface, rect: Maybe(^Rect)) -> bool ---
	GetSurfaceClipRect           :: proc(surface: ^Surface, rect: ^Rect) -> bool ---
	FlipSurface                  :: proc(surface: ^Surface, flip: FlipMode) -> bool ---
	RotateSurface                :: proc(surface: ^Surface, angle: f32) -> ^Surface ---
	DuplicateSurface             :: proc(surface: ^Surface) -> ^Surface ---
	ScaleSurface                 :: proc(surface: ^Surface, width, height: c.int, scaleMode: ScaleMode) -> ^Surface ---
	ConvertSurface               :: proc(surface: ^Surface, format: PixelFormat) -> ^Surface ---
	ConvertSurfaceAndColorspace  :: proc(surface: ^Surface, format: PixelFormat, palette: ^Palette, colorspace: Colorspace, props: PropertiesID) -> ^Surface ---
	ConvertPixels                :: proc(width, height: c.int, src_format: PixelFormat, src: rawptr, src_pitch: c.int, dst_format: PixelFormat, dst: rawptr, dst_pitch: c.int) -> bool ---
	ConvertPixelsAndColorspace   :: proc(width, height: c.int, src_format: PixelFormat, src_colorspace: Colorspace, src_properties: PropertiesID, src: rawptr, src_pitch: c.int, dst_format: PixelFormat, dst_colorspace: Colorspace, dst_properties: PropertiesID, dst: rawptr, dst_pitch: c.int) -> bool ---
	PremultiplyAlpha             :: proc(width, height: c.int, src_format: PixelFormat, src: rawptr, src_pitch: c.int, dst_format: PixelFormat, dst: rawptr, dst_pitch: c.int, linear: bool) -> bool ---
	PremultiplySurfaceAlpha      :: proc(surface: ^Surface, linear: bool) -> bool ---
	ClearSurface                 :: proc(surface: ^Surface, r, g, b, a: f32) -> bool ---
	FillSurfaceRect              :: proc(dst: ^Surface, rect: Maybe(^Rect), color: Uint32) -> bool ---
	FillSurfaceRects             :: proc(dst: ^Surface, rects: [^]Rect, count: c.int, color: Uint32) -> bool ---
	BlitSurface                  :: proc(src: ^Surface, srcrect: Maybe(^Rect), dst: ^Surface, dstrect: Maybe(^Rect)) -> bool ---
	BlitSurfaceUnchecked         :: proc(src: ^Surface, srcrect: Maybe(^Rect), dst: ^Surface, dstrect: Maybe(^Rect)) -> bool ---
	BlitSurfaceScaled            :: proc(src: ^Surface, srcrect: Maybe(^Rect), dst: ^Surface, dstrect: Maybe(^Rect), scaleMode: ScaleMode) -> bool ---
	BlitSurfaceUncheckedScaled   :: proc(src: ^Surface, srcrect: Maybe(^Rect), dst: ^Surface, dstrect: Maybe(^Rect), scaleMode: ScaleMode) -> bool ---
	StretchSurface               :: proc(src: ^Surface, srcrect: Maybe(^Rect), dst: ^Surface, dstrect: Maybe(^Rect), scaleMode: ScaleMode) -> bool ---
	BlitSurfaceTiled             :: proc(src: ^Surface, srcrect: Maybe(^Rect), dst: ^Surface, dstrect: Maybe(^Rect)) -> bool ---
	BlitSurfaceTiledWithScale    :: proc(src: ^Surface, srcrect: Maybe(^Rect), scale: f32, scaleMode: ScaleMode, dst: ^Surface, dstrect: Maybe(^Rect)) -> bool ---
	BlitSurface9Grid             :: proc(src: ^Surface, srcrect: Maybe(^Rect), left_width, right_width, top_height, bottom_height: c.int, scale: f32, scaleMode: ScaleMode, dst: ^Surface, dstrect: Maybe(^Rect)) -> bool ---
	MapSurfaceRGB                :: proc(surface: ^Surface, r, g, b: Uint8) -> Uint32 ---
	MapSurfaceRGBA               :: proc(surface: ^Surface, r, g, b, a: Uint8) -> Uint32 ---
	ReadSurfacePixel             :: proc(surface: ^Surface, x, y: c.int, r, g, b, a: ^Uint8) -> bool ---
	ReadSurfacePixelFloat        :: proc(surface: ^Surface, x, y: c.int, r, g, b, a: ^f32) -> bool ---
	WriteSurfacePixel            :: proc(surface: ^Surface, x, y: c.int, r, g, b, a: Uint8) -> bool ---
	WriteSurfacePixelFloat       :: proc(surface: ^Surface, x, y: c.int, r, g, b, a: f32) -> bool ---
 ]#

## Section: SDL_video.h


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


## Section: SDL_camera.h


## Section: SDL_events.h


## Section: SDL_render.h


## Section: SDL_init.h


{.pop.}