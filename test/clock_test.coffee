# test things
# ===========

expect = require "expect.js"
vows = require "vows"
Emulator = require "../emulator"
hardware = require "../hardware"
test_helpers = require "../test_helpers"

makeNextRam = test_helpers.makeNextRam
makeTopic = test_helpers.makeTopic

GenericClock = hardware.GenericClock
LEM1802 = hardware.LEM1802

delayTestStart = no

vows.describe("Clock").addBatch(
    "if we look for the clock when there's only one piece of hardware":
        topic: makeTopic (emulator) ->
            clock = new GenericClock emulator
            emulator.addHardware clock
            nextRam = makeNextRam emulator
            nextRam 0x1a00
            nextRam 0x88c3
            nextRam 0x1a20
            nextRam 0x7c32, 0x12d0
            nextRam 0x7c12, 0xb402
            nextRam 0x7f81, 0x000a
            nextRam 0x8f9f
            nextRam 0x1bc1, 0x000d
            nextRam 0x0000
            nextRam 0x0000

        "we can find it": (emulator) -> expect(emulator.ram.get 0x000d).to.be(0)
    "if we tell the clock to tick every second":
        topic: makeTopic (emulator) ->
            clock = new GenericClock emulator
            emulator.addHardware clock
            nextRam = makeNextRam emulator
            nextRam 0x8401
            nextRam 0x7c21, 0x003c
            nextRam 0x8640
            nextRam 0x0000

        "it will tick every second": (emulator) -> expect(emulator.hardware[0].tickRate).to.be(1)

        "it set an interval": (emulator) -> expect(emulator.hardware[0].intervalID).to.not.be(no)
    "if we wait for one second":
        topic: makeTopic (emulator) ->
            clock = new GenericClock emulator
            emulator.addHardware clock
            nextRam = makeNextRam emulator
            nextRam 0x1a00
            nextRam 0x88c3
            nextRam 0x1a20
            nextRam 0x7c32, 0x12d0
            nextRam 0x7c12, 0xb402
            nextRam 0x7f81, 0x000a
            nextRam 0x8f9f
            nextRam 0x1bc1, 0x0018
            nextRam 0x8401
            nextRam 0x7c21, 0x003c
            nextRam 0x7a40, 0x0018
            nextRam 0x8801
            nextRam 0x7a40, 0x0018
            nextRam 0x8856
            nextRam 0xcf81
            nextRam 0x7ca1, 0xbeef
            nextRam 0x0000
            nextRam 0x0000
            delayTestStart = new Date
 
        "we waited": (emulator) -> expect(emulator.Z).to.be(0xbeef)

        "one second passed": (emulator) ->
            expect(new Date().getTime() - delayTestStart.getTime()).to.be.within(950, 1050)
).export(module)