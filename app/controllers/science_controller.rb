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
  
###################################################################
  def main
    if (not session[:userid])
      redirect_to :action => "index"
      return
    end
    @username = session[:username]
    @subtitle = 'Список проектов'
    
    @projectlist = GoblinDb.getProjectsOwnedBy(session[:userid])
  end
  
###################################################################
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
    if (not session[:userid])
      redirect_to :action => "index"
      return
    end
    
    key = 0
    begin
      if (params[:key])
        key = Integer(params[:key])
      end
    rescue ArgumentError
      key = 0
    end
    
#    item = Hash.new
#    item[:id] = params[:id]
#    item[:name] = params[:name]
#    item[:description] = params[:description]
    
    leader_id = GoblinDb.getProjectLeader(key)
    if (leader_id != session[:userid])
      redirect_to :action => "main"
      return
    end
        
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
    
    if key == 0
      @error = true
    else
      @error = false
      @project = GoblinDb.getProjectInfo(key)
      if (@project)
        leader_id = GoblinDb.getProjectLeader(key)
        
        puts "----------------------------------------\n"
        puts session[:userid]
        puts "----------------------------------------\n"
        
        @editable = (leader_id == session[:userid])
        
        @members = ScienceController.membersArray(key)
      else
        @error = true
        @members = []
        @project = {}
        @editable = false  
      end 
    end
  end
  
  
########################################################################################
  def members_edit
    if (not session[:userid])
      redirect_to :action => "index"
      return
    end
    @username = session[:username]
    
    key = 0
    @error = false
    begin
      if (params[:key])
        key = Integer(params[:key])
        
        leader_id = GoblinDb.getProjectLeader(key)
        if (leader_id != session[:userid])
          redirect_to :action => "main"
          return
        end
        
        mems = GoblinDb.getProjectMembers(key)
        
        if (mems.size == 0)
          @error = true
        else
          @members = []
          for m in mems
            mi = MemberItem.new
            mi.set(m["id"], m["name"])
            @members.append(mi)
          end
        end
      end
    rescue ArgumentError
      key = 0
      @error = true
    end
    
    if not @error
      @project = {}
      @project["key"] = key
    end
  end
end
