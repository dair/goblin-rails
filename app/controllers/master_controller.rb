# coding: utf-8

class MasterController < ApplicationController
  def failMaster
    if (session[:userstatus] == 'M')
      return false
    end
    
    addError("Недостаточно прав")
    redirect_to :action => "my_projects"
    return true
  end
  
  def main
    if failLogin() or failMaster()
      return
    end
    @subtitle = "Исследования к рассмотрению"

    rows = GoblinDb.getResearchListForMaster()
    @research_list = rows
  end
  
  def review
    if failLogin() or failMaster()
      return
    end
    @subtitle = "Информация об исследовании"

    id = id0(params[:id])
    research = GoblinDb.getResearchInfo(id)
    @project = GoblinDb.getProjectInfo(research["project_key"])
    @project["members"] = MasterController.membersArray(research["project_key"])
    
    reslist = GoblinDb.getProjectResearchList(research["project_key"])
    @research_list = []
    for r in reslist
      @research_list.append(GoblinDb.getResearchInfo(r["id"]))
    end
  end
  
  def review_research
    if failLogin() or failMaster()
      return
    end
    @subtitle = "Принять решение по исследованию"
    id = id0(params[:id])
    @research = GoblinDb.getResearchInfo(id)
  end
  
  def review_research_write
    if failLogin() or failMaster()
      return
    end
    id = id0(params[:id])
    
    if (params[:is_ok] == "ok")
      price = 0
      begin
        price = Integer(params[:price])
      rescue ArgumentError
        price = 0
      end
      
      if price != 0
        GoblinDb.setResearchPriceAndStatus(id, price)
        
        if (params[:comment].strip.length > 0)
          GoblinDb.addResearchEntry(id, session[:userid], params[:comment])
        end
        
        redirect_to :action => "review", :id => id
      else
        addError("С ценой что-то не то, надо проверить ещё раз")
        redirect_to :action => "review_research", :id => id
        return
      end
      
      
      
    elsif (params[:is_ok] == "not_ok")
      GoblinDb.addResearchEntry(id, session[:userid], params[:comment])
      GoblinDb.setResearchStatus(id, 'A')
      redirect_to :action => "review", :id => id
    else
      addError("Чо-то не то")
      redirect_to :action => "review_research", :id => id
      return
    end
  end
  
end
