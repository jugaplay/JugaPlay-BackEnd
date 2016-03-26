module ApplicationHelper
  def add_floating_button_for path
    link = link_to '<i class="mdi-content-add"></i>'.html_safe, path, class: 'btn-floating btn-large waves-effect waves-light green'
    "<div class='fixed-action-btn' style='bottom: 20px; right: 24px;'>
      #{link}
    </div>".html_safe
  end

  def remove_button_for path
    link_to '<i class="mdi-navigation-cancel" style="color: red;"></i>'.html_safe, path, method: :delete
  end

  def submit_button_for name
    button_tag name, class: 'waves-effect waves-light btn'
  end

  def bootstrap_class_for_alert_type type
    { 'success' => 'success', 'error' => 'danger', 'alert' => 'warning', 'notice' => 'info' }[type.to_s]
  end
end
