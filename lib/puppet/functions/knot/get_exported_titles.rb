# frozen_string_literal: true

require 'net/http'
require 'json'

Puppet::Functions.create_function('knot::get_exported_titles') do
  dispatch :get_exported_titles do
    param 'String', :puppetdb_server
    param 'Integer', :puppetdb_port
    param 'String', :search_prefix
  end

  def get_exported_titles(puppetdb_server, puppetdb_port, search_prefix)
    resources = []
    http      = Net::HTTP.new(puppetdb_server, puppetdb_port)
    request   = Net::HTTP::Get.new('/pdb/query/v4/resources/Knot::Remote')
    begin
      response = http.request(request)
      if response.code != '200'
        Puppet.warning(
          "unable to connect to the #{puppetdb_server}:#{puppetdb_port}, exported resources wont work: #{response.code}"
        )
        return resources
      end
      scope = closure_scope
      response_json = JSON.parse(response.body)
      exported_resources = response_json.map do |resource|
        next unless resource['certname'] == scope['trusted']['certname'] &&
                    resource['title'] =~ %r{#{search_prefix}.+} &&
                    !resource['exported']
        resource['title']
      end
      resources = exported_resources.compact
    rescue => e
      Puppet.warning("Exception, exported resources wont work: #{e}")
    end
    resources
  end
end
