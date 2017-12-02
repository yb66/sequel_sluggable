module Sequel
  module Plugins

    # The Sluggable plugin creates hook that automatically sets 
    # 'slug' field to the slugged value of the column specified
    # by :source option.
    #
    # You need to have "target" column in your model.
    module Sluggable
      DEFAULT_TARGET_COLUMN = :slug
      DEFAULT_TARGET_COLUMN.freeze


      # @param frozen    [Boolean]      :Is slug frozen, default true
      # @param sluggator [Proc, Symbol] :Algorithm to convert string to slug.
      # @param source    [Symbol] :Column to get value to be slugged from.
      # @param target    [Symbol] :Column to write value of the slug to.
      def self.configure(model, source:, target: DEFAULT_TARGET_COLUMN, sluggator: nil, frozen: nil)
        # unfreeze
        model.sluggable_options = model.sluggable_options.dup
        model.sluggable_options[:source] = source
        if sluggator
          if sluggator.respond_to? :intern
            model.sluggable_options[:sluggator] = sluggator.intern
          elsif sluggator.respond_to?(:call)
            model.sluggable_options[:sluggator] = sluggator
          else
            raise ArgumentError, "If you provide :sluggator it must respond to `intern` or `call`."
          end
        end
        model.sluggable_options[:target] = target
        model.sluggable_options[:frozen] = frozen.nil? ? true : !!frozen
        model.sluggable_options.freeze

        model.class_eval do
          # Sets the slug to the normalized URL friendly string
          #
          # Compute slug for the value
          #
          # @param [String] String to be slugged
          # @return [String]
          define_method("#{sluggable_options[:target]}=") do |value|
            sluggator = self.class.sluggable_options[:sluggator]
            if sluggator
              if sluggator.respond_to?(:call)
                slug = sluggator.call(value, self)
              else
                slug = self.send(sluggator, value) if sluggator
              end
            else
              slug = to_slug(value)
            end
            super(slug)
          end
        end

      end


      module ClassMethods
        attr_reader :sluggable_options

        # Finds model by slug or PK
        #
        # @return [Sequel::Model, nil]
        def find_by_pk_or_slug(value)
          value.to_s =~ /^\d+$/ ? self[value] : self.find_by_slug(value)
        end


        # Finds model by Slug column
        #
        # @return [Sequel::Model, nil]
        def find_by_slug(value)
          self[sluggable_options[:target] => value.chomp]
        end


        def sluggable_options=( opts )
          self.sluggable_options.replace opts
        end


        def sluggable_options
          @sluggable_options ||= {}
        end
      end


      module InstanceMethods

        # Sets a slug column to the slugged value
        def before_create
          super
          target = self.class.sluggable_options[:target]
          set_target_column unless self.send(target)
        end


        # Sets a slug column to the slugged value
        def before_update
          super
          self.class.sluggable_options[:frozen] ||
            self.send(self.class.sluggable_options[:target]) ||
              set_target_column
        end


        private

        # Generate slug from the passed value
        #
        # @param [String] String to be slugged
        # @return [String]
        def to_slug(value)
          value.strip.downcase.gsub(/[^a-z0-9]+/,'-')
        end


        # Sets target column with source column which 
        # effectively triggers slug generation
        def set_target_column
          target = self.class.sluggable_options[:target]
          source = self.class.sluggable_options[:source]
          self.send("#{target}=", self.send(source))
        end

      end # InstanceMethods
    end # Sluggable
  end # Plugins
end # Sequel
