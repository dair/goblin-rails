class GoblinDb < ActiveRecord::Base
  
  def self.checkCredentials(id, passwd)
    rows = connection.select_all(%Q{select pin from money where id = #{sanitize(id)}})
    if (rows.size == 1)
      return passwd == rows[0]["pin"]
    end
    
    return false
  end
  
  def self.getPersonName(id)
    rows = connection.select_all(%Q{select name from person where id = #{sanitize(id)}})
    if (rows.size == 1)
      return rows[0]["name"]
    end
    
    return ""
  end
  
  def self.getProjectsOwnedBy(id)
    rows = connection.select_all(%Q{select p.key, p.name, p.description from project p, project_team t 
      where t.person_id = #{sanitize(id)} and t.status='L' and p.status='A' and t.project_key = p.key})
    
    for row in rows
      row["key"] = Integer(row["key"])
    end
    
    return rows
  end
  
  def self.getProjectMembers(key)
    rows = connection.select_all(%Q{select p.id, p.name, t.status from person p, project_team t 
      where t.project_key = #{sanitize(key)} and
      t.person_id = p.id and
      t.status in ('A', 'L') order by t.status desc, p.name asc})

    for row in rows
      row["id"] = Integer(row["id"])
    end
    
    return rows
  end
  
  def self.getProjectLeader(key)
    rows = connection.select_all(%Q{select person_id from project_team where project_key = #{sanitize(key)} and status = 'L'})
    if (rows.size != 1)
      return 0
    end
    return Integer(rows[0]["person_id"])
  end
  
  def self.getProjectInfo(key)
    rows = connection.select_all(%Q{select id, key, name, description, money from project where key = #{sanitize(key)} and status = 'A' order by created_at desc})
    if (rows.size == 1)
      row = rows[0]
      row["money"] = Integer(row["money"])
    end
    return row
  end

  def self.generateKey()
    found = true
    key = 0
    begin
      key = rand(10000000..99999999)
      
      rows = connection.select_all(%Q{select key from project_key where key = #{sanitize(key)}})
      
      found = (rows.size > 0)
    end while found
    
    connection.insert("INSERT INTO project_key (key) values (#{key})")
    
    return key
  end


  def self.editProject(key, name, description, personId)
    transaction do
      money = 0
      if (key > 0)
        r = getProjectInfo(key)
        if (r != nil)
          money = r["money"]
        end
      end
      
      connection.update(%Q{update project set status = 'H' where key=#{sanitize(key)}})
      
      newProject = false
      if (key == 0)
        key = generateKey()
        newProject = true
      end
      
      connection.insert(%Q{insert into project (key, name, description, money, status, created_at, updated_at)
                           values (#{sanitize(key)}, #{sanitize(name)}, #{sanitize(description)}, #{sanitize(money)}, 'A', now(), now())})
      
      if newProject
        connection.insert(%Q{insert into project_team (project_key, person_id, status, created_at, updated_at)
          values (#{sanitize(key)}, #{sanitize(personId)}, 'L', now(), now())})
      end
    end
  end

###############################################################################  
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
    
    if (rows.size == 0)
      rows = connection.select_all(%Q{select id, name from person where name = #{sanitize(personName)}})
    end
    
    if rows.size > 0
      rows[0]["id"] = Integer(rows[0]["id"])
      return rows[0]
    end
    
    return nil
  end

###############################################################################  
  def self.addPersonToProjectTeam(person_id, key)
    connection.insert("INSERT INTO project_team (project_key, person_id, status, created_at, updated_at)
                        values (#{sanitize(key)}, #{sanitize(person_id)}, 'A', now(), now())")
  end  

  def self.removePersonFromProject(person_id, key)
    connection.update("UPDATE project_team set status='H', updated_at = now() where
                       project_key = #{sanitize(key)} and person_id = #{sanitize(person_id)}")
  end
  
  def self.passLeadershipToPersonForProject(person_id, key)
    transaction do
      connection.update("UPDATE project_team set status='A', updated_at = now() where
                         project_key = #{sanitize(key)} and status='L'")
      connection.update("UPDATE project_team set status='L', updated_at = now() where
                         project_key = #{sanitize(key)} and person_id = #{sanitize(person_id)} and status='A'")
    end
  end  
end

