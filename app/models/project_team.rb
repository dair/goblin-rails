class ProjectTeam < ActiveRecord::Base
  set_table_name "project_team"
  attr_accessible :person, :project, :status
  
  belongs_to :project, :class_name => "Project"
  belongs_to :person, :class_name => "Person", :primary_key => :key
  
  def allProjectsForPerson(id)
    where(:person => id)
  end
end
