# frozen_string_literal: true

require 'json'
require 'puppet/util/puppetdb'
require 'puppet/network/http_pool'
# credit to dalen
# https://github.com/dalen/puppet-puppetdbquery/blob/master/lib/puppetdb/connection.rb
Puppet::Functions.create_function('knot::get_exported_titles') do
  dispatch :get_exported_titles do
    param 'Array', :imports
  end

  def get_exported_titles(imports)
    db_uri = URI(Puppet::Util::Puppetdb.config.server_urls.first)
    http = Puppet::Network::HttpPool.http_instance(
      db_uri.host, db_uri.port, db_uri.scheme == 'https'
    )
    headers = { 'Accept' => 'application/json' }
    query    = ['and', ['=', 'exported', true], ['~', 'tag', "(#{imports.join('|')})"]]
    uri      = '/pdb/query/v4/resources/Knot::Remote'
    uri      += URI.escape("?query=#{query.to_json}")
    begin
      response = http.get(uri, headers)
      if !response.is_a?(Net::HTTPSuccess)
        Puppet.warning(
          "unable to connect to the puppetdb, exported resources wont work: #{response.code}"
        )
        return []
      end
      return JSON.parse(response.body).map { |res| res['title'] }
    rescue => e
      Puppet.warning("Exception, exported resources wont work: #{e}")
    end
    []
  end
end
