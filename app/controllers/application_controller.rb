class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def index
    if (session[:userid])
      redirect_to :action => 'main'
      return
    end
    
    if (session[:fail])
      @password_fail = true
      session[:fail] = nil
    end
  end
  
  def login
    id = params[:name]
    password = params[:password]
    
    ret = Money.checkCredentials(id, password)
    
    if (ret)
      session[:userid] = id
      session[:username] = Person.find(id).name
      redirect_to :action => "main"
    else
      session[:fail] = true
      session[:userid] = nil
      redirect_to :action => "index"
    end
  end
  
  def logout
    session[:userid] = nil
    session[:username] = nil
    redirect_to :action => "index"
  end

end
