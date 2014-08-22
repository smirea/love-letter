
_ = require 'lodash'

# Returns the descendant of an object (e.g. (a:b:c:1, 'a.b') -> c:1)
get_object = (base, str) ->
    base = base[key] for key in str.split '.'
    base

module.exports =
    logs:
        __get_ns: (color = null) ->
            ns = "[#{@constructor?.name}]"
            ns = get_object ns, color if color?.length
            "#{ns} "

        __console_message: (method, args, color = null) ->
            @__console_ns method, @__get_ns(color), args

        ###
        # When you want to log with a namespace (e.g. [PORT] a b c)
        #   but you want to preserve the functionality of the first argument
        #   (aka still have it work if it is `Hello %s` or if it's a non-string)
        # @param method log|info|warn|error|debug
        # @param prepend The string to prepend
        # @param args
        ###
        __console_ns: (method, prepend, args = []) ->
            arg1 = prepend
            if _.isString args[0]
                args[0].slice 0, prepend.length if args[0].indexOf prepend is 0
                arg1 += args[0]
                args = args[1..]
            arr = [arg1].concat args
            console[method].apply console, arr

        log: (args...) -> @__console_message 'log', args
        info: (args...) -> @__console_message 'info', args, 'blue.bold'
        success: (args...) -> @__console_message 'info', args, 'green'
        warn: (args...) -> @__console_message 'warn', args, 'yellow'
        error: (args...) -> @__console_message 'error', args, 'red.bold'

        throw: (error) ->
            add_ns = (str) =>
                ns = @__get_ns()
                str.replace (new RegExp "^#{ns}"), ''
                ns + str

            if _.isString error
                error = new Error add_ns error
            else
                error.message = add_ns error.message

            throw error
