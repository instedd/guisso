require 'rails_helper'

describe AccessToken do
  include_examples "user lifespan", AccessToken
end
