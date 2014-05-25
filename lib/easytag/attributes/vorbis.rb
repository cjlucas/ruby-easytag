require_relative 'base'

module EasyTag
  module VorbisAttributeAccessors
    include BaseAttributeAccessors


    def read_fields(xiph_comment, fields, **opts)
      fields = Array(fields)
      fields.each do |field|
        next unless xiph_comment.contains?(field)
        data = xiph_comment.field_list_map[field]
        return opts[:returns] == :list ? data : data.first
      end
      opts[:returns] == :list ? [] : nil
    end
  end
end