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
  
  
  def failProjectEditPermission(key)
    if (session[:userstatus] == 'M')
      return false
    end
    
    leader_id = GoblinDb.getProjectLeader(id0(key))
    if (leader_id != session[:userid]) 
      addError("Недостаточно прав для редактирования данного проекта")
      redirect_to :action => "my_projects"
      return true
    end
    
    return false
  end
  
###################################################################
  def main
    if failLogin()
      return
    end
    
    @subtitle = 'Список проектов'
    @projectlist = GoblinDb.getProjects()
  end

###################################################################
  def my_projects
    if failLogin()
      return
    end
    
    @subtitle = 'Список моих проектов'
    @projectlist = GoblinDb.getProjectsPersonIn(session[:userid])
  end
  
###################################################################
  def project_new
    if failLogin()
      return
    end
    @subtitle = 'Новый проект'
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
    
    @subtitle = 'Редактирование проекта'
    @project = GoblinDb.getProjectInfo(key) 
    @error = (@project == nil)
  end
  
###################################################################
  def project_write
    key = id0(params[:key])
    
    if failLogin() or (key != 0 and failProjectEditPermission(key))
      return
    end
    
    key = GoblinDb.editProject(key, params[:name], params[:description], session[:userid])
    
    redirect_to :action => "project_info", :key => key    
  end
  
###################################################################
  def project_info
    key = id0(params[:key])
    if failLogin()
      return
    end
    
    @subtitle = 'Информация о проекте'
    if key == 0
      @error = true
    else
      @error = false
      @project = GoblinDb.getProjectInfo(key)
      if (@project)
        leader_id = GoblinDb.getProjectLeader(key)
        
        @editable = (leader_id == session[:userid])
        @project["members"] = ScienceController.membersArray(key)
      end
      
      @research_list = GoblinDb.getProjectResearchList(key)
      for research in @research_list
        id = id0(research["id"])
        team = ApplicationController.researchMembersArray(id)
        team_names = team.join(", ")
        research["members"] = team_names
      end
    end
    
    if @error
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
    @subtitle = 'Участники проекта'
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
    if failLogin()
      return
    end
    
    @research = research
    team = GoblinDb.getResearchTeam(id)
    @research["members"] = []
    member_ids = []
    for t in team
      member_ids.append(t["id"])
      @research["members"].append(t["name"])
    end
    
    leader_id = GoblinDb.getProjectLeader(key)
    @editable = (leader_id == session[:userid] and research["status"] == 'A')
    @addable = (member_ids.index(session[:userid]) != nil) and (research["status"] == 'S')
    @project = GoblinDb.getProjectInfo(key)
    
    @entries = GoblinDb.getResearchEntries(id)
    @subtitle = 'Исследование'

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
    @subtitle = 'Редактирование данных исследования'
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
    @subtitle = 'Новое исследование'
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
    
    @subtitle = 'Участники исследования'
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
    
    begin
      bablo = Integer(params[:balance])
    rescue ArgumentError
      bablo = 0
    end
    
    bablo = bablo.abs
    
    if (bablo + research["balance"] >= 0)
      GoblinDb.financeResearch(id, bablo)
      GoblinDb.setResearchStatus(id, 'S')
    end
    
    redirect_to :action => "research_info", :id => id, :key => key
  end
  
##################################################################################
  def research_add_entry
    id = id0(params[:id])
    if failLogin()
      return
    end
    
    research = GoblinDb.getResearchInfo(id)
    team = GoblinDb.getResearchTeam(id)
    key = 0
    if (research != nil)
      key = research["project_key"]
    end
    
    if research["status"] != "S"
      addError("Добавление записей возможно только на этапе работы")
      redirect_to :action => "research_info", :id => id, :key => key
      return
    end
    if team.map{|x| x["id"]}.index(session[:userid]) == nil
      addError("Добавление записей возможно только для участников исследования")
      redirect_to :action => "research_info", :id => id, :key => key
      return
    end
    
    @research = research
    @subtitle = 'Добавление хода исследования'
  end
  
  def research_entry_write
    id = id0(params[:id])
    if failLogin()
      return
    end
    
    research = GoblinDb.getResearchInfo(id)
    team = GoblinDb.getResearchTeam(id)
    
    key = 0
    if (research != nil)
      key = research["project_key"]
    end
    
    if research["status"] != "S"
      addError("Добавление записей возможно только на этапе работы")
      redirect_to :action => "research_info", :id => id, :key => key
      return
    end
    if team.map{|x| x["id"]}.index(session[:userid]) == nil
      addError("Добавление записей возможно только для участников исследования")
      redirect_to :action => "research_info", :id => id, :key => key
      return
    end
    
    GoblinDb.addResearchEntry(id, session[:userid], params[:entry])
    redirect_to :action => "research_info", :id => id, :key => key
  end
  
  def asset_return
    key = id0(params[:key])
    if failLogin() or failProjectEditPermission(key)
      return
    end
    
    @project = GoblinDb.getProjectInfo(key) 
    @error = (@project == nil)
    @subtitle = 'Возврат излишних средств'
  end
  
  def asset_return_write
    key = id0(params[:key])
    if failLogin() or failProjectEditPermission(key)
      return
    end
    @project = GoblinDb.getProjectInfo(key) 
    
    amount = id0(params[:amount])
    account = id0(params[:account])
    
    if amount <= 0 or amount > @project["money"]
      addError("Ошибочная сумма")
      redirect_to :action => "asset_return", :key => key
      return
    end
    
    person = GoblinDb.getPerson(account)
    if (person == nil)
      addError("Ошибочный номер счёта")
      redirect_to :action => "asset_return", :key => key
      return
    end
    
    GoblinDb.stealMoney(key, account, amount)
    redirect_to :action => "project_info", :key => key
  end
  
end
