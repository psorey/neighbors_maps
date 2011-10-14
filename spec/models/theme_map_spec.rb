#!/usr/bin/env ruby
require 'spec_helper'

describe ThemeMap do
  
  before (:each) do
    @valid_attributes = {:name => 'Great Pubs', :slug => 'great-pubs', :base_layer_ids => [1,2], :layer_ids => [1,2,3]}
  end

  it "should not be valid empty" do
    @map = ThemeMap.new()
    @map.should_not be_valid
  end
  
  it "should not be valid without name" do
    @map = ThemeMap.new(@valid_attributes.except(:name))
    @map.should_not be_valid
  end
  
  it "should create a valid slug from the name" do
    @map = ThemeMap.create(@valid_attributes.except(:slug))
    @map.slug should equal 'great-pubs'
  end
 
  it "should be valid with valid attributes" do
    @map = ThemeMap.new(@valid_attributes)
    @map.should be_valid
  end
  
  it "should have a unique name" do
    @map = ThemeMap.new(@valid_attributes)
    @map.save
    @map2 = ThemeMap.new(@valid_attributes)
    @map2.should_not be_valid
  end

  it "should produce a map" do
    
  end

  
end
