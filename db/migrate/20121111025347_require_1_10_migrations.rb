class Require110Migrations < ActiveRecord::Migration
  def self.up
    fail %{
Your database is not ready to be migrated to #{Wagn::Version.full}.
Please first install version 1.10.0 and run `rake db:migrate`.

Sorry about this! We're working to minimize these hassles in the future.
}
  end

  def self.down
    fail "Older migrations have been removed because of incompatibility."
  end
end
