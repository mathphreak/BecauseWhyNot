# test things
# ===========

Emulator = require "./emulator"
GenericClock = require("./hardware").GenericClock

emulator = new Emulator
clock = new GenericClock @
emulator.addHardware clock

nextRam = do ->
    idx = 0
    return (ist...) -> emulator.ram.set(idx++, i) for i in ist

nextRam 0x7c01, 0x0030          # SET A, 0x30
nextRam 0x7fc1, 0x0020, 0x1000  # SET [0x1000], 0x20
nextRam 0x7803, 0x1000          # SUB A, [0x1000]
nextRam 0xc413                  # IFN A, 0x10
nextRam 0x7f81, 0x0019          # SET PC, crash
nextRam 0xacc1                  # SET I, 10
nextRam 0x7c01, 0x2000          # SET A, 0x2000         :loop
nextRam 0x22c1, 0x2000          # SET [0x2000+I], [A]
nextRam 0x88c3                  # SUB I, 1
nextRam 0x84d3                  # IFN I, 0
nextRam 0xbb81                  # SET PC, loop
nextRam 0x9461                  # SET X, 0x4
nextRam 0x7c20, 0x0017          # JSR testsub
nextRam 0x7f81, 0x0019          # SET PC, crash
nextRam 0x946f                  # SHL X, 4              :testsub
nextRam 0x6381                  # SET PC, POP
nextRam 0x0000                  #                       :crash

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

setInterval tick, 10