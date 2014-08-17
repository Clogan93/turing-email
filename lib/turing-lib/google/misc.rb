module Google
  class Misc
    def Misc.get_parameters_from_args(args)
      parameters = {}

      args.each { |arg|
        val = arg.values[0]
        parameters[arg.keys[0]] = val if val
      }

      return parameters
    end
  end
end
