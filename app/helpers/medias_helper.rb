module MediasHelper
  def embed_url(request = @request)
    src = convert_url_to_format(request.original_url, 'js')
    "<script src=\"#{src}\" type=\"text/javascript\"></script>".html_safe
  end

  def convert_url_to_format(url, format)
    url = url.sub(/medias([^\?]*)/, 'medias.' + format)
    if url =~ /refresh=1/
      url = url.sub(/refresh=1/, '').sub(/medias\.#{format}\?/, "medias.#{format}?refresh=1&").sub(/\&$/, '')
    end
    url
  end

  def timeout_value
    CONFIG['timeout'] || 20
  end

  def handle_exceptions(media, exception, message_method = :message, code_method = :code)
    begin
      yield
    rescue exception => error
      code = error.respond_to?(code_method) ? error.send(code_method) : 5
      media.data.merge!(error: { message: "#{error.class}: #{error.send(message_method)}", code: code })
      return
    end
  end

  def get_metatags(media)
    fields = []
    unless media.doc.nil?
      media.doc.search('meta').each do |meta|
        metatag = {}
        meta.each { |key, value| metatag.merge!({key => value}) }
        fields << metatag
      end
    end
    fields
  end

  def get_html_metadata(media, attr, metatags)
    data = {}
    metatags.each do |key, value|
      metatag = media.data['raw']['metatags'].find { |tag| tag[attr] == value }
      data[key] = metatag['content'] if metatag
    end
    data
  end

  def get_info_from_api_data(data, *args)
    hash = data['raw']['api']
    args.each do |i|
      return hash[i] if !hash[i].nil?
    end
    ''
  end
end
