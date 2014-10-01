# encoding: utf-8

module Attrio
  module Initialize
    def new(*args, &block)
      obj = self.allocate

      obj.send :initialize, *args, &block

      obj.class.attrio.each do |group, options|
        obj.instance_variable_set("@#{group}", {})
        obj.class.send("#{group}").each do |name, attribute|
          obj.send("#{group}")[name] = attribute.dup
          obj.send("#{group}")[name].instance_variable_set(:@object, obj)
          obj.send("#{group}")[name].reset! if reset?(obj, name, attribute)
        end
      end

      obj
    end

    private

    def reset?(obj, attribute_name, attribute)
      if attribute.allow_blank?
        nil_attribute?(obj, attribute_name, attribute)
      else
        blank_attribute?(obj, attribute_name, attribute)
      end
    end

    def nil_attribute?(obj, attribute_name, attribute)
      obj.send(attribute_name).nil?
    end

    def blank_attribute?(obj, attribute_name, attribute)
      if attribute.type && attribute.type <= Attrio::Types::Boolean
        obj.send(attribute_name).nil?
      else
        obj.send(attribute_name).blank?
      end
    end
  end
end
