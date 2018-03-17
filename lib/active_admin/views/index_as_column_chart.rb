module ActiveAdmin
  module Views

    # # Index as a Block
    #
    # If you want to fully customize the display of your resources on the index
    # screen, Index as a Block allows you to render a block of content for each
    # resource.
    #
    # ```ruby
    # index as: :block do |product|
    #   div for: product do
    #     resource_selection_cell product
    #     h2  auto_link     product.title
    #     div simple_format product.description
    #   end
    # end
    # ```
    #
    class IndexAsColumnChart < ActiveAdmin::Component

      def build(page_presenter, collection)
        add_class "index"
        collection.limit(1).each do |obj|
          instance_exec(obj, &page_presenter.block)
        end
      end

      def self.index_name
        "column_chart"
      end

    end
  end
end