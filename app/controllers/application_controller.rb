# coding: utf-8

class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def setDefaultVars
    if (flash[:last_error])
      @last_error = flash[:last_error].join(", ")
    end
    @username = session[:username]
  end
  
  def render(options = nil, extra_options = {}, &block)
    setDefaultVars()
    super(options, extra_options, &block)
  end
  
  def addError(error)
    if !flash[:last_error]
      flash[:last_error] = []
    end
    flash[:last_error].append(error)
  end
  
  def id0(id)
    key = 0
    begin
      if (id)
        key = Integer(id)
      end
    rescue ArgumentError
      key = 0
    end
    return key
  end
  
  def failLogin
    if (not session[:userid])
      addError("Вход не выполнен")
      redirect_to :action => "index"
      return true
    end
    return false
  end
  
  def index
    if (session[:userid])
      if session[:userstatus] == 'A'
        redirect_to :controller => "science", :action => "main"
      elsif session[:userstatus] == 'M'
        redirect_to :controller => "master", :action => "main"
      end
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
        redirect_to :controller => "science", :action => "main"
      elsif p["status"] == 'M'
        redirect_to :controller => "master", :action => "main"
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

###################################################################
  def self.membersArray(key)
    team = GoblinDb.getProjectMembers(key)
    leader = nil
    members = Array.new
    for member in team
      if member["status"] == "L"
        leader = member["name"]
      else
        members.append(member["name"])
      end
    end
    members = members.sort
    if leader != nil
      members.prepend(leader)
    end
    
    return members
  end
  
  def self.researchMembersArray(id)
    team = GoblinDb.getResearchTeam(id)
    members = []
    for member in team
      members.append(member["name"])
    end
    
    return members
  end
  

end
