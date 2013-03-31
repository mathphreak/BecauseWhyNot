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

vows.describe("HWN").addBatch(
    "on an emulator with just one item":
        topic: makeTopic (emulator) ->
            emulator.addHardware new GenericClock emulator
            nextRam = makeNextRam emulator
            nextRam 0x0200 # HWN A

        "HWN returns 1": (emulator) -> expect(emulator.A).to.be(1)
    "but with two items":
        topic: makeTopic (emulator) ->
            emulator.addHardware new GenericClock emulator
            emulator.addHardware new LEM1802 emulator
            nextRam = makeNextRam emulator
            nextRam 0x0600 # HWN B

        "HWN returns 2": (emulator) -> expect(emulator.B).to.be(2)
).export(module)