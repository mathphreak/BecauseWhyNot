# Hardware!!!
# ===========
class Hardware
    constructor: (@emulator) ->
        @init()

    init: ->

    getID: -> 0x00000000

    getVersion: -> 0x0000

    getManufacturer: -> 0x00000000

    onTick: ->

    onHWI: ->

class NyaElektriskaHardware extends Hardware
    getManufacturer: -> 0x1c6c8b36

class LEM1802 extends NyaElektriskaHardware
    getID: -> 0x7349f615
    getVersion: -> 0x1802

    onTick: ->

    onHWI: ->

class GenericHardware extends Hardware
    getManufacturer: -> 0xdeadbeef

class GenericClock extends GenericHardware
    getID: -> 0x12d0b402
    getVersion: -> 1

    init: ->
        @tickRate = 0 # in Hz; 0 means off
        @ticks = 0
        @intervalID = no

    onTick: ->

    onClockTick: =>
        @ticks++
        if @interruptMessage isnt no
            # TODO
            # figure out interrupts
            no

    onHWI: ->
        A = @emulator.A
        B = @emulator.B
        switch A
            when 0
                @tickRate = if B is 0 then 0 else 60/B
                @ticks = 0
                if @intervalID isnt no
                    clearInterval @intervalID
                @intervalID = setInterval(@onClockTick, @tickRate * 1000)
            when 1
                @emulator.C = @ticks
            when 2
                @interruptMessage = if B is 0 then no else B

module.exports =
    Hardware: Hardware
    LEM1802: LEM1802
    GenericClock: GenericClock