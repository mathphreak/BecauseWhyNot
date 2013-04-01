Emulator = require "./emulator"
events = require "events"

exports.makeNextRam = (emulator) ->
    idx = 0
    (ist...) -> emulator.ram.set(idx++, i) for i in ist

exports.makeTopic = (topicFunction) -> ->
    emulator = new Emulator
    topicFunction emulator
    promise = new events.EventEmitter
    done = no
    intervalID = setInterval (callback) ->
        if done
            intervalID.unref()
        if emulator.finished and not done
            debugger
            callback null, emulator
            done = yes
        else
            emulator.tick()
    , 1, @callback
    return