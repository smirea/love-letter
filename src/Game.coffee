
_ = require 'lodash'

mixins = require './mixins.coffee'
Player = require './Player.coffee'

class Game
    _.mixin @::, mixins.logs

    classMap: {Princess, Countess, King, Prince, Handmaid, Baron, Priest, Guard}

    defaults:
        players: ['A', 'B', 'C', 'D']
        deck:
            Princess: 1
            Countess: 1
            King: 1
            Prince: 2
            Handmaid: 2
            Baron: 2
            Priest: 2
            Guard: 5

    game_ended: false
    current_player: null
    current_index: -1
    players: null
    deck: null

    constructor: (@options = {}) ->
        @options = _.defaults @options, @defaults
        @game_ended = false
        @deck = @build_deck @options.deck
        @init_players @options.players

    start: ->
        player.draw() for player in @players
        @set_turn 0
        @print_status()

    build_deck: (deck) ->
        result = []
        for role, count of deck
            result.push @classMap[role] for i in [1..count] by 1
        _.shuffle result

    init_players: (names) ->
        @players = (new Player name, @deck for name in names)

    next_turn: ->
        return if @check_end_game()
        for i in [1..@players.length]
            @current_index = ++@current_index % @players.length
            if @players[@current_index].is_alive
                @set_turn @current_index
                break
        @print_status()

    set_turn: (index) ->
        return if @check_end_game()
        throw "Not enough players (#{index} < #{@players.length})" if index >= @players.length
        @current_index = index
        @current_player = @players[@current_index]
        @current_player.turn()
        @setup_current_turn()

    setup_current_turn: ->
        return if @check_end_game()
        @current_player.draw()

    current_player_play: (index, target, args...) ->
        # Trigger on_before_play events and maybe override the play
        for card in @current_player.cards
            result = card.on_before_play?()
            if result?.override
                {index, target, args} = result
                break

        if Number.isFinite target
            throw "Invalid target index #{target}" if target >= @players.length
            target = @players[target]
        @current_player.play index, target, args...
        @print_status()

    check_end_game: ->
        return true if @game_ended

        alive = _.filter @players, is_alive: true

        reason = null

        if alive.length <= 1
            reason = 'Last Man Standing'
            max = power: alive[0].power(), players: alive
        else if @deck.length is 0
            reason = 'No More Cards'
            max = power: -1, players: []
            for player in alive
                power = player.power()
                if power is max.power
                    max.players.push player
                else if power > max.power
                    max = {power, players: [player]}

        if reason
            end_game = true
            @success "GAME OVER (#{reason})!"
            if max.players.length is 0
                @log 'Nobody won lol'
            else if max.players.length is 1
                @log "#{max.players[0].name} won"
            else
                @log 'It is a tie between: ' + _.pluck(max.players, 'name').join ', '
            return true
        else
            return false

    print_status: ->
        result = []
        indent = (str, indent = '    ') ->
            arr = if Array.isArray str then _.clone str else str.split '\n'
            (indent + line for line in arr).join '\n'

        # Deck
        result.push "Deck[#{@deck.length}]: " + (card.toString() for card in @deck).join ', '

        # Player Board
        for player, index in @players
            if player.is_alive
                str = "#{player.name}:"
                str += ' CURRENT'.green if index is @current_index
                str += ' IMMUNE'.cyan if player.is_immune
                str += '\n'
                str += ("  - #{card.name}" for card in player.cards).join '\n'
            else
                str = "#{player.name} is #{'DEAD'.red}"
            result.push str

        @log '\n' + indent result.join('\n'), '   | '

module.exports = Game
