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

vows.describe("HWN").addBatch(
    "on an emulator with just one item":
        topic: ->
            emulator = new Emulator
            emulator.addHardware new GenericClock emulator
            nextRam = makeNextRam emulator
            nextRam 0x0200 # HWN A
            elapse emulator

        "HWQ returns 1": (emulator) -> expect(emulator.A).to.be(1)
    "but with two items":
        topic: ->
            emulator = new Emulator
            emulator.addHardware new GenericClock emulator
            emulator.addHardware new LEM1802 emulator
            nextRam = makeNextRam emulator
            nextRam 0x0600 # HWN B
            elapse emulator

        "HWQ returns 2": (emulator) -> expect(emulator.B).to.be(2)
).export(module)