module Eventsfinder

  def self.events(all_events = get_live_events)
    events = structured_events all_events
    remove_single_events events
  end


  def self.structured_events(unstructured)
    #change hash from address => players view to players => address view
    structured = Hash.new
    unstructured.each do |key, value|
      unless structured[value]
        structured[value] = [key]
      else
        structured[value].push(key)
      end
    end
    structured
  end

  def self.remove_single_events(events)
    unique = Hash.new
    events.each do |key, val|
      unique[key] = val if val.size > 1
    end
    unique
  end
end
