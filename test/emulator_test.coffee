# test things
# ===========

expect = require "expect.js"
vows = require "vows"
Emulator = require "../emulator"
test_helpers = require "../test_helpers"

makeNextRam = test_helpers.makeNextRam
elapse = test_helpers.elapse

vows.describe("Emulation").addBatch(
    "after running Notch's test code":
        topic: ->
            emulator = new Emulator
            nextRam = makeNextRam emulator
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
            elapse emulator
        "ram[0x2000..0x200a] is all ram[0x2000]": (emulator) ->
            expect(emulator.ram[0x2000]).to.be(emulator.ram[0x2000])
            expect(emulator.ram[0x2001]).to.be(emulator.ram[0x2000])
            expect(emulator.ram[0x2002]).to.be(emulator.ram[0x2000])
            expect(emulator.ram[0x2003]).to.be(emulator.ram[0x2000])
            expect(emulator.ram[0x2004]).to.be(emulator.ram[0x2000])
            expect(emulator.ram[0x2005]).to.be(emulator.ram[0x2000])
            expect(emulator.ram[0x2006]).to.be(emulator.ram[0x2000])
            expect(emulator.ram[0x2007]).to.be(emulator.ram[0x2000])
            expect(emulator.ram[0x2008]).to.be(emulator.ram[0x2000])
            expect(emulator.ram[0x2009]).to.be(emulator.ram[0x2000])
            expect(emulator.ram[0x200a]).to.be(emulator.ram[0x2000])
        "X is 0x0040": (emulator) -> expect(emulator.X).to.be(0x0040)
    "after running github/0x10cStandardsCommittee/0x10c-Standards/TESTS/high-nerd.dasm16":
        topic: ->
            emulator = new Emulator
            nextRam = makeNextRam emulator
            nextRam 0x7c41, 0x01f4 # SET C, 500
            nextRam 0x7c42, 0x01f3 # ADD C, 499
            nextRam 0x7c43, 0x0063 # SUB C, 99
            nextRam 0x8c44         # MUL C, 2
            nextRam 0x8001         # SET A, 0xffff
            nextRam 0x0803         # SUB A, C
            nextRam 0x0041         # SET C, A
            nextRam 0x8401         # SET A, 0
            nextRam 0x8c45         # MLI C, 2
            nextRam 0x9047         # DVI C, 3
            elapse emulator
        "C is 0xfb50": (emulator) ->
            expect(emulator.C).to.be(0xfb50)
        "A is 0": (emulator) -> expect(emulator.A).to.be(0)
).export(module)