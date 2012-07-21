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
      p = GoblinDb.getPerson(id)
      session[:username] = p["name"]
      session[:userstatus] = p["status"]
      
      if p["status"] == 'A'
        redirect_to :action => "main"
      elsif p["status"] == 'M'
        redirect_to :action => "master_main"
      end
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
