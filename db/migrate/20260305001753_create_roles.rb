class CreateRoles < ActiveRecord::Migration[8.1]
  def change
    create_table :roles do |t|
      t.string :name

      t.timestamps
    end
    Role.create(name: 'Owner') if Role.find_by(name: 'Owner').nil?
    Role.create(name: 'Admin') if Role.find_by(name: 'Admin').nil?
    Role.create(name: 'User') if Role.find_by(name: 'User').nil?
    Role.create(name: 'Viewer') if Role.find_by(name: 'Viewer').nil?
  end
end
