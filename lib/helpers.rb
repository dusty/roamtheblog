module ViewHelpers

  def self.included(base)
    base.send(:include, InstanceMethods)
    base.send(:extend, ClassMethods)
  end

  module InstanceMethods

    def production
      ENV['RACK_ENV'] == 'production'
    end

    def get_location_link(location)
      return nil if location.empty?
      loc = location.gsub(" ", "%20")
      "<a href=\"http://maps.google.com?q=#{loc}\" target=\"x-{{timestamp}}\">#{location}</a>"
    end

    def get_post_path(post)
      "/blog/#{post.slug}"
    end

    def get_tag_path(tag)
      "/blog?tag=#{tag}"
    end

    def get_post_url(domain,post)
      "http://#{domain}#{get_post_path(post)}"
    end

    def get_short_date(date)
      date = parse_date(date)
      date ? date.strftime("%m/%d/%Y %l:%M %P") : ""
    end

    def get_long_date(date)
      date = parse_date(date)
      date ? date.strftime("%B #{date.day.ordinal}, %Y") : ""
    end

    private
    def parse_date(date)
      return nil if date.blank?
      date = Chronic.parse(date) if date.is_a?(String)
      date ? date.in_time_zone : nil
    end


    def create_getter(variable,attribute)
      self.class.class_eval do
        define_method("#{variable}_#{attribute}") do
          instance_variable_get("@#{variable}").send(attribute)
        end
      end
    end

    def create_error_getter(variable,attribute)
      self.class.class_eval do
        define_method("#{variable}_#{attribute}_error") do
          instance_variable_get("@#{variable}").errors[attribute].first
        end
      end
    end

    def create_getters(variable,attributes)
      attributes.each {|attribute| create_getter(variable,attribute)}
    end

    def create_error_getters(variable,attributes)
      attributes.each {|attribute| create_error_getter(variable,attribute)}
    end

    def create_getters_and_errors(variable,attributes)
      create_getters(variable,attributes)
      create_error_getters(variable,attributes)
    end

  end

  module ClassMethods
  end

end

