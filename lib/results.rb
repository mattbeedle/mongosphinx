module MongoSphinx #:nodoc:
    class SearchResults

      def initialize(query_results, objects, page, page_size, options = {})
       @query_results = query_results
       @page = page
       @page_size = page_size
       @objects = objects
       
       add_excerpter(@objects)
      end
      
      def add_excerpter(docs)
        docs.each do |object|
          next if object.respond_to?(:excerpts)

          excerpter = MongoSphinx::Excerpter.new self, object
          block = lambda { excerpter }

          object.metaclass.instance_eval do
            define_method(:excerpts, &block)
          end
        end
      end
      
      def excerpt_for(string, model)
        Riddle::Client.new.excerpts(
          :docs   => [string],
          :words  => @query_results[:words].keys.join(' '),
          :index  => "#{MongoMapper.database.name}"
        ).first
      end
      
      def length
        @objects.length
      end

      def previous_page
       @page == 1 ? @page : @page - 1
      end

      def next_page
       (@page == total_pages ? total_pages : @page + 1)
      end

      def current_page
       @page
      end
      
      def total_found
        @query_results[:total_found]
      end

      def total_pages
       (@query_results[:total_found]/@page_size.to_f).ceil
      end

      def each(&block)
       @objects.each(&block)
      end
      
      def map(&block)
        @objects.map(&block)
      end

      def empty?
       @objects.empty?
      end
      
      def time
        @query_results[:time]
      end

    end
  
end

 