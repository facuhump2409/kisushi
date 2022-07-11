# frozen_string_literal: true

# require 'xml/mapping'
#
# class Item; end
#
# class Channel; end
#
# class Metadata; end
#
# class Rss
#   include XML::Mapping
#   object_node :channel, 'channel', class: Channel
# end
#
# class Channel
#   include XML::Mapping
#   text_node :title, 'title'
#   text_node :link, 'link'
#   text_node :description, 'description'
#   array_node :items, 'items', 'item', class: Item
# end
#
# class Metadata
#   include XML::Mapping
#
#   text_node :ref_application_id, 'ref_application_id'
#   text_node :ref_asset_id, 'ref_asset_id'
# end
module ActiveRecordExtension
  def to_hash
    hash = {}; self.attributes.each { |k, v| hash[k] = v }
    return hash
  end
end

class Item
  # include ActiveRecordExtension

  # include XML::Mapping
  # numeric_node :id
  # text_node :availability
  # text_node :condition
  # text_node :image_link
  # text_node :link
  # text_node :title
  # text_node :price
  # text_node :product_type
  # text_node :identifier_exists

  attr_accessor :availability, :id, :condition, :image_link, :link, :title, :price, :product_type,
                :identifier_exists, :description

  def to_hash
    hash = {}
    instance_variables.each { |var| hash[var.to_s.delete('@')] = instance_variable_get(var) }
    hash
  end

  # def initialize(availability, id, condition, image_link, link, title, price, product_type, identifier_exists)
  #   @availability = availability
  #   @id = id
  #   @condition = condition
  #   @image_link = image_link
  #   @link = link
  #   @title = title
  #   @price = price
  #   @product_type = product_type
  #   @identifier_exists = identifier_exists
  # end
end
