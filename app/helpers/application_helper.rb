module ApplicationHelper
  
  def course_index_notes(course)
    s = []
    if course.draft
      s << '<li class="draft">Draft</li>'
    elsif course.contains_drafts && logged_in_as_owner?
      s << '<li class="draft has_content">Draft Content</li>'
    end
    if course.contains_premium_visible_to(current_user)
      s << '<li class="premium has_content"><span class="icon">Premium</span> <span class="content">Content</span></li>'
    end
    if logged_in_as_owner? && course.contains_registered_visible_to(current_user)
      s << '<li class="registered has_content"><span class="icon">Registered</span> <span class="content">Content</span></li>'
    end
    s.last.gsub!(/\">/, ' last">') if s.last
    return s * "\n"
  end
  
  def content_notes(content)
    s = []
    if !content.access_class.nil?
      s << '<li class="premium"><span class="icon">Premium</span></li>'
    end
    if logged_in_as_owner? && content.registered
      s << '<li class="registered"><span class="icon">Registered</span></li>'
    end
    if content.draft
      s << '<li class="draft">Draft</li>'
    end
    s.last.gsub!(/\">/, ' last">') if s.last
    return s * "\n"
  end
    
  def define_js_function(function_name, &block)
    parens = function_name.kind_of?(Symbol) ? "()" : ""
    update_page_tag do | page |
      page << "function #{function_name}#{parens} {"
      yield page
      page << "}"
    end	
  end
  
  def themed_public_file(filename)
    themes_absolute_dir = File.expand_path(File.dirname(__FILE__) + "/../../public/themes")
    
    themes_public_dir = "/themes"
    default_public_file = "#{themes_public_dir}/default/#{filename}"
    
    return default_public_file unless current_community
    return default_public_file unless File.exist?("#{themes_absolute_dir}/#{current_community.host}/#{filename}")
      "#{themes_public_dir}/#{current_community.host}/#{filename}"
  end
  
  def current_tag(tag_name, class_is_current_if, &block)
    content_tag(tag_name, { :class => (:current if class_is_current_if) }, &block)
  end
  
  def set_focus_to(id)
    javascript_tag("Field.focus('#{id}')");
  end
  
  def community_stylesheet
    themed_file(current_community ? "#{current_community.host}.css" : nil, "default.css")
  end
  
  def community_logo
    themed_file("images/logo.gif")
  end
  
  private
  def themed_file(path, default_path = path) 
    default_file = "/themes/default/#{default_path}"
    return default_file unless current_community
    return default_file unless File.exist?(File.expand_path(File.dirname(__FILE__) + "/../../public/themes/#{current_community.host}/#{path}"))
      "/themes/#{current_community.host}/#{path}"
  end
  
#  def snippet(thought, wordcount = 4)
#    thought.split[0..(wordcount-1)].join(' ') + (thought.split.size > wordcount ? '...' : '')
#  end

  def snippet(thought, letters = 15)
    truncate(thought, :length => letters)
  end

end
