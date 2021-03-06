class GoblinDb < ActiveRecord::Base
  
  def self.checkCredentials(id, passwd)
    rows = connection.select_all(%Q{select pin from money where id = #{sanitize(id)}})
    if (rows.size == 1)
      return passwd == rows[0]["pin"]
    end
    
    return false
  end
  
  def self.getPerson(id)
    rows = connection.select_all(%Q{select name, status from person where id = #{sanitize(id)}})
    if (rows.size == 1)
      return rows[0]
    end
    
    return nil
  end
  
  def self.getProjects
    rows = connection.select_all(%Q{select p.key, p.name, p.description, l.id as leader_id, l.name as leader from project p, project_team t, person l where p.status='A' and t.project_key = p.key and t.person_id = l.id and t.status = 'L' order by p.key asc})
    
    for row in rows
      row["key"] = Integer(row["key"])
      key = row["key"]
      row["leader_id"] = Integer(row["leader_id"])
      cnt = connection.select_all("select count(*) from research where project_key = #{key}")
      row["research_count"] = Integer(cnt[0]["count"])
    end
    
    return rows
  end
  
  def self.getProjectsOwnedBy(id)
    rows = connection.select_all(%Q{select p.key, p.name, p.description, p.money from project p, project_team t 
      where t.person_id = #{sanitize(id)} and p.status = 'A' and t.status='L' and t.project_key = p.key order by key asc})
    
    for row in rows
      row["key"] = Integer(row["key"])
      row["money"] = Integer(row["money"])
    end
    
    return rows
  end
  
  def self.getProjectsPersonIn(id)
    rows = connection.select_all(%Q{select p.key, p.name, p.description, p.money from project p, project_team t 
      where t.person_id = #{sanitize(id)} and t.status in ('A', 'L') and p.status='A' and t.project_key = p.key order by key asc})
    
    for row in rows
      row["key"] = Integer(row["key"])
      row["money"] = Integer(row["money"])
    end
    
    return rows
  end
  
  def self.getProjectMembers(key)
    rows = connection.select_all(%Q{select p.id, p.name, t.status from person p, project_team t 
      where t.project_key = #{sanitize(key)} and
      t.person_id = p.id and
      p.status = 'A' and
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

  def self.sixCount(key)
      k = key
      six_count = 0
      while k > 0
        digit = k % 10
        if digit == 6
          six_count = six_count + 1
        end
        k = k / 10
      end
      return six_count
  end

  def self.generateKey()
    found = true
    key = 0
    begin
      key = rand(10000000..99999999)
      if sixCount(key) > 2
        found = false
      else
        rows = connection.select_all(%Q{select key from project_key where key = #{sanitize(key)}})
        found = (rows.size > 0)
      end
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
      
      return key
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
      rows = connection.select_all(%Q{select id, name from person where id = #{sanitize(personId)} and status='A'})
    end
    
    if rows.length != 0
      person_found = rows[0]
    else
      upname = personName.mb_chars.upcase.to_s
      
      rows = connection.select_all(%Q{select id, name from person where status='A'})
      for row in rows
        name = row["name"].mb_chars.upcase.to_s
        if name == upname
          person_found = row
          break
        end
      end
    end
    
    if person_found
      person_found["id"] = Integer(person_found["id"])
    end
    
    return person_found
  end

###############################################################################  
  def self.addPersonToProjectTeam(person_id, key)
    connection.insert("INSERT INTO project_team (project_key, person_id, status, created_at, updated_at)
                        values (#{sanitize(key)}, #{sanitize(person_id)}, 'A', now(), now())")
  end  

###############################################################################  
  def self.removePersonFromProject(person_id, key)
    connection.update("UPDATE project_team set status='H', updated_at = now() where
                       project_key = #{sanitize(key)} and person_id = #{sanitize(person_id)}")
  end
  
###############################################################################  
  def self.passLeadershipToPersonForProject(person_id, key)
    transaction do
      connection.update("UPDATE project_team set status='A', updated_at = now() where
                         project_key = #{sanitize(key)} and status='L'")
      connection.update("UPDATE project_team set status='L', updated_at = now() where
                         project_key = #{sanitize(key)} and person_id = #{sanitize(person_id)} and status='A'")
    end
  end
  
###############################################################################  
  def self.getProjectResearchList(key)
    rows = connection.select_all(%Q{select id, balance, name, status from research where project_key = #{sanitize(key)} order by name asc})
    for row in rows
      row["id"] = Integer(row["id"])
      row["balance"] = Integer(row["balance"])
    end
    
    return rows
  end

###############################################################################  
  def self.getResearchInfo(id)
    rows = connection.select_all(%Q{select id, project_key, balance, name, description, status from research where id = #{sanitize(id)}})
    
    if (rows.size == 1)
      rows[0]["id"] = Integer(rows[0]["id"])
      rows[0]["project_key"] = Integer(rows[0]["project_key"])
      rows[0]["balance"] = Integer(rows[0]["balance"])
      return rows[0]
    end
    return nil
  end
  
  def self.getResearchTeam(id)
    rows = connection.select_all(%Q{select p.id, p.name from research_team r, person p where r.person_id = p.id and r.status = 'A' and p.status = 'A' and r.research_id = #{sanitize(id)} order by p.name asc})
    for row in rows
      row["id"] = Integer(row["id"])
    end
    return rows
  end
  
  def self.setResearchData(id, key, name, description)
    if id == 0
      connection.insert(%Q{insert into research (project_key, name, description, status, created_at, updated_at)
        values (#{sanitize(key)}, #{sanitize(name)}, #{sanitize(description)}, 'A', now(), now() ) })
    else
      connection.update("update research set name = #{sanitize(name)}, description = #{sanitize(description)}, updated_at = now() where id = #{sanitize(id)}")
    end
  end
  
  def self.setResearchTeam(id, new_team)
    current_team_obj = getResearchTeam(id)
    current_team = []
    for t in current_team_obj
      current_team.append(t["id"])
    end
    
    new_team.uniq!
    
    to_delete = current_team - new_team
    to_add = new_team - current_team
    
    puts current_team.join(",")
    puts new_team.join(",")
    puts to_delete.join(",")
    puts to_add.join(",")
    
    transaction do
      for pid in to_delete
        connection.update("update research_team set status = 'H', updated_at = now() where research_id = #{sanitize(id)} and person_id = #{sanitize(pid)}")
      end
      
      for pid in to_add
        connection.insert("insert into research_team (research_id, person_id, status, created_at, updated_at) values (#{sanitize(id)}, #{sanitize(pid)}, 'A', now(), now())")
      end
    end
  end
  
  def self.setResearchStatus(id, status)
    connection.update("update research set status = #{sanitize(status)}, updated_at = now() where id = #{sanitize(id)}")
  end
  
  def self.financeResearch(id, amount)
    transaction do
      puts "======================================================================="
      
      query = "insert into project (key, name, description, money, status) (select key, name, description, money - #{sanitize(amount)}, 'N' from project where project.status = 'A' and project.key in (select project_key from research where id = #{sanitize(id)}))"
      puts query
      connection.insert(query)
      
      query = "update project set status = 'H' where key in (select project_key from research where id = #{sanitize(id)}) and status = 'A'"
      puts query
      connection.update(query)
      
      query = "update project set status = 'A' where key in (select project_key from research where id = #{sanitize(id)}) and status = 'N'"
      puts query
      
      connection.update(query)
      
      query = "update research set balance = balance + #{sanitize(amount)} where id = #{sanitize(id)}"
      puts query
      connection.update(query)
      puts "======================================================================="
      #raise ActiveRecord::Rollback
    end
  end
  
  def self.getResearchEntries(id, is_team_member)
    query = "select r.entry, p.name from research_entry r, person p where r.research_id = #{sanitize(id)} and r.person_id = p.id"
    
    if (not is_team_member)
      query += " and p.status = 'A'"
    end
    
    query += " order by r.created_at asc"
    
    rows = connection.select_all(query)
    return rows
  end
  
  def self.getResearchListForMaster
    rows = connection.select_all("select id, project_key, name, status from research where status in ('P', '$', 'S', 'H') order by updated_at asc")
    for row in rows
      row["id"] = Integer(row["id"])
      row["project_key"] = Integer(row["project_key"])
    end
    return rows
  end
  
  def self.setResearchPriceAndStatus(id, price)
    p = - price.abs
    connection.update("update research set balance = #{sanitize(p)}, status = '$' where id = #{sanitize(id)}")
  end
  
  def self.addResearchEntry(id, person_id, entry)
    connection.insert("insert into research_entry (research_id, entry, person_id)
                       values (#{sanitize(id)}, #{sanitize(entry)}, #{sanitize(person_id)})")
  end
  
  def self.stealMoney(project_key, person_id, amount)
    transaction do
      connection.insert("insert into money_history (sender_project_key, receiver_id, value) values(#{sanitize(project_key)}, #{sanitize(person_id)}, #{sanitize(amount)})")
      connection.update("update project set money = money - #{sanitize(amount)} where key = #{sanitize(project_key)} and status = 'A'")
      connection.update("update money set balance = balance + #{sanitize(amount)} where id = #{sanitize(person_id)}")
    end
  end
end
