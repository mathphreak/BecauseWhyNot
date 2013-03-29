exports.makeNextRam = (emulator) ->
    idx = 0
    (ist...) -> emulator.ram[idx++] = i for i in ist

exports.elapse = (emulator) ->
    while not emulator.finished
        emulator.tick()
    emulator