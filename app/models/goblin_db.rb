class GoblinDb < ActiveRecord::Base
  
  def self.getProjectsOwnedBy(id)
    rows = connection.select_all(%Q{select p.key, p.name, p.description from project p, project_team t 
      where t.person_id = #{sanitize(id)} and t.status='L' and p.status='A' and t.project_key = p.key})
    
    for row in rows
      row["key"] = Integer(row["key"])
    end
    
    return rows
  end
end

