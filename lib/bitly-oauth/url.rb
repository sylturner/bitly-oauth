module BitlyOAuth

  class Url
    attr_reader :short_url, :long_url, :user_hash, :global_hash, :referrers, :countries

    # Initialize with a bitly client and optional hash to fill in the details for the url.
    def initialize(client, options = {})
      @client        = client
      @new_hash      = options['new_hash'] == 1
      @long_url      = options['long_url']
      @created_by    = options['created_by']
      @global_hash   = options['global_hash']
      @user_clicks   = options['user_clicks']
      @global_clicks = options['global_clicks']
      @title         = options['title']
      @user_hash     = options['hash']            || options['user_hash']
      @short_url     = options['url']             || options['short_url'] || "http://bit.ly/#{@user_hash}"

      @referrers = options['referrers'].map do |referrer|
        BitlyOAuth::Referrer.new(referrer)
      end if options['referrers']

      @countries = options['countries'].map do |country|
        BitlyOAuth::Country.new(country)
      end if options['countries']

      if options['clicks'] && options['clicks'][0].is_a?(Hash)
        @clicks_by_day = options['clicks'].map do |day|
          BitlyOAuth::Day.new(day)
        end
      else
        @clicks_by_minute = options['clicks']
      end
    end

    # Returns true if the user hash was created first for this call
    def new_hash?
      @new_hash
    end

    # If the url already has click statistics, returns the user clicks.
    # IF there are no click statistics or <tt>:force => true</tt> is passed,
    # updates the stats and returns the user clicks
    def user_clicks(options={})
      update_clicks_data if @user_clicks.nil? || options[:force]
      @user_clicks
    end

    # If the url already has click statistics, returns the global clicks.
    # IF there are no click statistics or <tt>:force => true</tt> is passed,
    # updates the stats and returns the global clicks
    def global_clicks(options={})
      update_clicks_data if @global_clicks.nil? || options[:force]
      @global_clicks
    end

    # If the url already has the title, return it.
    # IF there is no title or <tt>:force => true</tt> is passed,
    # updates the info and returns the title
    def title(options={})
      update_info if @title.nil? || options[:force]
      @title
    end

    # If the url already has the creator, return it.
    # IF there is no creator or <tt>:force => true</tt> is passed,
    # updates the info and returns the creator
    def created_by(options={})
      update_info if @created_by.nil? || options[:force]
      @created_by
    end

    # If the url already has referrer data, return it.
    # IF there is no referrer or <tt>:force => true</tt> is passed,
    # updates the referrers and returns them
    def referrers(options={})
      if @referrers.nil? || options[:force]
        full_url = @client.referrers(@user_hash || @short_url)
        @referrers = full_url.referrers
      end
      @referrers
    end

    # If the url already has referring_domains data, return it.
    # IF there is no referring_domains or <tt>:force => true</tt> is passed,
    # updates the referring_domains and returns them
    def referring_domains(options={})
      if @referring_domains.nil? || options[:force]
        @referring_domains = @client.referring_domains(@short_url)
      end
      @referring_domains
    end

    # If the url already has country data, return it.
    # IF there is no country or <tt>:force => true</tt> is passed,
    # updates the countries and returns them
    def countries(options={})
      if @countries.nil? || options[:force]
        full_url = @client.countries(@user_hash || @short_url)
        @countries = full_url.countries
      end
      @countries
    end

    def clicks_by_minute(options={})
      if @clicks_by_minute.nil? || options[:force]
        full_url = @client.clicks_by_minute(@user_hash || @short_url)
        @clicks_by_minute = full_url.clicks_by_minute
      end
      @clicks_by_minute
    end

    def clicks_by_day(options={})
      if @clicks_by_day.nil? || options[:force]
        full_url = @client.clicks_by_day(@user_hash || @short_url)
        @clicks_by_day = full_url.clicks_by_day
      end
      @clicks_by_day
    end

    private

    def update_clicks_data
      full_url       = @client.clicks(@user_hash || @short_url)
      @global_clicks = full_url.global_clicks
      @user_clicks   = full_url.user_clicks
    end

    def update_info
      url         = @client.info(@user_hash || @short_url)
      @created_by = url.created_by
      @title      = url.title || ''
    end
  end
end
