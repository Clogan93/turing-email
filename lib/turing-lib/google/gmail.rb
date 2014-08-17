module Google
  class Gmail
    attr_accessor :api_client, :gmail_api

    def initialize(api_client)
      self.api_client = api_client
      self.gmail_api = api_client.discovered_api('gmail', 'v1')
    end

    # labels

    def labels_list(userId, fields = nil)
      args = method(__method__).parameters.map { |arg| {arg[1] => eval(arg[1].to_s)} }
      parameters = Google::Misc.get_parameters_from_args(args)

      result = self.api_client.execute(:api_method => self.gmail_api.users.labels.list,
                                       :parameters => parameters)

      return JSON.parse(result.data.to_json())
    end

    # threads

    def threads_list(userId, includeSpamTrash = nil, labelIds = nil, maxResults = nil, pageToken = nil, q = nil, fields = nil)
      args = method(__method__).parameters.map { |arg| {arg[1] => eval(arg[1].to_s)} }
      parameters = Google::Misc.get_parameters_from_args(args)

      result = self.api_client.execute(:api_method => self.gmail_api.users.threads.list,
                                       :parameters => parameters)
      return JSON.parse(result.data.to_json())
    end

    def threads_get_call(userId, id, fields = nil)
      args = method(__method__).parameters.map { |arg| {arg[1] => eval(arg[1].to_s)} }
      parameters = Google::Misc.get_parameters_from_args(args)

      return :api_method => self.gmail_api.users.threads.get,
             :parameters => parameters
    end

    def threads_get(userId, id, fields = nil)
      call = self.threads_get_call(userId, id, fields)
      result = self.api_client.execute(call)
      return JSON.parse(result.data.to_json())
    end

    # messages

    def messages_get_call(userId, id, format = nil, fields = nil)
      args = method(__method__).parameters.map { |arg| {arg[1] => eval(arg[1].to_s)} }
      parameters = Google::Misc.get_parameters_from_args(args)

      return :api_method => self.gmail_api.users.messages.get,
             :parameters => parameters
    end

    def messages_get(userId, id, format = nil, fields = nil)
      call = self.messages_get_call(userId, id, format, fields)
      result = self.api_client.execute(call)
      return JSON.parse(result.data.to_json())
    end
  end
end
