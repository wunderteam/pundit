require "pundit/version"
require "pundit/policy_finder"
require "active_support/concern"

module Pundit
  class NotAuthorized < StandardError
    attr_accessor :query, :record, :policy
  end
  class PolicyMissing < StandardError; end

  extend ActiveSupport::Concern

  class << self
    def policy(user, record)
      policy = PolicyFinder.new(record).policy
      policy.new(user, record) if policy
    end

    def policy!(user, record)
      PolicyFinder.new(record).policy!.new(user, record)
    end
  end

  included do
    if respond_to?(:helper_method)
      helper_method :policy
      helper_method :pundit_user
    end
    if respond_to?(:hide_action)
      hide_action :policy
      hide_action :policy=
      hide_action :authorize
      hide_action :pundit_user
    end
  end

  def authorize(record, query=nil)
    query ||= params[:action].to_s + "?"

    policy = policy(record)
    unless policy.public_send(query)
      error = NotAuthorized.new("not allowed to #{query} this #{record}")
      error.query, error.record, error.policy = query, record, policy

      raise error
    end

    true
  end

  def policy(record)
    @_policy or Pundit.policy!(pundit_user, record)
  end

  def policy=(policy)
    @_policy = policy
  end

  def pundit_user
    current_user
  end
end
