require 'json/lexer'
require 'json/objects'
require 'amazon/coral/handler'
require 'amazon/coral/querystringmap'
require 'amazon/coral/logfactory'

module Amazon
module Coral

#
# Processes requests using the AWS/QUERY protocol.
#
# Copyright:: Copyright (c) 2008 Amazon.com, Inc. or its affiliates.  All Rights Reserved.
#
class AwsQueryHandler < Handler

  def initialize
    @log = LogFactory.getLog('Amazon::Coral::AwsQueryHandler')
  end

  def before(job)
    request = job.request

    operation_name = request[:operation_name]

    query_string_map = QueryStringMap.new(request[:value])
    query_string_map['Action'] = operation_name.to_s
    query_string_map['ContentType'] = 'JSON'

    request[:query_string_map] = query_string_map
    request[:http_verb] = 'POST'

    @log.info "Making request to operation #{operation_name} with parameters #{query_string_map}"
  end

  def after(job)
    operation_name = job.request[:operation_name]

    reply = job.reply

    @log.info "Received response body: #{reply[:value]}"

    json_result = nil
    begin
      json_result = JSON::Lexer.new(reply[:value]).nextvalue
    rescue
      code = reply[:http_status_code]
      message = reply[:http_status_message]

      raise "#{code} : #{message}" unless code.to_i == 200
      raise "Failed parsing response: #{$!}\n"
    end

    reply[:value] = get_value(operation_name, json_result)
  end

 private
  def get_value(operation_name, json_result)
    # If there was an error, unwrap it and return
    return {"Error" => json_result["Error"]} if json_result["Error"]

    # Otherwise unwrap the valid response
    json_result = json_result["#{operation_name}Response"]
    json_result = json_result["#{operation_name}Result"]
    return json_result

  end
end

end
end
