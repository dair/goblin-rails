# coding: utf-8

class MemberItem
  def id
    return @id
  end
  
  def name
    return @name
  end
  
  def set(id, name)
    @id = id
    @name = name
  end
end

class ScienceController < ApplicationController
  @password_fail = false
  
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
    @username = session[:username]
    return false
  end
  
  def failProjectPermission(key)
    leader_id = GoblinDb.getProjectLeader(id0(key))
    if (leader_id != session[:userid])
      addError("Недостаточно прав для редактирования данного проекта")
      redirect_to :action => "main"
      return true
    end
    
    return false
  end
  
  def setDefaultVars
    if (flash[:last_error])
      @last_error = flash[:last_error].join(", ")
    end
    
    puts "=========================================================="
    puts @last_error
    puts "=========================================================="
  end
  
  def render(options = nil, extra_options = {}, &block)
    setDefaultVars()
    super(options, extra_options, &block)
  end
  
###################################################################
  def main
    if failLogin()
      return
    end
    
    @subtitle = 'Список проектов'
    @projectlist = GoblinDb.getProjectsOwnedBy(session[:userid])
  end
  
###################################################################
  def project_edit
    if failLogin() or failProjectPermission(params[:key])
      return
    end
    
    key = id0(params[:key])
    
    if (key != 0)
      @project = GoblinDb.getProjectInfo(key) 
      @error = (@project == nil)
    else
      @project = Hash.new
      @project[:key] = 0
      @project[:name] = ""
      @project[:description] = ""
    end
  end
  
###################################################################
  def project_write
    if failLogin() or failProjectPermission(params[:key])
      return
    end
    
    key = id0(params[:key])
    
    GoblinDb.editProject(key, params[:name], params[:description], session[:userid])
    
    redirect_to :action => "main"    
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
  
###################################################################
  def project_info
    if failLogin()
      return
    end
    
    key = id0(params[:key])
    
    if key == 0
      @error = true
    else
      @error = false
      @project = GoblinDb.getProjectInfo(key)
      if (@project)
        leader_id = GoblinDb.getProjectLeader(key)
        
        @editable = (leader_id == session[:userid])
        @members = ScienceController.membersArray(key)
      end
    end
    
    if @error
      @members = []
      @project = {}
      @editable = false  
    end 
  end
  
########################################################################################
  def members_edit
    if failLogin() or failProjectPermission(params[:key])
      return
    end
    
    key = id0(params[:key])
    @error = false
    
    mems = GoblinDb.getProjectMembers(key)
    if (mems.size == 0)
      @error = true
    else
      mems = mems[1..mems.size]
      @members = []
      for m in mems
        mi = MemberItem.new
        mi.set(m["id"], m["name"])
        @members.append(mi)
      end
    end
    
    if not @error
      @project = {}
      @project["key"] = key
    end
  end
  
########################################################################################
  def members_delete
    if failLogin() or failProjectPermission(params[:key])
      return
    end
    
    key = id0(params[:key])
    person_id = id0(params[:list])
    puts key
    puts person_id
    
    if (key > 0 and person_id > 0)
      GoblinDb.removePersonFromProject(person_id, key)
    end
    redirect_to :action => "members_edit", :key => params[:key]
  end
  
  def members_add
    if failLogin() or failProjectPermission(params[:key])
      return
    end
    
    key = id0(params[:key])
    
    puts "===================================================================="
    person = GoblinDb.findPerson(params[:name])
    puts person
    
    if person == nil
      addError("Такой пользователь не найден")
    else
      mems = GoblinDb.getProjectMembers(key)
      inTeam = false
      for m in mems
        if m["id"] == person["id"]
          inTeam = true
          break
        end
      end
      
      if inTeam
        addError("Такой пользователь уже в команде")
      else
        puts "adding " + String(key) + " to " + String(person["id"])
        GoblinDb.addPersonToProjectTeam(person["id"]. key)
      end
    end
    puts "===================================================================="
    puts flash[:last_error]
    puts "===================================================================="
    
    redirect_to :action => "members_edit", :key => params[:key]
  end
end
