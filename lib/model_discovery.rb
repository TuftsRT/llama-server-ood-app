# frozen_string_literal: true

class ModelDiscovery # rubocop:disable Style/Documentation
  def initialize(entries)
    @entries = entries
  end

  def options
    @entries.map do |m|
      [
        m[:label],
        m[:model_path],
        {
          'data-set-model-file' => m[:model_path],
          'data-set-mmproj-file' => m[:mmproj_path]
        }
      ]
    end
  end

  def first_model_path
    @entries.first&.fetch(:model_path, '')
  end

  def first_mmproj_path
    @entries.first&.fetch(:mmproj_path, '')
  end
end

def mmproj?(filename)
  File.basename(filename).start_with?('mmproj')
end

def discover_models(base_dir) # rubocop:disable Metrics
  return ModelDiscovery.new([]) unless Dir.exist?(base_dir)

  entries = []

  Dir.children(base_dir).sort.each do |entry|
    full_path = File.join(base_dir, entry)

    if File.file?(full_path) && entry.end_with?('.gguf')
      entries << {
        label: File.basename(entry, '.gguf'),
        model_path: full_path,
        mmproj_path: ''
      }
    elsif File.directory?(full_path)
      gguf_files = Dir.glob(File.join(full_path, '*.gguf')).sort
      model_files, mmproj_files = gguf_files.partition { |f| !mmproj?(f) }

      next if model_files.empty?

      entries << {
        label: entry,
        model_path: model_files.first,
        mmproj_path: mmproj_files.first || ''
      }
    end
  end

  ModelDiscovery.new(entries)
end
