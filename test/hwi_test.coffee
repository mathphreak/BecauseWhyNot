# test things
# ===========

expect = require "expect.js"
vows = require "vows"
Emulator = require "../emulator"
hardware = require "../hardware"
test_helpers = require "../test_helpers"

makeNextRam = test_helpers.makeNextRam
elapse = test_helpers.elapse

GenericClock = hardware.GenericClock
LEM1802 = hardware.LEM1802

vows.describe("HWI").addBatch(
    "a dummy piece of hardware":
        topic: ->
            emulator = new Emulator
            dummyHardware = new hardware.Hardware emulator
            dummyHardware.interrupted = no
            dummyHardware.onHWI = ->
                @interrupted = yes
            emulator.addHardware dummyHardware
            nextRam = makeNextRam emulator
            nextRam 0x8640 # HWI 0
            elapse emulator

        "notices when we HWI it": (emulator) -> expect(emulator.hardware[0].interrupted).to.be.ok()
).export(module)