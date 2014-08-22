_ = require 'lodash'
mixins = require './mixins.coffee'

class Player
    _.mixin @::, mixins.logs

    name: null
    cards: null
    is_alive: true
    is_immune: false

    cards_played: null

    constructor: (name, @deck) ->
        @name = name.bold
        @cards = []
        @cards_played = []

    role: -> @cards[0]
    power: -> @role().power

    die: ->
        @log "#{@name} is dead"
        @is_alive = false

    draw: ->
        if card = @deck.pop()
            instance = new card @
            @cards.push instance
            @log "#{@name} draws a new card: #{instance.name}"
        else if @cards.length is 0
            @warn "#{@name} has no more cards to draw"
            @die()

    # Discards the first card in the hand
    discard: ->
        card = @cards.shift()
        @log "#{@name} discards #{card}"
        card.on_discard?()
        return unless @is_alive
        @draw()

    # Called when it's this player's current turn
    turn: ->
        @is_immune = false
        @info "It is #{@name}'s turn"

    # Play a card on a target
    play: (index, target = @, args...) ->
        if typeof index isnt 'number'
            index = _.findIndex @cards, index

        @throw "Invalid card: #{index}" if typeof index isnt 'number' or index < 0

        if @cards.length < 2
            @throw "You need at least 2 cards to play, you got #{@cards.length} cards"

        if index >= @cards.length
            @throw "#{@name} does not have `#{index}` cards in their hand"

        card = _.first @cards.splice index, 1
        card.set_target target

        @log "#{@name}(#{@role().name}) plays #{card.name} on #{target.name}(#{target.role().name}), args:", args...

        if target.is_immune
            return @warn "#{target.name} is Immune, nothing happens"
        else
            card.perform args...

    # Gets the first index of the given role in the Player's hand
    card_index: (role) ->
        for card, index in @cards when card.constructor is role
            return index
        return -1

module.exports = Player
