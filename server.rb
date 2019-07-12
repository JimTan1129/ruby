require "sinatra"
require "sinatra/activerecord"


# ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: './database.sqlite3')

if ENV['RACK_ENV']
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
else
  set :database, {adapter: "sqlite3", database: "database.sqlite3"}
end

enable :sessions


class Category < ActiveRecord::Base
  self.table_name = 'categories'
end


class User < ActiveRecord::Base
  attr_accessor :birthday
end

get '/' do
  if session[:user_id]
    redirect "/feed"
  else
    erb :home
  end
end

get '/signup' do
  @user = User.new
  erb :signup
end

post "/signup" do
  @user = User.new(params)
  if @user.save
    p "#{@user.first_name} was saved to the database"
    redirect "/thanks"
  end
end


get "/users" do
  erb :users
end


get "/thanks" do
  erb :thanks
end

get '/login' do
  if session[:user_id]
    redirect "/feed"
  else
    erb :login
  end
end

post "/login" do
  given_password = params['password']
  user = User.find_by(email: params['email'])
  if user
    if user.password == given_password
      p "User authenticated succesfuly"
      session[:user_id] = user.id
      redirect "/feed"
    else
      p "Wrong password entered"
      redirect "/login"
    end
  end
end

get "/feed" do
  erb :feed
end

post "/logout" do
  session.clear
  p "You have been logged out"
end
