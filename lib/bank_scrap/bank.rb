require 'mechanize'
require 'logger'

module BankScrap
  class Bank

    WEB_USER_AGENT = 'Mozilla/5.0 (Linux; Android 4.2.1; en-us; Nexus 4 Build/JOP40D) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.166 Mobile Safari/535.19'
    attr_accessor :headers, :accounts

    def initialize(user, password, log: false, debug: false, extra_args: nil)
      @accounts = fetch_accounts
    end

    # Interface method placeholders

    def fetch_accounts
      raise Exception.new "#{self.class} should implement a fetch_account method"
    end

    def fetch_transactions_for(account, start_date: Date.today - 1.month, end_date: Date.today)
      raise Exception.new "#{self.class} should implement a fetch_transactions method"
    end

    def account_with_iban(iban)
      accounts.find { |account| account.iban.gsub(' ','') == iban.gsub(' ','') }
    end

    private

    def get(url, params = {})
      @http.get(url, params).body
    end

    def post(url, fields)
      @http.post(url, fields, @headers).body
    end

    def put(url, fields)
      @http.put(url, fields, @headers).body
    end

    # Sets temporary HTTP headers, execute a code block
    # and resets the headers
    def with_headers(tmp_headers)
      current_headers = @headers
      set_headers(tmp_headers)
      yield
    ensure
      set_headers(current_headers)
    end


    def set_headers(headers)
      @headers.merge! headers
      @http.request_headers = @headers
    end


    def initialize_cookie(url)
      @http.get(url).body
    end

    def initialize_connection
      @http = Mechanize.new do |mechanize|
        mechanize.user_agent = WEB_USER_AGENT
        mechanize.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        mechanize.log = Logger.new(STDOUT) if @debug
        # mechanize.set_proxy 'localhost', 8888
      end

      @headers = {}
    end

    def log(msg)
      puts msg if @log
    end
  end
end
