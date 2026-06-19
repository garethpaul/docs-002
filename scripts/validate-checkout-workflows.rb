#!/usr/bin/env ruby
# frozen_string_literal: true

require "psych"

PINNED_CHECKOUT = "actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10"

def fail_policy(message)
  warn "checkout workflow policy: #{message}"
  exit 1
end

def validate_ast(node, path)
  if node.respond_to?(:tag) && node.tag
    fail_policy("#{path} must not use explicit YAML tags")
  end

  case node
  when Psych::Nodes::Alias
    fail_policy("#{path} must not use YAML aliases")
  when Psych::Nodes::Mapping
    keys = {}
    node.children.each_slice(2) do |key, value|
      fail_policy("#{path} must use scalar mapping keys") unless key.is_a?(Psych::Nodes::Scalar)
      fail_policy("#{path} contains duplicate key #{key.value.inspect}") if keys.key?(key.value)

      keys[key.value] = true
      validate_ast(key, path)
      validate_ast(value, path)
    end
  else
    children = node.children if node.respond_to?(:children)
    children&.each { |child| validate_ast(child, path) }
  end
end

workflow_dir = File.expand_path(ARGV.fetch(0, File.join(__dir__, "..", ".github", "workflows")))
fail_policy("workflow directory is missing") unless File.directory?(workflow_dir)

workflow_paths = Dir.children(workflow_dir)
  .select { |name| name.end_with?(".yml", ".yaml") }
  .sort
  .map { |name| File.join(workflow_dir, name) }

fail_policy("at least one workflow file is required") if workflow_paths.empty?

checkout_steps = []

workflow_paths.each do |path|
  fail_policy("#{path} must be a regular file") unless File.file?(path) && !File.symlink?(path)

  begin
    content = File.read(path, encoding: "UTF-8")
    stream = Psych.parse_stream(content, filename: path)
    fail_policy("#{path} must contain exactly one YAML document") unless stream.children.length == 1
    validate_ast(stream, path)
    workflow = Psych.safe_load(
      content,
      permitted_classes: [],
      permitted_symbols: [],
      aliases: false,
      filename: path
    )
  rescue Psych::Exception => error
    fail_policy("#{path} is not unambiguous safe YAML: #{error.message}")
  end

  fail_policy("#{path} must contain a workflow mapping") unless workflow.is_a?(Hash)
  jobs = workflow["jobs"]
  fail_policy("#{path} must contain a jobs mapping") unless jobs.is_a?(Hash)

  jobs.each do |job_name, job|
    fail_policy("#{path} job #{job_name.inspect} must be a mapping") unless job.is_a?(Hash)
    next unless job.key?("steps")

    steps = job["steps"]
    fail_policy("#{path} job #{job_name.inspect} steps must be a sequence") unless steps.is_a?(Array)
    steps.each_with_index do |step, index|
      fail_policy("#{path} job #{job_name.inspect} step #{index + 1} must be a mapping") unless step.is_a?(Hash)
      uses = step["uses"]
      next unless uses.is_a?(String) && uses.match?(/\Aactions\/checkout@/i)

      checkout_steps << [path, job_name, index + 1, step]
    end
  end
end

fail_policy("exactly one checkout step is required across all workflows") unless checkout_steps.length == 1

path, job_name, index, checkout = checkout_steps.fetch(0)
fail_policy("#{path} job #{job_name.inspect} step #{index} must use the reviewed checkout commit") unless checkout["uses"] == PINNED_CHECKOUT

options = checkout["with"]
fail_policy("#{path} job #{job_name.inspect} step #{index} must have a with mapping") unless options.is_a?(Hash)
credential_keys = options.keys.select do |key|
  key.is_a?(String) && key.casecmp?("persist-credentials")
end
unless credential_keys == ["persist-credentials"] && options["persist-credentials"] == false
  fail_policy("#{path} job #{job_name.inspect} step #{index} must set persist-credentials to boolean false")
end

puts "checkout workflow policy passed."
