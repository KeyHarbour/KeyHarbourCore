class WorkspaceEnvironment < ApplicationRecord
  belongs_to :workspace
  belongs_to :environment
end
