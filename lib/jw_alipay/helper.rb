module JwAlipay
  class Helper
    include Sign

    attr_reader :fields, :datum, :xml_root

    def initialize(options = {})
      @fields = {}
      @datum = {}
      @xml_root = options[:xml_root]
      add_field('partner', PARTNER)
      add_field('_input_charset', 'utf-8')
    end

    def add_field(name, value)
      return if name.blank? || value.blank?
      self.fields[name.to_s] = value.to_s
    end

    def add_fields(params)
      (params || {}).each do |k, v|
        add_field(k, v)
      end
    end

    def add_xml_field(name, value)
      self.datum[name.to_s] = value.to_s
    end

    def add_xml_fields(params)
      (params || {}).each do |k, v|
        add_xml_field(k, v)
      end
    end

    def xml_string
      xml = self.datum.to_xml(:skip_instruct => true, :root => self.xml_root, :skip_types => true)
      xml.gsub("-", "_").gsub("\n", "").gsub(" ", "")
    end

    def query_string
      sign(self.fields)
    end
  end
end
