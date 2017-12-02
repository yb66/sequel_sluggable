require 'spec_helper'
require 'sequel'

require_relative "../lib/sequel/plugins/sluggable.rb"

# Create model to test on
DB = Sequel.sqlite

SLUGGATOR = Proc.new {|value, model| value.chomp.downcase }

# declaration
module Sluggable; end

shared_context "set up table" do
  before do
    DB.create_table :items do
      primary_key :id
      String :name
      String :slug
      String :sluggie
    end
  end
  after do
    DB.drop_table :items
  end
end

# used a shared example to help with passing opts
shared_examples "Set up" do |opts|
  include_context "set up table"
  before do
    # set up this way to grab opts, class keyword is
    # a scope gate
    Sluggable::Item = Class.new(Sequel::Model) do
        plugin :sluggable, opts
    end
    Sluggable::Item.set_dataset :items
  end
  after do
    Sluggable.send(:remove_const, :Item)
  end
end


describe "SequelSluggable" do

  describe "Available plugins" do
    include_examples "Set up", {source: :name, target: :slug}
    Given(:plugins) { Sluggable::Item.plugins }
    Then { plugins.include? Sequel::Plugins::Sluggable }
  end


  describe "Available methods" do
    context "Class" do
      include_examples "Set up", {source: :name, target: :slug}
      Given(:klass) { Sluggable::Item }
      Then { klass.respond_to? :find_by_pk_or_slug }
      And { klass.respond_to? :find_by_slug }
    end
    context "Instance" do
      include_examples "Set up", {source: :name, target: :slug}
      Given(:instance) { Sluggable::Item.new }
      Then { instance.respond_to? :slug }
    end
  end


  describe "Action" do
    include_context "Set up", {source: :name, target: :slug}
    When(:item_created) { Sluggable::Item.create(:name => 'Pavel Kunc') }
    Then { item_created.slug == 'pavel-kunc' }
  end


  describe "Options handling" do
    Given(:a_sluggator) { SLUGGATOR }

    context "Item2" do
      include_examples "Set up", {:source    => :name,
                                  :target    => :slugg,
                                  :sluggator => SLUGGATOR,
                                  :frozen    => false}

      Given(:options) { Sluggable::Item.sluggable_options }
      Then { options[:source] == :name }
      And { options[:target] == :slugg }
      And { options[:sluggator] == SLUGGATOR }
      And { options[:frozen] == false }
    end

    context "Item1" do
      include_examples "Set up", {source: :name, target: :slug}
      Given(:options) { Sluggable::Item.sluggable_options }
      Then { options[:frozen] == true }
      And { options[:target] == :slug }
    end

    context "Errors" do      
      #include_examples "Set up", {source: :name, target: :slug}
      include_context "set up table"
      before do
        class Sluggable::Item < Sequel::Model; end
      end
      after do
        Sluggable.send(:remove_const, :Item)
      end
        

      it "should require source option" do
        expect { Sluggable::Item.plugin :sluggable }.to raise_error(ArgumentError, "missing keyword: source")
      end


      it "should require sluggator to be Symbol or callable" do
        expect { Sluggable::Item.plugin :sluggable, :source => :name, :sluggator => 5 }.to raise_error(ArgumentError, "If you provide :sluggator it must respond to `intern` or `call`.")
      end
    end
  end


  describe "#:target= method" do
    include_examples "Set up", {source: :name, target: :sluggie}

    Given(:item) { Sluggable::Item.new(:name => 'Ida Down') }
    When { item.sluggie = item.name }
    Then { item.sluggie == 'ida-down' }

    When(:other_item){ Sluggable::Item.create(:name => 'Nora Bone') }
    Then { other_item.sluggie == 'nora-bone' }
  end


  describe "::find_by_pk_or_slug" do
    include_examples "Set up", {source: :name, target: :slug}
    Given(:name) { 'Sleepy Ness' }
    Given(:slug) { "sleepy-ness" }
    When(:item) { Sluggable::Item.create(:name => name) }
    Then { Sluggable::Item.find_by_pk_or_slug(slug)== item }
    Then { Sluggable::Item.find_by_pk_or_slug(item.id) == item }
    describe "failure" do
      context "Ask for a slug that isn't there" do
        Then { Sluggable::Item.find_by_pk_or_slug('tonda-kunc').nil? }
      end

      context "model not found when searching by id" do
        Then(:result) { Sluggable::Item.find_by_pk_or_slug(1000).nil? }
      end
    end
  end

  describe "::find_by_slug" do
    include_examples "Set up", {source: :name, target: :slug}
    When(:rick) { Sluggable::Item.create(:name => "Rick O'Shea") }
    Then { Sluggable::Item.find_by_slug('rick-o-shea') == rick }
    Then { Sluggable::Item.find_by_slug('tonda-kunc').nil? }
  end


  describe "slug algorithm customization" do
    context "using `to_slug` on model if available" do      
      include_examples "Set up", {source: :name, target: :slug}
      before do
        Sluggable::Item.class_eval do
          def to_slug(v)
            v.strip
              .downcase
              .gsub(/[^a-z0-9]+/,'_')
              .split(//)
              .reverse
              .join
          end
        end
      end
      When(:item) { Sluggable::Item.create(:name => 'Scott Chegg') }
      Then{ item.slug == 'ggehc_ttocs' }
    end

    context "use only :sluggator proc if defined" do        
      include_examples "Set up", {source: :name, target: :slug, :sluggator => Proc.new {|value, model| value.chomp.downcase.gsub(/[^a-z0-9]+/,'_')}}
      When(:item) { Sluggable::Item.create(:name => 'Gerry Atrick') }
      Then { item.slug == 'gerry_atrick' }
    end

    context "use only :sluggator Symbol if defined" do        
      include_examples "Set up", {source: :name, target: :slug, :sluggator => :my_custom_sluggator}
      before do
        Sluggable::Item.class_eval do
          def my_custom_sluggator(v)
             v.chomp.upcase.gsub(/[^a-zA-Z0-9]+/,'-')
          end
        end
      end
      When(:item) { Sluggable::Item.create(:name => 'Ulrika Garlic') }
      Then { item.slug == 'ULRIKA-GARLIC' }
    end
  end

  describe "slug generation and regeneration" do
    context "Standard set up" do
      include_examples "Set up", {source: :name, target: :slug}
      describe "Generating slug when creating model and slug is not set" do
        When(:item) { Sluggable::Item.create(:name => 'Dee Liver')}
        Then { item.slug == 'dee-liver'}
      end

      describe "Not regenerating slug when creating model and slug is set" do
        Given(:item) {
          item = Sluggable::Item.new(:name => 'Dennis Elbow')
          item.slug = 'Elbow Dennis'
          item.save
        }
        Then { item.slug == 'elbow-dennis' }
      end

      describe "Not regenerating slug when updating model because frozen is the default" do
        Given(:item) { Sluggable::Item.create(:name => 'Phylis Stein') }
        When { item.update(:name => 'Stein Phylis') }
        Then { item.slug == 'phylis-stein' }
      end
    end

    describe "Regenerating slug when updating model and slug is not frozen" do        
      include_examples "Set up", {source: :name, target: :slug, frozen: false}
      Given(:item) { Sluggable::Item.create(:name => 'Leah Tard') }
      When { item.update(:name => 'Tard Leah') }
      Then { item.slug == 'leah-tard' }
    end
  end

end
