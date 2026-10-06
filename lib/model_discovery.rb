# frozen_string_literal: true

require 'yaml'

class ModelDiscovery # rubocop:disable Style/Documentation
  def self.discover(base_dir) # rubocop:disable Metrics
    return new([]) unless Dir.exist?(base_dir)

    entries = []

    Dir.children(base_dir).sort.each do |entry|
      full_path = File.join(base_dir, entry)

      if File.file?(full_path) && entry.end_with?('.gguf')
        entries << {
          label: File.basename(entry, '.gguf'),
          model_path: full_path,
          mmproj_path: '',
          size_bytes: File.size(full_path)
        }
      elsif File.directory?(full_path)
        gguf_files = Dir.glob(File.join(full_path, '*.gguf')).sort
        model_files, mmproj_files = gguf_files.partition { |f| !mmproj?(f) }

        next if model_files.empty?

        entries << {
          label: entry,
          model_path: model_files.first,
          mmproj_path: mmproj_files.first || '',
          size_bytes: gguf_files.sum { |f| File.size(f) }
        }
      end
    end

    new(entries, read_default_label(base_dir))
  end

  def self.read_default_label(base_dir)
    catalog = YAML.safe_load_file(File.join(base_dir, '.catalog.yaml'))
    return nil unless catalog.is_a?(Hash)

    value = catalog['default_model']
    return nil unless value.is_a?(String)

    label = File.basename(value.strip.chomp('/'), '.gguf')
    label.empty? ? nil : label
  rescue ArgumentError, EncodingError, IOError, SystemCallError,
         Psych::Exception # YAML parser exceptions
    nil
  end

  def self.mmproj?(filename)
    File.basename(filename).start_with?('mmproj')
  end

  private_class_method :read_default_label, :mmproj?

  def initialize(entries, default_label = nil)
    @entries = entries
    @default_label = default_label
  end

  def options
    @entries.map do |m|
      [
        display_label(m),
        m[:model_path],
        {
          'data-set-model-file' => m[:model_path],
          'data-set-mmproj-file' => m[:mmproj_path]
        }
      ]
    end
  end

  def default_entry
    @entries.find { |m| m[:label] == @default_label } || @entries.first ||
      { model_path: '', mmproj_path: '' }
  end

  private

  def display_label(entry)
    return entry[:label] unless entry[:size_bytes]&.positive?

    "#{entry[:label]} (#{format_size(entry[:size_bytes])})"
  end

  def format_size(bytes)
    "#{(bytes.to_f / 1.gigabyte).ceil} GB"
  end
end
