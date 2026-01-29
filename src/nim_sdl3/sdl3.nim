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

const SDL_VERSION* =  SDL_VERSION_NUM(SDL_MAJOR_VERSION, SDL_MINOR_VERSION, SDL_MICRO_VERSION)
template SDL_VERSION_ATLEAST* (X, Y, Z): bool = SDL_VERSION >= SDL_VERSIONNUM(X, Y, Z)

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
    bytes_requested*: uint64
    bytes_transferred*: uint64
    userdata*: pointer

proc asyncIOFromFile*(file, mode: cstring): AsyncIOPtr {.importc: "SDL_AsyncIOFromFile".}
proc getSize*(asyncio: AsyncIOPtr): int64 {.importc: "SDL_GetAsyncIOSize".}
proc read*(asyncio: AsyncIOPtr, readPtr: pointer, offset, size: uint64, queue: AsyncIOQueuePtr, userdata: pointer): bool {.importc: "SDL_ReadAsyncIO".}
proc write*(asyncio: AsyncIOPtr, writePtr: pointer, offset, size: uint64, queue: AsyncIOQueuePtr, userdata: pointer): bool {.importc: "SDL_WriteAsyncIO".}
proc close*(asyncio: AsyncIOPtr, flush: bool, queue: AsyncIOQueuePtr, userdata: pointer): bool {.importc: "SDL_CloseAsyncIO".}

proc createAsyncIOQueue*(): AsyncIOQueuePtr {.importc: "SDL_CreateAsyncIOQueue".}
proc destroy*(asyncioQueue: AsyncIOQueuePtr): void {.importc: "SDL_DestroyAsyncIOQueue".}
proc getAsyncIOResult*(asyncioQueue: AsyncIOQueuePtr, outPtr: AsyncIOOutcomePtr): bool {.importc: "SDL_GetAsyncIOResult".}
proc waitAsyncIOResult*(asyncioQueue: AsyncIOQueuePtr, outPtr: AsyncIOOutcomePtr, timeoutMs: int32): bool {.importc: "SDL_WaitAsyncIOResult".}
proc signal*(asyncioQueue: AsyncIOQueuePtr): void {.importc: "SDL_SignalAsyncIOQueue".}
proc loadFileAsync*(file: cstring, queue: AsyncIOQueuePtr, userdata: pointer): bool {.importc: "SDL_LoadFileAsync".}

## Section: SDL_atomic.h

type
  SpinLock* = distinct cint
  SpinLockPtr* = ptr SpinLock
  AtomicIntPtr* = ptr AtomicInt
  AtomicInt* = distinct cint
  AtomicU32Ptr* = ptr AtomicU32
  AtomicU32* = distinct uint32

proc tryLock*(lock: SpinLockPtr): bool {.importc: "SDL_TryLockSpinLock".}
proc lock*(lock: SpinLockPtr): void {.importc: "SDL_LockSpinLock".}
proc unlock*(lock: SpinLockPtr): void {.importc: "SDL_UnlockSpinLock".}

proc memoryBarrierReleaseFunction*(): void {.importc: "SDL_MemoryBarrierReleaseFunction".}
proc memoryBarrierAcquireFunction*(): void {.importc: "SDL_MemoryBarrierAcquireFunction".}

proc compareAndSwap*(atom: AtomicU32Ptr, oldValue, newValue: uint32): bool {.importc: "SDL_CompareAndSwapAtomicU32".}
proc set*(atom: AtomicU32Ptr, value: uint32): uint32 {.importc: "SDL_SetAtomicU32".}
proc get*(atom: AtomicU32Ptr): uint32 {.importc: "SDL_GetAtomicU32".}
proc add*(atom: AtomicU32Ptr, value: uint32): uint32 {.importc: "SDL_AddAtomicU32".}
proc compareAndSwap*(atom: AtomicIntPtr, oldValue, newValue: pointer): bool {.importc: "SDL_CompareAndSwapAtomicPointer".}
proc set*(atom: AtomicIntPtr, value: pointer): pointer {.importc: "SDL_SetAtomicPointer".}
proc get*(atom: AtomicIntPtr): pointer {.importc: "SDL_GetAtomicPointer".}

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
proc hasProperty*(props: PropertiesId, name: cstring): bool {.importc: "SDL_HasProperty".}
proc getPropertyType*(props: PropertiesId, name: cstring): PropertyType {.importc: "SDL_GetPropertyType".}

proc getPointerProperty*(props: PropertiesId, name: cstring, default_value: pointer): pointer {.importc: "SDL_GetPointerProperty".}
proc getStringProperty*(props: PropertiesId, name, default_value: cstring): cstring {.importc: "SDL_GetStringProperty".}
proc getNumberProperty*(props: PropertiesId, name: cstring, default_value: int64): int64 {.importc: "SDL_GetNumberProperty".}
proc getFloatProperty*(props: PropertiesId, name: cstring, default_value: float32): float32 {.importc: "SDL_GetFloatProperty".}
proc getBooleanProperty*(props: PropertiesId, name: cstring, default_value: bool): bool {.importc: "SDL_GetBooleanProperty".}

