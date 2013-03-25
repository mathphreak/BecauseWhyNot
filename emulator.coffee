# Emulator
# ========
#
# We need variables!
ram = (0 for i in [0..10000])
ram.A = 0
ram.B = 0
ram.C = 0
ram.X = 0
ram.Y = 0
ram.Z = 0
ram.I = 0
ram.J = 0
ram.PC = 0
ram.SP = 0xFFFF
ram.EX = 0
ram.IA = 0

literal = (i) -> i

valueAt = (i) -> ram[i]

memoryAt = (i) -> ram[ram[i]]

decodeValue = (value, getNextWord) ->
    switch value
        when 0x00 then valueAt 'A'
        when 0x01 then valueAt 'B'
        when 0x02 then valueAt 'C'
        when 0x03 then valueAt 'X'
        when 0x04 then valueAt 'Y'
        when 0x05 then valueAt 'Z'
        when 0x06 then valueAt 'I'
        when 0x07 then valueAt 'J'
        when 0x08 then memoryAt 'A'
        when 0x09 then memoryAt 'B'
        when 0x0A then memoryAt 'C'
        when 0x0B then memoryAt 'X'
        when 0x0C then memoryAt 'Y'
        when 0x0D then memoryAt 'Z'
        when 0x0E then memoryAt 'I'
        when 0x0F then memoryAt 'J'
        when 0x10 then valueAt (valueAt 'A' + getNextWord())
        when 0x11 then valueAt (valueAt 'B' + getNextWord())
        when 0x12 then valueAt (valueAt 'C' + getNextWord())
        when 0x13 then valueAt (valueAt 'X' + getNextWord())
        when 0x14 then valueAt (valueAt 'Y' + getNextWord())
        when 0x15 then valueAt (valueAt 'Z' + getNextWord())
        when 0x16 then valueAt (valueAt 'I' + getNextWord())
        when 0x17 then valueAt (valueAt 'J' + getNextWord())
        # 0x18 depends on whether we're A or B
        when 0x19 then memoryAt 'SP'
        when 0x1A then valueAt (valueAt 'SP' + getNextWord())
        when 0x1B then valueAt 'SP'
        when 0x1C then valueAt 'PC'
        when 0x1D then valueAt 'EX'
        when 0x1E then valueAt getNextWord()
        when 0x1F then literal getNextWord()