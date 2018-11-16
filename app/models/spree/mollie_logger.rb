module Spree
  class MollieLogger
    def self.debug(message = nil)
      return unless message.present?

      @logger ||= Logger.new(File.join(Rails.root, 'log', 'mollie.log'))
      @logger.debug(message)
    end

    class << self
      attr_writer :logger
    end
  end
end
