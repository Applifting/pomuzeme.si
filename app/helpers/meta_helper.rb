module MetaHelper
  def page_meta
    path = SessionsHelper.normalize_path(request.path).join('')

    return MetaHelper.default_meta unless I18n.t('meta').keys.any? { |key| key.to_s == path.to_s }

    MetaHelper.meta_for(path)
  end

  def self.extract_values(path, key)
    I18n.t format("meta.%{path}.%{key}", path: path, key: key)
  end

  def self.default_meta
    MetaHelper.meta_for(:home)
  end

  def self.set_url(path)
    "https://pomuzeme.si/#{path}"
  end

  def self.meta_for(path)
    {
      url: MetaHelper.set_url(path),
      title: MetaHelper.extract_values(path, :title),
      description: MetaHelper.extract_values(path, :description)
    }
  end
end
