
require 'colors'

_ = require 'lodash'

Roles = require './src/Roles.coffee'

# HACK: add all the Roles to the global scopelog
global[name] = role for name, role of Roles

Game = require './src/Game.coffee'

init = ->
    game = new Game
    game.deck.length = 0
    game.deck.push [
        Guard, Priest, Baron, Handmaid, Prince, King, Countess, Prince
        Handmaid, Prince, Prince, Priest, King, Guard, Countess
    ].reverse()...
    game.start()

    next = ->
        game.current_player_play arguments...
        game.next_turn()

    next 0, 1, Priest
    next 1, 3
    next 0, 2
    next 0, 3
    next 0
    next 1, 3
    next 1, 0
    next 1, 3
    next 1, 0, Priest
    next 0, 3

# INIT
init()