proc setPointerProperty*(props: PropertiesId, name: cstring, value: pointer): bool {.importc: "SDL_SetPointerProperty".}
proc setPointerProperty*(props: PropertiesId, name: cstring, value: pointer, cleanupCb: CleanupPropertyCb, userdata: pointer): bool {.importc: "SDL_SetPointerPropertyWithCleanup".}
proc setStringProperty*(props: PropertiesId, name, value: cstring): bool {.importc: "SDL_SetStringProperty".}
proc setNumberProperty*(props: PropertiesId, name: cstring, value: int64): bool {.importc: "SDL_SetNumberProperty".}
proc setFloatProperty*(props: PropertiesId, name: cstring, value: float32): bool {.importc: "SDL_SetFloatProperty".}
proc setBooleanProperty*(props: PropertiesId, name: cstring, value: bool): bool {.importc: "SDL_SetBooleanProperty".}

proc enumerateProperties*(props: PropertiesId, enumCb: EnumeratePropertiesCb, userdata: pointer): void {.importc: "SDL_EnumerateProperties".}
proc clearProperty*(props: PropertiesId, name: cstring): bool {.importc: "SDL_ClearProperty".}

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
  IOStreamInterfaceSizeCallback* = proc(userdata: pointer): int64 {.cdecl.}
  IOStreamInterfaceSeekCallback* = proc(userdata: pointer, offset: int64, whence: IOWhence): int64 {.cdecl.}
  IOStreamInterfaceReadCallback* = proc(userdata, locPtr: pointer, size: uint, status: IOStatusPtr): uint {.cdecl.}
  IOStreamInterfaceWriteCallback* = proc(userdata, locPtr: pointer, size: uint, status: IOStatusPtr): uint {.cdecl.}
  IOStreamInterfaceFlushCallback* = proc(userdata: pointer, status: IOStatusPtr): bool {.cdecl.}
  IOStreamInterfaceCloseCallback* = proc(userdata: pointer): bool {.cdecl.}
  IOStreamInterfacePtr* = ptr IOStreamInterface
  IOStreamInterface* {.bycopy.} = object
    version: uint32
    size: IOStreamInterfaceSizeCallback
    seek: IOStreamInterfaceSeekCallback
    read: IOStreamInterfaceReadCallback
    write: IOStreamInterfaceWriteCallback
    flush: IOStreamInterfaceFlushCallback
    close: IOStreamInterfaceCloseCallback

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
proc IOFromMemory*(memPtr: pointer, size: uint): IOStreamPtr {.importc: "SDL_IOFromMem".}
proc IOFromConstMemory*(memPtr: pointer, size: uint): IOStreamPtr {.importc: "SDL_IOFromConstMem".}
proc IOFromDynamicMem*(): IOStreamPtr {.importc: "SDL_IOFromDynamicMem".}

proc openIO*(iface: IOStreamInterfacePtr, userdata: pointer): IOStreamPtr {.importc: "SDL_OpenIO".}
proc open*(iface: IOStreamInterfacePtr, userdata: pointer): IOStreamPtr =
  openIO(iface, userdata)
proc closeIO*(iostream: IOStreamPtr): void {.importc: "SDL_CloseIO".}
proc close*(iostream: IOStreamPtr): void =
  closeIO(iostream)

proc getProperties*(iostream: IOStreamPtr): PropertiesId {.importc: "SDL_GetIOProperties".}
proc getStatus*(iostream: IOStreamPtr): IOStatus {.importc: "SDL_GetIOStatus".}
proc getSize*(iostream: IOStreamPtr): int64 {.importc: "SDL_GetIOSize".}

proc seek*(iostream: IOStreamPtr, offset: int64, whence: IOWhence): int64 {.importc: "SDL_SeekIO".}
proc tell*(iostream: IOStreamPtr): int64 {.importc: "SDL_TellIO".}
proc read*(iostream: IOStreamPtr, readPtr: pointer, size: uint): uint {.importc: "SDL_ReadIO".}
proc write*(iostream: IOStreamPtr, writePtr: pointer, size: uint): uint {.importc: "SDL_WriteIO".}
proc flush*(iostream: IOStreamPtr): bool {.importc: "SDL_FlushIO".}

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
  AudioSpec* = object
    format*: AudioFormat
    channels*: cint
    freq*: cint
  
  AudioStreamPtr = ptr object
  AudioStreamCallback* = proc(userdata: pointer, stream: AudioStreamPtr, additionalAmount, totalAmount: cint): void {.cdecl.}
  AudioStreamDataCompleteCallback* = proc(userdata, buffer: pointer, bufferLen: cint): void {.cdecl.}
  AudioPostmixCallback* = proc(userdata: pointer, spec: AudioSpecPtr, buffer: ptr float, bufferLen: cint): void {.cdecl.}

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
proc getAudioDeviceName*(deviceID: AudioDeviceID): cstring {.importc: "SDL_GetAudioDeviceName".}
proc getAudioDeviceFormat*(deviceID: AudioDeviceId, spec: AudioSpecPtr, sampleFrames: ptr cint): bool {.importc: "SDL_GetAudioDeviceFormat".}

{.pop.}