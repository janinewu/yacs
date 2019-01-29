require 'oj'
require 'redis'

class StateStore
	KEY_PREFIX = '/observer/state_store/'

	# Creates a new StateStore
	#
	# @param [String] key the identifier for this resource's state
	def initialize key:, logger:
		@key = KEY_PREFIX + key
		@redis = Redis.current
		@logger = logger.with_fields log_fields
	end

	def get
		future { @redis.get @key }
			.then { |state| Oj.load state }
			.rescue { |reason| log_raise :error, :state_store_get_failure, reason }
	end

	def set state
		future { Oj.dump state }
			.then { |json| @redis.set @key, json }
			.rescue { |reason| log_raise :error, :state_store_set_failure, reason }			
	end

	def log_fields
		{ state_store: { key: @key } }
	end
end