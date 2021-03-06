require 'sinatra'
require 'securerandom'
require './security'

include ERB::Util

#set :erubis, :escape_html => true

get '/' do
  erb :payment_form
end

post '/payment_confirmation' do

  if params['signed_date_time'].to_s.size == 0
    params.store 'signed_date_time', Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ')
  end

  if params['access_key'].to_s.size > 0
    params.store 'signature', Security.generate_signature(params)
  end

  erb :payment_confirmation
end

post '/receipt' do
  @signature_valid = Security.valid? params
  erb :receipt
end

post '/backoffice' do
  puts "Backoffice POST notification received: #{params}"
end
