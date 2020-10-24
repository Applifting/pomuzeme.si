module ApplicationHelper
  def class_names(*classnames)
    classnames.join(' ')
  end

  def if_path_active(path, if_result, else_result = nil)
    request.env['PATH_INFO'] == path ? if_result : else_result
  end
end
