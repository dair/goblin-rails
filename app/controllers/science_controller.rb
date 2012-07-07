# coding: utf-8

class ScienceController < ApplicationController
  @password_fail = false
  
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
  
  def main
    if (not session[:userid])
      redirect_to :action => "index"
      return
    end
    @username = session[:username]
    @subtitle = 'Список проектов'
    
    @projectlist = GoblinDb.getProjectsOwnedBy(session[:userid])
  end
  
  def header
    
  end
  
  def project_edit
    if (not session[:userid])
      redirect_to :action => "index"
      return
    end
    @username = session[:username]
    
    key = 0
    begin
      if (params[:key])
        key = Integer(params[:key])
      end
    rescue ArgumentError
      key = 0
    end
    
    if (key != 0)
      @project = Project.getItemByKey(key)
      @error = (@project == nil)
    else
      @project = Hash.new
      @project[:key] = 0
      @project[:name] = ""
      @project[:description] = ""
    end
    
  end
  
  def project_write
    if (not session[:userid])
      redirect_to :action => "index"
      return
    end
    
    item = Hash.new
    item[:id] = params[:id]
    item[:name] = params[:name]
    item[:description] = params[:description]
    
    Project.editItem(params[:id], params[:name], params[:description], session[:userid])
    
    redirect_to :action => "main"    
  end
end
