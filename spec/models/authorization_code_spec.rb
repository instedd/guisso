require 'rails_helper'

describe AuthorizationCode do
  include_examples "user lifespan", AuthorizationCode
end
