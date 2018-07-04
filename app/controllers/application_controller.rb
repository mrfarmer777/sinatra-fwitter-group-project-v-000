require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "pickles"

  end

  get '/' do
    erb :home
  end

  #////////////TWEET ACTIONS///////////////

  get "/tweets/new" do
    if logged_in?
      erb :'tweets/new'
    else
      redirect "/users/login"
    end
  end

  get "/tweets" do
    if logged_in?
      @tweets=Tweet.all
      erb :"tweets/index"
    else
      redirect "/login"
    end
  end

  post "/tweets" do
    if logged_in? && !params[:content].empty?
      @user=current_user
      @tweet=Tweet.create(params)
      @tweet.user_id=@user.id
      @tweet.save
      redirect "/tweets/#{@tweet.id}"
    else
      redirect "tweets/new"
    end
  end

  get "/tweets/:id" do
    if logged_in?
      @tweet=Tweet.find(params[:id])
      erb :'tweets/show'
    else
      redirect "/login"
    end
  end

  get "/tweets/:id/edit" do
    if logged_in?
      @tweet=Tweet.find(params[:id])
      if current_user==@tweet.user
        erb :'tweets/edit'
      else
        redirect "/tweets"
      end
    else
      redirect "/login"
    end
  end

  patch "/tweets/:id" do
    if !params[:content].empty?
      @tweet=Tweet.find(params[:id])
      @tweet.update(content:params[:content])
      @tweet.save
      redirect "/tweets/#{@tweet.id}"
    else
      redirect "/tweets/#{params[:id]}/edit"
    end
  end

  delete "/tweets/:id/delete" do
    if logged_in?
      @tweet=Tweet.find(params[:id])
      if @tweet.user==current_user
        @tweet.destroy
      end
      redirect "/tweets"
    else
      redirect "/login"
    end
  end

  #////////////USER ACTIONS///////////////
  get "/signup" do
    #if they're already logged in, send them to /tweets
    if !logged_in?
      erb :'/users/signup'
    else
      redirect "/tweets"
    end
  end

  post "/signup" do
    if !params.any?{|param,value| value.empty?} #if NOT any parameters are empty
      @user=User.create(params) #create a new user objects
      @user.save
      session[:user_id]=@user.id
      redirect '/tweets'
    else
      redirect '/signup'
    end

  end

  get "/login" do
    if !logged_in?
      erb :'users/login'
    else
      redirect "/tweets"
    end
  end

  post "/login" do
    @user=User.find_by(username:params[:username])
    if @user && @user.authenticate(params[:password])
      session[:user_id]=@user.id
      redirect '/tweets'
    else
      redirect "/login"
    end
  end

  get "/logout" do
    if logged_in?
      session.delete(:user_id)
    end
    redirect "/login"
  end

  get "/users/:id" do
    @user=User.find(params[:id])
    @tweets=@user.tweets
    erb :'users/show'
  end





  #//////////////HELPER METHODS///////////////
  helpers do
          def logged_in?
            !!session[:user_id]
          end

          def current_user
            User.find(session[:user_id])
          end
  end


end
