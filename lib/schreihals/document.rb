require 'tilt'

module Schreihals
  class Document
    cattr_accessor :documents
    @@documents = []

    attr_accessor :attributes

    def initialize(attrs = {})
      @attributes = attrs
      @@documents << self
    end

    def file_extension
      File.extname(file_name).sub(/^\./, '')
    end

    def file_name_without_extension
      File.basename(file_name, '.'+file_extension)
    end

    def method_missing(name, *args)
      attributes.has_key?(name.to_s) ? attributes[name.to_s] : super
    end

    def to_html
      Tilt.new(file_extension) { body }.render
    end

    class << self
      def from_string(s, attrs = {})
        frontmatter, body = split_original_document(s)
        new(Psych.load(frontmatter).
          merge('body' => body.strip).
          merge(attrs))
      end

      def from_file(name)
        from_string(open(name).read, 'file_name' => File.basename(name))
      end

      def load_from_directory(dir)
        Dir[File.join(dir, "*")].collect { |f| from_file f }
      end

      def split_original_document(s)
        s =~ /.*(---\s*\n.*)\n---\s*\n(.*)/m ? [$1, $2] : [nil, s]
      end
    end
  end
end