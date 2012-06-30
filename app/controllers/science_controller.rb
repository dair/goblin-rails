# coding: utf-8

class ScienceController < ApplicationController
  @password_fail = false
  
  def index
    if (session[:fail])
      @password_fail = true
      session[:fail] = nil
    end
  end
  
  def login
    id = params[:name]
    password = params[:password]
    
    ret = Money.check_credentials(id, password)
    
    if (ret)
      session[:userid] = id
      session[:username] = Person.getName(id)
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
    end
    @username = session[:username]
    @subtitle = 'Список проектов'
    @projectlist = ["11111", '22222', '33333']
  end
  
  def header
    
  end
end
