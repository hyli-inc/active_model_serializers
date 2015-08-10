require 'test_helper'
require 'will_paginate/array'
require 'kaminari'
require 'kaminari/hooks'
::Kaminari::Hooks.init

module ActiveModel
  class Serializer
    class Adapter
      class JsonApi
        class PaginationLinksTest < Minitest::Test
          def setup
            ActionController::Base.cache_store.clear
            @array = [
              Profile.new({ id: 1, name: 'Name 1', description: 'Description 1', comments: 'Comments 1' }),
              Profile.new({ id: 2, name: 'Name 2', description: 'Description 2', comments: 'Comments 2' }),
              Profile.new({ id: 3, name: 'Name 3', description: 'Description 3', comments: 'Comments 3' })
            ]
          end

          def using_kaminari
            Kaminari.paginate_array(@array).page(2).per(1)
          end

          def using_will_paginate
            @array.paginate(page: 2, per_page: 1)
          end

          def expected_response_without_pagination_links
            {
              data: [{
                id:"2",
                type:"profiles",
                attributes:{
                  name:"Name 2",
                  description:"Description 2"
                }
              }]
            }
          end

          def expected_response_with_pagination_links
            {
              data: [{
                id:"2",
                type:"profiles",
                attributes:{
                  name:"Name 2",
                  description:"Description 2"
                }
              }],
              links:{
                first: "http://example.com?page=1&per_page=1",
                prev: "http://example.com?page=1&per_page=1",
                next: "http://example.com?page=3&per_page=1",
                last: "http://example.com?page=3&per_page=1"
              }
            }
          end

          def test_pagination_links_using_kaminari
            serializer = ArraySerializer.new(using_kaminari, pagination: true, original_url: "http://example.com")
            adapter = ActiveModel::Serializer::Adapter::JsonApi.new(serializer)

            assert_equal expected_response_with_pagination_links, adapter.serializable_hash
          end

          def test_pagination_links_using_will_paginate
            serializer = ArraySerializer.new(using_will_paginate, pagination: true, original_url: "http://example.com")
            adapter = ActiveModel::Serializer::Adapter::JsonApi.new(serializer)

            assert_equal expected_response_with_pagination_links, adapter.serializable_hash
          end

          def test_not_showing_pagination_links
            serializer = ArraySerializer.new(using_will_paginate, pagination: false)
            adapter = ActiveModel::Serializer::Adapter::JsonApi.new(serializer)

            assert_equal expected_response_without_pagination_links, adapter.serializable_hash
          end
        end
      end
    end
  end
end
