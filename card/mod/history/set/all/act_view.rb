ACTS_PER_PAGE = Card.config.acts_per_page

format :html do
  def default_act_args args
    act = (args[:act]  ||= Act.find(params["act_id"]))
    args[:act_seq]     ||= params["act_seq"]
    args[:hide_diff]   ||= hide_diff?
    args[:slot_class]  ||= "revision-#{act.id} history-slot list-group-item"
    args[:action_view] ||= action_view
    act_context args
  end

  view :act_list, cache: :never do |args|
    act_accordion args do |act, act_seq|
      render_act args.merge(act: act, act_seq: act_seq)
    end
  end

  def act_accordion args
    acts = args.delete :acts
    page = params["page"] || 1
    count = acts.size + 1 - (page.to_i - 1) * ACTS_PER_PAGE
    rendered_acts = acts.map do |act|
      count -= 1
      yield act, count
    end
    accordion_group rendered_acts, nil, class: "clear-both"
  end


  view :act, cache: :never do |args|
    act_renderer(args[:act_context]).new(self, args[:act], args).render
  end

  def action_icon action_type, extra_class=nil
    icon = case action_type
           when :create then :plus
           when :update then :pencil
           when :delete then :trash
           when :draft then :wrench
           end
    icon_tag icon, extra_class
  end

  def action_view
    (params["action_view"] || "summary").to_sym
  end

  def hide_diff?
    params["hide_diff"].to_s.strip == "true"
  end

  private

  def act_renderer context
    if context == :absolute
      Act::ActRenderer::AbsoluteActRenderer
    else
      Act::ActRenderer::RelativeActRenderer
    end
  end

  def act_context args
    args[:act_context] =
      (args[:act_context] || params["act_context"] || :relative).to_sym
  end
end
