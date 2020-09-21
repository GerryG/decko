require "decko/application"
require_relative "alias"
require "card/seed_consts"

CARD_TASKS =
  [
    :migrate,
    { migrate: [:cards, :structure, :core_cards, :deck_cards, :redo, :stamp] },
    :reset_cache
  ]

link_task CARD_TASKS, from: :decko, to: :card

decko_namespace = namespace :decko do
  desc "create a decko database from scratch, load initial data"
  task :seed do
    failing_loudly "decko seed" do
      seed
    end
  end

  desc "clear and load fixtures with existing tables"
  task reseed: :environment do
    ENV["SCHEMA"] ||= "#{Cardio.gem_root}/db/schema.rb"

    decko_namespace["clear"].invoke
    decko_namespace["load"].invoke
  end

  # ARDEP: this is all Rails -> AR standard usages, need alternatives in loading data to storage models
  desc "empty the card tables"
  task :clear do
    conn = ActiveRecord::Base.connection

    puts "delete all data in bootstrap tables"
    CARD_SEED_TABLES.each do |table|
      conn.delete "delete from #{table}"
    end
  end

  desc "Load seed data into database"
  task :load do
    decko_namespace["load_without_reset"].invoke
    puts "reset cache"
    system "bundle exec rake decko:reset_cache" # needs loaded environment
  end

  desc "set symlink for assets"
  task update_assets_symlink: :environment do
    prepped_asset_path do |assets_path|
      Card::Mod.dirs.each_assets_path do |mod, target|
        link = File.join assets_path, mod
        FileUtils.rm_rf link
        FileUtils.ln_s target, link, force: true
      end
    end
  end

  def prepped_asset_path
    return if Rails.root.to_s == Decko.gem_root # inside decko gem
    assets_path = File.join Rails.public_path, "assets"
    if File.symlink?(assets_path) || !File.directory?(assets_path)
      FileUtils.rm_rf assets_path
      FileUtils.mkdir assets_path
    end
    yield assets_path
  end

  alias_task :migrate, "card:migrate"

  desc "insert existing card migrations into schema_migrations_cards to avoid re-migrating"
  task :assume_card_migrations do
    require "decko/engine"
    Cardio.assume_migrated_upto_version :core_cards
  end

  def seed with_cache_reset: true
    ENV["SCHEMA"] ||= "#{Cardio.gem_root}/db/schema.rb"
    # FIXME: this should be an option, but should not happen on standard
    # creates!
    begin
      Rake::Task["db:drop"].invoke
    rescue
      puts "not dropped"
    end

    puts "creating"
    Rake::Task["db:create"].invoke

    puts "loading schema"

    Rake::Task["db:schema:load"].invoke

    load_task = "decko:load"
    load_task << "_without_reset" unless with_cache_reset
    Rake::Task[load_task].invoke
  end

  namespace :emergency do
    task rescue_watchers: :environment do
      follower_hash = Hash.new { |h, v| h[v] = [] }

      Card.where("right_id" => 219).each do |watcher_list|
        watcher_list.include_set_modules
        next unless watcher_list.left
        watching = watcher_list.left.name
        watcher_list.item_names.each do |user|
          follower_hash[user] << watching
        end
      end

      Card.search(right: { codename: "following" }).each do |following|
        Card::Auth.as_bot do
          following.update! content: ""
        end
      end

      follower_hash.each do |user, items|
        next unless (card = Card.fetch(user)) && card.account
        Card::Auth.as(user) do
          following = card.fetch "following", new: {}
          following.items = items
        end
      end
    end
  end
end

def failing_loudly task
  yield
rescue
  # TODO: fix this so that message appears *after* the errors.
  # Solution should ensure that rake still exits with error code 1!
  raise "\n>>>>>> FAILURE! #{task} did not complete successfully." \
        "\n>>>>>> Please address errors and re-run:\n\n\n"
end

def version
  ENV["VERSION"] ? ENV["VERSION"].to_i : nil
end
