# test things
# ===========

expect = require "expect.js"
vows = require "vows"
Emulator = require "../emulator"
hardware = require "../hardware"
test_helpers = require "../test_helpers"

makeNextRam = test_helpers.makeNextRam
makeTopic = test_helpers.makeTopic

vows.describe("HWI").addBatch(
    "a dummy piece of hardware":
        topic: makeTopic (emulator) ->
            dummyHardware = new hardware.Hardware emulator
            dummyHardware.interrupted = no
            dummyHardware.onHWI = ->
                @interrupted = yes
            emulator.addHardware dummyHardware
            nextRam = makeNextRam emulator
            nextRam 0x8640 # HWI 0

        "notices when we HWI it": (emulator) -> expect(emulator.hardware[0].interrupted).to.be.ok()
).export(module)