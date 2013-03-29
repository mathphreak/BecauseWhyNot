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

vows.describe("HWQ").addBatch(
    "after running HWQ on a clock":
        topic: ->
            emulator = new Emulator
            emulator.addHardware new GenericClock @
            nextRam = makeNextRam emulator
            nextRam 0x8620 # HWQ 0
            elapse emulator

        "A is 0xb402": (emulator) -> expect(emulator.A).to.be(0xb402)
        "B is 0x12d0": (emulator) -> expect(emulator.B).to.be(0x12d0)
        "C is 0x0001": (emulator) -> expect(emulator.C).to.be(0x0001)
        "X is 0xbeef": (emulator) -> expect(emulator.X).to.be(0xbeef)
        "Y is 0xdead": (emulator) -> expect(emulator.Y).to.be(0xdead)
    "after running HWQ on a LEM1802":
        topic: ->
            emulator = new Emulator
            emulator.addHardware new LEM1802 @
            nextRam = makeNextRam emulator
            nextRam 0x8620 # HWQ 0
            elapse emulator

        "A is 0xf615": (emulator) -> expect(emulator.A).to.be(0xf615)
        "B is 0x7349": (emulator) -> expect(emulator.B).to.be(0x7349)
        "C is 0x1802": (emulator) -> expect(emulator.C).to.be(0x1802)
        "X is 0x8b36": (emulator) -> expect(emulator.X).to.be(0x8b36)
        "Y is 0x1c6c": (emulator) -> expect(emulator.Y).to.be(0x1c6c)
).export(module)