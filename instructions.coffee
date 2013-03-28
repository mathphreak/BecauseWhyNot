# Instructions
# ============
#
# Base class for all instructions.
#
class GeneralInstruction
    constructor: (@emulator) ->

    isConditional: no

    execute: (a, b) ->
        changeB: no
        changeA: no

signed = (i) -> i - ((i << 1) & 0xffff)
unsigned = (i) -> if i < 0 then 0x10000 + i else i
coerce = (i) ->
    if Math.round(i) isnt i
        if i < 0
            i = Math.ceil i
        else
            i = Math.floor i
    if i < 0 then i = unsigned i
    if i > 0xffff then i = i - 0x10000
    i

class ModifyInstruction extends GeneralInstruction
    execute: (a, b) ->
        result = @run a, b
        if result isnt no
            changeB: yes
            newB: result
            changeA: no

    run: (a, b) -> no

class ConditionalInstruction extends GeneralInstruction
    execute: (a, b) ->
        @emulator.skipping = yes unless @run a, b
        changeB: no
        changeA: no

    isConditional: yes

    run: (a, b) -> no

class SpecialAction
    constructor: (@emulator) ->

    execute: (a) ->

class JSRAction extends SpecialAction
    execute: (a) ->
        @emulator.ram[coerce --@emulator.SP] = @emulator.PC
        @emulator.PC = a
        no

class INTAction extends SpecialAction
    execute: (a) ->
        # TODO
        # figure out interrupt queueing
        no

class IAGAction extends SpecialAction
    execute: (a) -> @emulator.IA

class IASAction extends SpecialAction
    execute: (a) ->
        @emulator.IA = a
        no

class RFIAction extends SpecialAction
    execute: (a) ->
        @emulator.interruptQueueing = off
        @emulator.A = @emulator.ram[coerce @emulator.SP++]
        @emulator.PC = @emulator.ram[coerce @emulator.SP++]
        no

class IAQAction extends SpecialAction
    execute: (a) ->
        @emulator.interruptQueueing = a isnt 0
        no

class HWNAction extends SpecialAction
    execute: (a) ->
        # TODO
        # figure out hardware
        0

class HWQAction extends SpecialAction
    execute: (a) ->
        # TODO
        # still, figure out hardware
        no

class HWIAction extends SpecialAction
    execute: (a) ->
        # TODO
        # seriously, figure out hardware for pity's sake!
        no

specialActions = []
specialActions[0x01] = JSRAction
specialActions[0x08] = INTAction
specialActions[0x09] = IAGAction
specialActions[0x0a] = IASAction
specialActions[0x0b] = RFIAction
specialActions[0x0c] = IAQAction
specialActions[0x10] = HWNAction
specialActions[0x11] = HWQAction
specialActions[0x12] = HWIAction

class SpecialInstruction extends GeneralInstruction
    execute: (a, b, aTargetBits, bTargetBits) ->
        debugger
        ActionType = specialActions[bTargetBits]
        action = new ActionType @emulator
        result = action.execute a
        changeB: no
        changeA: result isnt no
        newA: result

class SETInstruction extends ModifyInstruction
    run: (a, b) -> unsigned a

class ADDInstruction extends ModifyInstruction
    run: (a, b) ->
        result = b + a
        @emulator.EX = if result > 0xffff then 1 else 0
        unsigned result

class SUBInstruction extends ModifyInstruction
    run: (a, b) ->
        result = b - a
        @emulator.EX = if result < 0 then 0xffff else 0
        unsigned result

class MULInstruction extends ModifyInstruction
    run: (a, b) ->
        result = b * a
        @emulator.EX = (result>>16)&0xffff
        unsigned result

class MLIInstruction extends ModifyInstruction
    run: (a, b) ->
        result = signed(b) * signed a
        @emulator.EX = (result>>16)&0xffff
        unsigned result

class DIVInstruction extends ModifyInstruction
    run: (a, b) ->
        result = b / a
        @emulator.EX = ((b<<16)/a)&0xffff
        coerce result

