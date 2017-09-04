format :html do
  ICON_MAP = {
    material: {
      plus: :add,
      pencil: :edit,
      trash: :delete,
      wrench: :build,
      new_window: :open_in_new,
      history: :history,
      triangle_left: :expand_less,
      triangle_right: :expand_more,
      flag: :flag,
      option_horizontal: :more_horiz,
      option_vertical: :more_vert,
      pushpin: :pin_drop,
      baby_formula: :device_hub,
      log_out: :call_made,
      log_in: :call_received,
      explore: :explore,
      remove: :close,
      expand: :expand_more,
      collapse_down: :expand_less
    },
    font_awesome: {
      option_horizontal: :ellipsis_h,
      pushpin: "thumb-tack"
    },
    glyphicon: {
      option_horizontal: "option-horizontal",
      option_vertical: "option-vertical",
      triangle_left: "triangle-left",
      triangle_right: "triagnle-right",
      baby_formula: "baby-formula",
      log_out: "log-out",
      log_in: "log-in",
      collapse_down: "collaps-down"
    }

  }.freeze

  def icon_class library, icon
    ICON_MAP[library][icon] || icon
  end

  def icon_tag icon, extra_class=""
    return "" unless icon.present?
    material_icon icon_class(:material, icon), extra_class
  end

  def glyphicon icon, extra_class=""
    return "" unless icon
    wrap_with :span, "",
              "aria-hidden" => true,
              class: "glyphicon glyphicon-#{icon_class(:glyphicon, icon)} #{extra_class}"
  end

  def fa_icon icon, extra_class=""
    return "" unless icon
    %{<i class="fa fa-#{icon_class(:font_awesome, icon)} #{extra_class}"></i>}
  end

  def material_icon icon, extra_class=""
    %{<i class="material-icons #{extra_class}">#{icon_class(:material, icon)}</i>}
  end

  def button_link link_text, opts={}
    btn_type = opts.delete(:btn_type) || "primary"
    opts[:class] = [opts[:class], "btn btn-#{btn_type}"].compact.join " "
    smart_link_to link_text, opts
  end

  def dropdown_button name, opts={}
    <<-HTML
      <div class="btn-group btn-group-sm" role="group">
        <button class="btn btn-primary dropdown-toggle"
                data-toggle="dropdown" title="#{name}" aria-expanded="false"
                aria-haspopup="true">
          #{icon_tag opts[:icon] if opts[:icon]} #{name}
          <span class="caret"></span>
        </button>
        #{dropdown_list yield, opts[:class], opts[:active]}
      </div>
    HTML
  end

  def dropdown_list items, extra_css_class=nil, active=nil
    wrap_with :ul, class: "dropdown-menu #{extra_css_class}", role: "menu" do
      case items
      when Array
        items.map.with_index { |item, i| dropdown_list_item item, i, active }
      when Hash
        items.map { |key, item| dropdown_list_item item, key, active }
      else
        [items]
      end.compact.join "\n"
    end
  end

  def dropdown_list_item item, active_test, active
    return unless item
    "<li #{'class=\'active\'' if active_test == active}>#{item}</li>"
  end

  def separator
    '<li role="separator" class="divider"></li>'
  end

  def split_button main_button, active_item
    wrap_with :div, class: "btn-group btn-group-sm" do
      [
        main_button,
        split_button_toggle,
        dropdown_list(yield, nil, active_item)
      ]
    end
  end

  def split_button_toggle
    button_tag(situation: "primary",
               class: "dropdown-toggle",
               "data-toggle" => "dropdown",
               "aria-haspopup" => "true",
               "aria-expanded" => "false") do
      '<span class="caret"></span><span class="sr-only">Toggle Dropdown</span>'
    end
  end

  def list_group content_or_options=nil, options={}
    options = content_or_options if block_given?
    content = block_given? ? yield : content_or_options
    content = Array(content).map(&:to_s)
    add_class options, "list-group"
    options[:items] ||= {}
    add_class options[:items], "list-group-item"
    list_tag content, options
  end

  def list_tag content_or_options=nil, options={}
    options = content_or_options if block_given?
    content = block_given? ? yield : content_or_options
    content = Array(content)
    default_item_options = options.delete(:items) || {}
    tag = options[:ordered] ? :ol : :ul
    wrap_with tag, options do
      content.map do |item|
        i_content, i_opts = item
        i_opts ||= default_item_options
        wrap_with :li, i_content, i_opts
      end
    end
  end
end
