_ = require 'lodash'
mixins = require './mixins.coffee'

class Role
    _.mixin @::, mixins.logs

    power: 0
    player: null
    target: null

    constructor: (@player, @target) ->
        @name = @constructor.toString()

    set_player: (@player) ->

    set_target: (@target) ->

    perform: -> #noop

    toString: -> @constructor.toString()

class Guard extends Role
    power: 1

    perform: (role) ->
        if role is Guard
            return @error 'You can\'t guess Guard'

        if @target.role().constructor is role
            @target.die()

        undefined

class Priest extends Role
    power: 2

    perform: ->
        target_role = @target.role()
        @log "#{@target.name} is a #{target_role.name}"
        target_role

class Baron extends Role
    power: 3

    perform: ->
        return @error "You cannot compare with yourself" if @target is @player

        if @target.power() < @player.power()
            @target.die()
        else if @target.power() > @player.power()
            @player.die()
        else
            @log "#{@player.name} VS #{@target.name} -> TIE"

        undefined

class Handmaid extends Role
    power: 4

    perform: ->
        @player.is_immune = true
        undefined

class Prince extends Role
    power: 5

    perform: ->
        @target.discard()
        undefined

class King extends Role
    power: 6

    perform: ->
        player_role = @player.cards.shift()
        player_role.set_player @target

        target_role = @target.cards.shift()
        target_role.set_player @player

        @target.cards.unshift player_role
        @player.cards.unshift target_role

        target_role

class Countess extends Role
    power: 7

    on_before_play: ->
        return if @player.cards.length < 2
        if @player.card_index(King) > -1 or @player.card_index(Prince) > -1
            return {
                override: true
                index: @
                target: @player
                args: []
            }
        undefined

class Princess extends Role
    power: 8

    on_discard: ->
        @player.die()
        undefined

module.exports = {Princess, Countess, King, Prince, Handmaid, Baron, Priest, Guard, Role}

# Add Static methods to all Role classes
for name, cls of module.exports
    pointer = cls
    while pointer and pointer isnt Role
        pointer = pointer.__super__?.constructor
    continue unless pointer is Role
    cls.toString = -> "[#{@name}]".yellow
