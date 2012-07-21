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
  
  def failProjectViewPermission(key)
    members = GoblinDb.getProjectMembers(id0(key))
    ret = true
    for m in members
      if m["id"] == session[:userid]
        ret = false
      end
    end
    
    if (ret)
      addError("Недостаточно прав для просмотра данного проекта")
      redirect_to :action => "main"
    end
    
    return ret
  end
  
  def failProjectEditPermission(key)
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
    @projectlist = GoblinDb.getProjectsPersonIn(session[:userid])
  end
  
###################################################################
  def project_new
    if failLogin()
      return
    end
    
    @project = Hash.new
    @project["key"] = 0
    @project["name"] = ""
    @project["description"] = ""
    render "project_edit"
  end
  
###################################################################
  def project_edit
    key = id0(params[:key])
    if failLogin() or failProjectEditPermission(key)
      return
    end
    
    @project = GoblinDb.getProjectInfo(key) 
    @error = (@project == nil)
  end
  
###################################################################
  def project_write
    key = id0(params[:key])
    
    if failLogin() or (key != 0 and failProjectEditPermission(key))
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
    key = id0(params[:key])
    if failLogin() or failProjectViewPermission(key)
      return
    end
    
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
      
      @research_list = GoblinDb.getProjectResearchList(key)
      for research in @research_list
        id = id0(research["id"])
        team = GoblinDb.getResearchTeam(id)
        team_names = team.map { |i| i["name"] }.join(", ")
        research["members"] = team_names
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
    if failLogin() or failProjectEditPermission(params[:key])
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
  
  def members_action
    if failLogin() or failProjectEditPermission(params[:key])
      return
    end

    key = id0(params[:key])
    person_id = id0(params[:list])

    if (params[:method] == "delete")
      members_delete(key, person_id)
    elsif (params[:method] == "pass")
      members_pass(key, person_id)
    end
  end
  
########################################################################################
  def members_delete(key, person_id)
    if (key > 0 and person_id > 0)
      GoblinDb.removePersonFromProject(person_id, key)
    end
    redirect_to :action => "members_edit", :key => params[:key]
  end
  
  def members_pass(key, person_id)
    if (key > 0 and person_id > 0)
      GoblinDb.passLeadershipToPersonForProject(person_id, key)
    end
    redirect_to :action => "project_info", :key => params[:key]
  end
  
  def members_add
    if failLogin() or failProjectEditPermission(params[:key])
      return
    end
    
    key = id0(params[:key])
    
    person = GoblinDb.findPerson(params[:name])
    
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
        GoblinDb.addPersonToProjectTeam(person["id"], key)
      end
    end
    
    redirect_to :action => "members_edit", :key => params[:key]
  end
  
##################################################################################
  def research_info
    if failLogin()
      return
    end
    id = id0(params[:id])
    research = GoblinDb.getResearchInfo(id)
    if (research == nil)
      addError("Такого исследования не существует")
      return
    end
    
    key = id0(research["project_key"])
    if failLogin() or failProjectViewPermission(key)
      return
    end
    
    @research = research
    team = GoblinDb.getResearchTeam(id)
    @members = []
    member_ids = []
    for t in team
      member_ids.append(t["id"])
      @members.append(t["name"])
    end
    
    leader_id = GoblinDb.getProjectLeader(key)
    @editable = (leader_id == session[:userid] and research["status"] == 'A')
    @addable = (member_ids.index(session[:userid]) != nil) and (research["status"] == 'S')
    @project = GoblinDb.getProjectInfo(key)
    
    @entries = GoblinDb.getResearchEntries(id)
  end
  
##################################################################################
  def research_edit
    id = id0(params[:id])
    if failLogin()
      return
    end
    research = GoblinDb.getResearchInfo(id)
    puts '-----------------------------------------------------'
    puts research
    puts '-----------------------------------------------------'
    
    key = 0
    if (research != nil)
      key = research["project_key"]
    end
    puts key
    if failProjectEditPermission(key)
      return
    end
    
    if research["status"] != "A"
      addError("Редактирование свойств исследования возможно только на этапе подготовки")
      redirect_to :action => "research_info", :id => id, :key => key
      return
    end
    
    @research = research
  end

##################################################################################
  def research_new
    key = id0(params[:key])
    if failLogin() or failProjectEditPermission(key)
      return
    end
    
    @research = Hash.new
    @research["id"] = 0
    @research["project_key"] = key
    @research["name"] = ""
    @research["description"] = ""
    render "research_edit"
  end
  
##################################################################################
  def research_write
    id = id0(params[:id])
    key = id0(params[:project_key])
    
    if failLogin()
      return
    end
    
    if id != 0
      research = GoblinDb.getResearchInfo(id)
      if research == nil or research["project_key"] != key
        addError("Такого исследования не существует")
        redirect_to :action => "project_info", :key => research["project_key"]
        return
      end
      if research["status"] != "A"
        addError("Редактирование свойств исследования возможно только на этапе подготовки")
        redirect_to :action => "research_info", :id => id, :key => key
      return
    end

    end
    if failProjectEditPermission(key)
      return
    end
    
    GoblinDb.setResearchData(id, key, params[:name], params[:description])
    if (id != 0)
      redirect_to :action => "research_info", :id => id, :project_key => key
    else
      redirect_to :action => "project_info", :key => key
    end
  end
  
##################################################################################
  def research_members_edit
    if failLogin()
      return
    end
    id = id0(params[:id])
    research = GoblinDb.getResearchInfo(id)
    key = 0
    if (research != nil)
      key = research["project_key"]
    end
    if failProjectEditPermission(key)
      return
    end
    
    team = GoblinDb.getResearchTeam(id)
    @research_members = Array.new
    for p in team
      info = MemberItem.new
      info.set(p["id"], p["name"])
      @research_members.append(info)
    end
    
    @research = research
    
    project_team = GoblinDb.getProjectMembers(key)
    for m in team
      index = project_team.index{|x|x["id"] == m["id"]}
      if index != nil
        project_team.delete_at(index) 
      end
    end
    
    @project_members = []
    for i in project_team
      info = MemberItem.new
      info.set(i["id"], i["name"])
      @project_members.append(info)
    end
  end
  
##################################################################################
  def research_members_action
    if failLogin()
      return
    end
    id = id0(params[:id])
    research = GoblinDb.getResearchInfo(id)
    key = 0
    if (research != nil)
      key = research["project_key"]
    end
    if failProjectEditPermission(key)
      return
    end
    
    new_team = params["research_list"]
    for t in new_team
      t = id0(t)
    end
    GoblinDb.setResearchTeam(id, new_team)
    
    redirect_to :action => "research_info", :id => id, :key => key
  end

##################################################################################
  def research_submit
    if failLogin()
      return
    end
    id = id0(params[:id])
    research = GoblinDb.getResearchInfo(id)
    key = 0
    if (research != nil)
      key = research["project_key"]
    end
    if failProjectEditPermission(key)
      return
    end
    
    GoblinDb.setResearchStatus(id, 'P')
    redirect_to :action => "research_info", :id => id, :key => key
  end
  
##################################################################################
  def research_finance
    if failLogin()
      return
    end
    id = id0(params[:id])
    research = GoblinDb.getResearchInfo(id)
    key = 0
    if (research != nil)
      key = research["project_key"]
    end
    if failProjectEditPermission(key)
      return
    end
    
    
    redirect_to :action => "research_info", :id => id, :key => key
  end
end
