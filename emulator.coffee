# Emulator
# ========
#
# not happening any time soon!
# We need variables!

instructions = require "./instructions"
_ = require "underscore"

addsNextWord = (no for i in [0..0x3f])
addsNextWord[i] = yes for i in [0x10..0x17]
addsNextWord[0x1a] = yes
addsNextWord[0x1e] = yes
addsNextWord[0x1f] = yes

targetType = ('CONTENTS' for i in [0..0x3f])
targetType[i] = 'MEMORY_AT' for i in [0x08..0x1a]
targetType[0x1e] = 'MEMORY_AT'
targetType[i] = 'LITERAL' for i in [0x1f..0x3f]

unsigned = (i) -> if i < 0 then 0x10000 + i else i
coerce = (i) ->
    if i < 0 then return unsigned i
    if i > 0xffff then return i - 0x10000
    i

extraSizeOf = (binary) ->
    opcodeBits  = binary & 0b11111
    aTargetBits = (binary & 0b1111110000000000) >> 10
    bTargetBits = (binary & 0b1111100000) >> 5
    aNextWord = addsNextWord[aTargetBits]
    bNextWord = addsNextWord[bTargetBits]
    aNextWord = if aNextWord then 1 else 0
    bNextWord = if bNextWord then 1 else 0
    aNextWord + bNextWord

class RAM
    constructor: ->
        @[i] = 0 for i in [0..0xffff]

partiallyDecode = (value) ->
    switch value
        when 0x00, 0x08, 0x10 then 'A'
        when 0x01, 0x09, 0x11 then 'B'
        when 0x02, 0x0a, 0x12 then 'C'
        when 0x03, 0x0b, 0x13 then 'X'
        when 0x04, 0x0c, 0x14 then 'Y'
        when 0x05, 0x0d, 0x15 then 'Z'
        when 0x06, 0x0e, 0x16 then 'I'
        when 0x07, 0x0f, 0x17 then 'J'
        when 0x18 then 'SP?'
        when 0x19, 0x1a, 0x1b then 'SP'
        when 0x1c then 'PC'
        when 0x1d then 'EX'
        when 0x1e, 0x1f then 0
        else value - 0x21

class Instruction
    constructor: (@emulator, @binary) ->
        @opcodeBits  = @binary & 0b11111
        @aTargetBits = (@binary & 0b1111110000000000) >> 10
        @bTargetBits = (@binary & 0b1111100000) >> 5
        @a = 0
        @b = 0
        @aTarget = partiallyDecode @aTargetBits
        @aNewWord = 0
        if _.isNumber @aTarget
            @a = @aTarget
        else if @aTarget isnt 'SP?'
            @a = @emulator[@aTarget]
        if @aTarget is 'SP?'
            @a = @emulator.SP++
        if addsNextWord[@aTargetBits]
            @aNewWord = @emulator.ram[@emulator.PC++]
            @a += @aNewWord
        if targetType[@aTargetBits] is 'MEMORY_AT'
            @a = @emulator.ram[@a]
        @bTarget = partiallyDecode @bTargetBits
        if @opcodeBits isnt 0
            @bNewWord = 0
            if _.isNumber @bTarget
                @b = @bTarget
            else if @bTarget isnt 'SP?'
                @b = @emulator[@bTarget]
            if @bTarget is 'SP?'
                @b = --@emulator.SP
            if addsNextWord[@bTargetBits]
                @bNewWord = @emulator.ram[@emulator.PC++]
                @b += @bNewWord
            if targetType[@bTargetBits] is 'MEMORY_AT'
                @b = @emulator.ram[@b]
        ChildType = instructions[@opcodeBits]
        @child = new ChildType @emulator

    execute: ->
        results = @child.execute @a, @b, @aTargetBits, @bTargetBits
        if results.changeA and targetType[@aTargetBits] isnt 'LITERAL'
            newA = results.newA
            if @aTarget is "SP?"
                @emulator.ram[@emulator.SP] = newA
            if targetType[@aTargetBits] is 'MEMORY_AT'
                ramTarget = @emulator[@aTarget]
                if addsNextWord[@aTargetBits]
                    ramTarget += @aNewWord
                @emulator.ram[ramTarget] = newA
            if targetType[@aTargetBits] is 'CONTENTS'
                @emulator[@aTarget] = newA
        if results.changeB and targetType[@bTargetBits] isnt 'LITERAL'
            newB = results.newB
            if @bTarget is "SP?"
                @emulator.ram[@emulator.SP] = newB
            if targetType[@bTargetBits] is 'MEMORY_AT'
                if @bTarget is 0 then ramTarget = 0 else ramTarget = @emulator[@bTarget]
                if addsNextWord[@bTargetBits]
                    ramTarget += @bNewWord
                @emulator.ram[ramTarget] = newB
            if targetType[@bTargetBits] is 'CONTENTS'
                @emulator[@bTarget] = newB

class Emulator
    constructor: ->
        @ram = new RAM
        @A  = 0
        @B  = 0
        @C  = 0
        @X  = 0
        @Y  = 0
        @Z  = 0
        @I  = 0
        @J  = 0
        @PC = 0
        @SP = 0
        @EX = 0
        @IA = 0
        @currPC = 0
        @interruptQueueing = off
        @skipping = no

    tick: ->
        @currPC = @PC++
        currInstruction = new Instruction @, @ram[@currPC]
        if @skipping
            if currInstruction.child.isConditional
                # just keep skipping
            else
                @skipping = no
        else
            currInstruction.execute()
            @SP = coerce @SP

module.exports = Emulator