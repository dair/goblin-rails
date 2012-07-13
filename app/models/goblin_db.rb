class GoblinDb < ActiveRecord::Base
  
  def self.getProjectsOwnedBy(id)
    rows = connection.select_all(%Q{select p.key, p.name, p.description from project p, project_team t 
      where t.person_id = #{sanitize(id)} and t.status='L' and p.status='A' and t.project_key = p.key})
    
    for row in rows
      row["key"] = Integer(row["key"])
    end
    
    return rows
  end
  
  def self.getProjectMembers(key)
    rows = connection.select_all(%Q{select p.id, p.name from person p, project_team t 
      where t.project_key = #{sanitize(key)} and
      t.person_id = p.id and
      t.status = 'A'})

    for row in rows
      row["id"] = Integer(row["id"])
    end
    
    return rows
  end
  
  def self.findPerson(personName)
    personId = 0
    begin
      personId = Integer(personName)
    rescue ArgumentError
      personId = 0
    end
    
    rows = []
    if (personId != 0)
      rows = connection.select_all(%Q{select id, name from person where id = #{sanitize(personId)}})
    end
    
    if (rows.size > 0)
      return rows[0]
    end
    
    rows = connection.select_all(%Q{select id, name from person where name = #{sanitize(personName)}})
    if (rows.size > 0)
      return rows[0]
    end
    
    return nil
  end
end

