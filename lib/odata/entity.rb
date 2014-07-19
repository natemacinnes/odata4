module OData
  class Entity
    attr_reader :type, :namespace

    def initialize(options = {})
      @type = options[:type]
      @namespace = options[:namespace]
    end

    def name
      @name ||= type.gsub(/#{namespace}\./, '')
    end

    def [](property_name)
      begin
       properties[property_name.to_s].value
      rescue NoMethodError
        raise ArgumentError, "Unknown property: #{property_name}"
      end
    end

    def []=(property_name, value)
      begin
        properties[property_name.to_s].value = value
      rescue NoMethodError
        raise ArgumentError, "Unknown property: #{property_name}"
      end
    end

    def self.with_properties(new_properties = {}, options = {})
      entity = OData::Entity.new(options)
      entity.instance_eval do
        service.properties_for(name).each do |name, instance|
          set_property(name, instance)
        end

        new_properties.each do |property_name, property_value|
          self[property_name.to_s] = property_value
        end
      end
      entity
    end

    def self.from_xml(xml_doc, options = {})
      return nil if xml_doc.nil?
      entity = OData::Entity.new(options)
      process_properties(entity, xml_doc)
      process_feed_property(entity, xml_doc, 'title')
      process_feed_property(entity, xml_doc, 'summary')
      entity
    end

    def to_xml
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.entry('xmlns'           => 'http://www.w3.org/2005/Atom',
                  'xmlns:data'      => 'http://schemas.microsoft.com/ado/2007/08/dataservices',
                  'xmlns:metadata'  => 'http://schemas.microsoft.com/ado/2007/08/dataservices/metadata',
                  'xmlns:georss'    => 'http://www.georss.org/georss',
                  'xmlns:gml'       => 'http://www.opengis.net/gml',
                  'xml:base'        => 'http://services.odata.org/OData/OData.svc/') do
          xml.category(term: "#{namespace}.#{type}",
                       scheme: 'http://schemas.microsoft.com/ado/2007/08/dataservices/scheme')
          xml.author { xml.name }

          xml.content(type: 'application/xml') do
            xml['metadata'].properties do
              properties.each do |name, property|
                next if name == primary_key
                attributes = {
                  'metadata:type' => property.type,
                }

                if property.value.nil?
                  attributes['metadata:null'] = 'true'
                  xml['data'].send(name.to_sym, attributes)
                else
                  xml['data'].send(name.to_sym, attributes, property.xml_value)
                end
              end
            end
          end
        end
      end
      builder.to_xml
    end

    def primary_key
      service.primary_key_for(name)
    end

    private

    def get_property_class(klass_name)
      ::OData::Properties.const_get(klass_name)
    end

    def properties
      @properties ||= {}
    end

    def service
      @service ||= OData::ServiceRegistry[namespace]
    end

    def set_property(name, odata_property)
      properties[name.to_s] = odata_property.dup
    end

    def self.process_properties(entity, xml_doc)
      entity.instance_eval do
        xml_doc.xpath('//content/properties/*').each do |property_xml|
          property_name = property_xml.name
          value_type = service.get_property_type(name, property_name)
          if property_xml.attributes['null'] &&
              property_xml.attributes['null'].value == 'true'
            value = nil
          else
            value = property_xml.content
          end
          klass_name = value_type.gsub(/^Edm\./, '')
          property = get_property_class(klass_name).new(property_name, value)
          set_property(property_name, property)
        end
      end
    end

    def self.process_feed_property(entity, xml_doc, property_name)
      entity.instance_eval do
        property_value = xml_doc.xpath("//#{property_name}").first.content
        property_name = service.send("get_#{property_name}_property_name", name)
        value_type = service.get_property_type(name, property_name)
        klass_name = value_type.gsub(/^Edm\./, '')
        property = get_property_class(klass_name).new(property_name, property_value)
        set_property(property_name, property)
      end
    end
  end
end