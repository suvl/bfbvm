require 'active_support/core_ext/string'
require 'active_support/configurable'
require 'action_view/helpers/tag_helper'
require 'action_view/helpers/url_helper'

module Refinery
    module Pages
        class MenuPresenter
            include ActionView::Helpers::TagHelper
            include ActionView::Helpers::UrlHelper
            include ActiveSupport::Configurable

            config_accessor :roots, :menu_tag, :list_tag, :list_item_tag, :css, :dom_id,
                                            :max_depth, :selected_css, :first_css, :last_css, :list_first_css,
                                            :list_dropdown_css, :list_item_dropdown_css,
                                            :list_item__css, :link_dropdown_options, :carret

            # self.dom_id = nil
            # self.css = "pull-left"
            self.menu_tag = :section
            self.list_tag = :ul
            self.list_first_css = ["nav", "navbar-nav", "navbar-right"]
            self.carret = '<b class="caret"></b>'
            self.list_dropdown_css = "dropdown-menu"
            self.link_dropdown_options = {class: "dropdown-toggle", data: {:toggle=>"dropdown"}}
            self.list_item_tag = :li
            self.list_item_dropdown_css = :dropdown
            self.list_item__css = nil
            self.selected_css = :active
            self.first_css = :first
            self.last_css = :last

            def roots
                config.roots.presence || collection.roots
            end

            attr_accessor :context, :collection
            delegate :output_buffer, :output_buffer=, :to => :context

            def initialize(collection, context)
                @collection = collection
                @context = context
            end

            def to_html
                render_menu(roots) if roots.present?
            end

            private
            def render_menu(items)
                content_tag(menu_tag, :id => dom_id, :class => css) do
                    render_menu_items(items)
                end
            end

            def render_menu_items(menu_items)
                if menu_items.present?
                    content_tag(list_tag, :class => menu_items_css(menu_items)) do
                        menu_items.each_with_index.inject(ActiveSupport::SafeBuffer.new) do |buffer, (item, index)|
                            buffer << render_menu_item(item, index)
                        end
                    end
                end
            end

            def render_menu_item(menu_item, index)
                content_tag(list_item_tag, :class => menu_item_css(menu_item, index)) do
                    @cont = context.refinery.url_for(menu_item.url)
                    buffer = ActiveSupport::SafeBuffer.new
                        if check_for_dropdown_item(menu_item)
                            buffer << link_to((menu_item.title+carret).html_safe, "#", link_dropdown_options)
                        else
                            buffer << link_to(menu_item.title, context.refinery.url_for(menu_item.url))
                        end
                    buffer << render_menu_items(menu_item_children(menu_item))
                    buffer
                end
            end

            def check_for_dropdown_item(menu_item)
                (menu_item!=roots.first)&&(menu_item_children(menu_item).count > 0)
            end

            # Determines whether any item underneath the supplied item is the current item according to rails.
            # Just calls selected_item? for each descendant of the supplied item
            # unless it first quickly determines that there are no descendants.
            def descendant_item_selected?(item)
                item.has_children? && item.descendants.any?(&method(:selected_item?))
            end

            def selected_item_or_descendant_item_selected?(item)
                selected_item?(item) || descendant_item_selected?(item)
            end

            # Determine whether the supplied item is the currently open item according to Refinery.
            def selected_item?(item)
                path = context.request.path
                path = path.force_encoding('utf-8') if path.respond_to?(:force_encoding)

                # Ensure we match the path without the locale, if present.
                if %r{^/#{::I18n.locale}/} === path
                    path = path.split(%r{^/#{::I18n.locale}}).last.presence || "/"
                end

                # First try to match against a "menu match" value, if available.
                return true if item.try(:menu_match).present? && path =~ Regexp.new(item.menu_match)

                # Find the first url that is a string.
                url = [item.url]
                url << ['', item.url[:path]].compact.flatten.join('/') if item.url.respond_to?(:keys)
                url = url.last.match(%r{^/#{::I18n.locale.to_s}(/.*)}) ? $1 : url.detect{|u| u.is_a?(String)}

                # Now use all possible vectors to try to find a valid match
                [path, URI.decode(path)].include?(url) || path == "/#{item.original_id}"
            end

            def menu_items_css(menu_items)
                css = []

                css << list_first_css if (roots == menu_items)
                css << list_dropdown_css if (roots != menu_items)

                css.reject(&:blank?).presence

            end

            def menu_item_css(menu_item, index)
                css = []

                css << list_item_dropdown_css if (check_for_dropdown_item(menu_item))
                css << selected_css if selected_item_or_descendant_item_selected?(menu_item)
                css << first_css if index == 0
                css << last_css if index == menu_item.shown_siblings.length

                css.reject(&:blank?).presence
            end

            def menu_item_children(menu_item)
                within_max_depth?(menu_item) ? menu_item.children : []
            end

            def within_max_depth?(menu_item)
                !max_depth || menu_item.depth < max_depth
            end

        end
    end
end