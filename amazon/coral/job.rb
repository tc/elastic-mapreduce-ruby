module Amazon
module Coral

#
# Internal abstraction that encapsulates the input and output data pertaining to a remote call.
#
# Copyright:: Copyright (c) 2008 Amazon.com, Inc. or its affiliates.  All Rights Reserved.
#
class Job
  def initialize(request)
    @request = request
    @reply = {}
  end

  # Returns the hash of request attributes
  def request
    @request
  end

  # Returns the hash of reply attributes
  def reply
    @reply
  end
end

end
end
