# Hardware!!!
# ===========
class Hardware
    constructor: (@emulator) ->

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

    onTick: ->

    onHWI: ->

module.exports =
    Hardware: Hardware
    LEM1802: LEM1802
    GenericClock: GenericClock