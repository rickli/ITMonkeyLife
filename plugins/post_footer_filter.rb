#
# Author: Brandon Mathis
# Based on the semantic pullquote technique by Maykel Loomans at http://miekd.com/articles/pull-quotes-with-html5-and-css/
#
# Outputs a span with a data-pullquote attribute set from the marked pullquote. Example:
#
#   {% pullquote %}
#     When writing longform posts, I find it helpful to include pullquotes, which help those scanning a post discern whether or not a post is helpful.
#     It is important to note, {" pullquotes are merely visual in presentation and should not appear twice in the text. "} That is why it is prefered
#     to use a CSS only technique for styling pullquotes.
#   {% endpullquote %}
#   ...will output...
#   <p>
#     <span data-pullquote="pullquotes are merely visual in presentation and should not appear twice in the text.">
#       When writing longform posts, I find it helpful to include pullquotes, which help those scanning a post discern whether or not a post is helpful.
#       It is important to note, pullquotes are merely visual in presentation and should not appear twice in the text. This is why a CSS only approach
#       for styling pullquotes is prefered.
#     </span>
#   </p>
#
# {% pullquote left %} will create a left-aligned pullquote instead.
#
# Note: this plugin now creates pullquotes with the class of pullquote-right by default

require './plugins/post_filters'

module AppendFooterFilter
        def append(post)
                author = post.site.config['author']
                url = post.site.config['url']
                pre = post.site.config['original_url_pre']
                post.content + %Q[<p class='post-footer'>
                        written by <a href='#{url}'>#{author}</a>&nbsp;posted at <a href='#{url}'>#{url}</a></p>]
        end
end

module Jekyll
        class AppendFooter < PostFilter
                include AppendFooterFilter
                def pre_render(post)
                        post.content = append(post) if post.is_post?
                end
        end
end

Liquid::Template.register_filter AppendFooterFilter