class DVIInstruction extends ModifyInstruction
    run: (a, b) ->
        result = signed(b) / signed a
        @emulator.EX = ((signed(b)<<16)/signed(a))&0xffff
        coerce result

class MODInstruction extends ModifyInstruction
    run: (a, b) -> unsigned if a is 0 then 0 else b % a

class MDIInstruction extends ModifyInstruction
    run: (a, b) -> unsigned if a is 0 then 0 else signed(b) % signed a

class ANDInstruction extends ModifyInstruction
    run: (a, b) -> b & a

class BORInstruction extends ModifyInstruction
    run: (a, b) -> b | a

class XORInstruction extends ModifyInstruction
    run: (a, b) -> b ^ a

class SHRInstruction extends ModifyInstruction
    run: (a, b) ->
        @emulator.EX = ((b<<16)>>a)&0xffff
        b >>> a

class ASRInstruction extends ModifyInstruction
    run: (a, b) ->
        @emulator.EX = ((b<<16)>>>a)&0xffff
        b >> a

class SHLInstruction extends ModifyInstruction
    run: (a, b) ->
        @emulator.EX = ((b<<a)>>16)&0xffff
        b << a

class IFBInstruction extends ConditionalInstruction
    run: (a, b) -> (b & a) isnt 0

class IFCInstruction extends ConditionalInstruction
    run: (a, b) -> (b & a) is 0

class IFEInstruction extends ConditionalInstruction
    run: (a, b) -> b is a

class IFNInstruction extends ConditionalInstruction
    run: (a, b) -> b isnt a

class IFGInstruction extends ConditionalInstruction
    run: (a, b) -> b > a

class IFAInstruction extends ConditionalInstruction
    run: (a, b) -> signed(b) > signed a

class IFLInstruction extends ConditionalInstruction
    run: (a, b) -> b < a

class IFUInstruction extends ConditionalInstruction
    run: (a, b) -> signed(b) < signed a

class ADXInstruction extends ModifyInstruction
    run: (a, b) ->
        result = b + a + @emulator.EX
        @emulator.EX = if result > 0xffff then 1 else 0
        unsigned result

class SBXInstruction extends ModifyInstruction
    run: (a, b) ->
        result = b - a + EX
        @emulator.EX = if result < 0 then 0xffff else if result > 0xffff then 1 else 0
        unsigned result

# hey guess what?  STI means something...
class STIInstruction extends ModifyInstruction
    run: (a, b) ->
        @emulator.I++
        @emulator.J++
        a

# ...that STD used to mean!  Thanks!
class STDInstruction extends ModifyInstruction
    run: (a, b) ->
        @emulator.I--
        @emulator.J--
        a

module.exports = []
module.exports[0x00] = SpecialInstruction
module.exports[0x01] = SETInstruction
module.exports[0x02] = ADDInstruction
module.exports[0x03] = SUBInstruction
module.exports[0x04] = MULInstruction
module.exports[0x05] = MLIInstruction
module.exports[0x06] = DIVInstruction
module.exports[0x07] = DVIInstruction
module.exports[0x08] = MODInstruction
module.exports[0x09] = MDIInstruction
module.exports[0x0a] = ANDInstruction
module.exports[0x0b] = BORInstruction
module.exports[0x0c] = XORInstruction
module.exports[0x0d] = SHRInstruction
module.exports[0x0e] = ASRInstruction
module.exports[0x0f] = SHLInstruction
module.exports[0x10] = IFBInstruction
module.exports[0x11] = IFCInstruction
module.exports[0x12] = IFEInstruction
module.exports[0x13] = IFNInstruction
module.exports[0x14] = IFGInstruction
module.exports[0x15] = IFAInstruction
module.exports[0x16] = IFLInstruction
module.exports[0x17] = IFUInstruction
module.exports[0x1a] = ADXInstruction
module.exports[0x1b] = SBXInstruction
module.exports[0x1e] = STIInstruction
module.exports[0x1f] = STDInstruction