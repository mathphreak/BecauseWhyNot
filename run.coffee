# test things
# ===========

Emulator = require "./emulator"
GenericClock = require("./hardware").GenericClock

emulator = new Emulator
clock = new GenericClock @
emulator.addHardware clock

nextRam = do ->
    idx = 0
    return (ist...) -> emulator.ram[idx++] = i for i in ist

nextRam 0x8620 # HWQ 0

hexed = (i) ->
    string = i.toString 16
    padding = switch string.length
        when 1 then "000"
        when 2 then "00"
        when 3 then "0"
        when 4 then ""
        else "AAAAAAaAaaaaAAAaaAAAAaaaAAAAA!!!!!"
    "0x#{ padding }#{ string }"

logEmulatorStatus = ->
    console.log "A: #{ hexed emulator.A } |
 B: #{ hexed emulator.B } |
 C: #{ hexed emulator.C } |
 X: #{ hexed emulator.X } |
 Y: #{ hexed emulator.Y } |
 Z: #{ hexed emulator.Z } |
 I: #{ hexed emulator.I } |
 J: #{ hexed emulator.J } |
 PC: #{ hexed emulator.PC } |
 SP: #{ hexed emulator.SP } |
 EX: #{ hexed emulator.EX } |
 IA: #{ hexed emulator.IA }"

tick = ->
    emulator.tick()
    logEmulatorStatus()

logEmulatorStatus()

setInterval tick, 100