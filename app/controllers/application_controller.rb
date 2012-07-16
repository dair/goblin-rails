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
    begin
      id = Integer(params[:name])
      password = params[:password]
    
      ret = GoblinDb.checkCredentials(id, password)
    rescue ArgumentError
      ret = false
    end
    
    if (ret)
      session[:userid] = id
      session[:username] = GoblinDb.getPersonName(id)
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
