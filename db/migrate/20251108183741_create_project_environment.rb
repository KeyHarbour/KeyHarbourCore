class CreateProjectEnvironment < ActiveRecord::Migration[8.0]
  def change
    create_join_table :projects, :environments do |t|
      t.index [ :project_id, :environment_id ]
      t.index [ :environment_id, :project_id ]
    end
  end
end
