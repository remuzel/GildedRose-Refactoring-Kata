# For convenience (and because I always miss python)
def max(*args)
  args.max
end

def min(*args)
  args.min
end

# Default guilded rose without the horrible ifs
class GildedRose

  def initialize(items)
    @items = items
  end

  def update_quality()
    @items.each do |item|
      ItemHandler.update(item)
  end
end

# Default items
class Item
  attr_accessor :name, :sell_in, :quality

  def initialize(name, sell_in, quality)
    @name = name
    @sell_in = sell_in
    @quality = quality
  end

  def to_s()
    "#{@name}, #{@sell_in}, #{@quality}"
  end
end

# Setting the common fields and methods for all items
class BaseItem
  attr_reader :item

  def initialize(item)
    @item = item
  end

  def update
    update_quality
    update_sell_in
  end

  private

  def update_quality
  end

  def update_sell_in
  end
end

# The default behaviour for an items' change in quality and sell_in values
class Default < BaseItem
  private

  def update_quality
    quality = item.quality - (item.sell_in > 0 ? 1 : 2)

    item.quality = max 0, quality
  end

  def update_sell_in
    item.sell_in -= 1
  end
end

# AgedBrie specific case
class AgedBrie < BaseItem
  private

  def update_quality
    quality += item.quality + (item.sell_in > 0 ? 1 : 2)

    item.quality = min quality, 50
  end

  def update_sell_in
    item.sell_in -= 1
  end
end

# Sulfuras specific case (just the default)
class Sulfuras < BaseItem
end

# Passes specific case
class Passes < BaseItem
  private

  def update_quality
    quality = if item.sell_in > 10
                item.quality + 1
              elsif item.sell_in > 5
                item.quality + 2
              elsif item.sell_in > 0
                item.quality + 3
              else
                0
              end

    item.quality = min quality, 50
  end

  def update_sell_in
    item.sell_in -= 1
  end
end

# Cake specific case
class Cake < BaseItem
  private

  def update_quality
    quality = item.quality - 2
    item.quality = max 0, quality
  end

  def update_sell_in
    item.sell_in -= 1
  end
end

# Wrapper for items, maps the unique name to the correct item handler
class ItemHandler
  attr_reader :item

  MAP = {
    'Aged Brie' => AgedBrie,
    'Sulfuras, Hand of Ragnaros' => Sulfuras, 
    'Backstage passes to a TAFKAL80ETC concert' => Passes,
    'Conjured Mana Cake' => Cake
  }

  def initialize(item)
    @item = item
  end

  def update
    handler.new(item).update
  end

  def self.update(item)
    new(item).update
  end

  private

  def handler 
    @handler ||= MAP[item.name] || Default 
  end
end

end