require 'mondo'

module MonzoMap
  class Client
    def initialize(access_token:, account_id:)
      @monzo = Mondo::Client.new(token: access_token, account_id: account_id)
    end

    def balance
      balance = monzo.balance['balance']
      "£#{balance / 100}"
    end

    def points
      monzo.transactions(expand: [:merchant]).map do |tr|
        [tr.merchant.address.latitude, tr.merchant.address.longitude] if tr.merchant
      end.compact
    end

    private

    def monzo
      @monzo
    end
  end
end


