require 'parser'
require 'parser/current'

# Simple documentation generator class, designed to be run locally
class UserDocumentationGenerator
  def initialize
    @files = Dir.glob(File.join(File.dirname(__FILE__), '..', 'app', 'drops', '**', '*.rb'))
    @drops_documentation = {}
    @liquid_views_variables = {}
    @workflow_variables = {}
    @parsed_files = {}
  end

  def generate_documentation
    # fills up the @drops_documentation hash
    parse_drop_files

    # liquid view variables
    parse_liquid_views_variables

    # parse workflows
    parse_workflows

    @output_file = open(File.join(File.dirname(__FILE__), '..', 'user_docs.html'), 'w')
    begin
      output_documentation_html
    ensure
      @output_file.close
    end
  end

  private

  def output_text(text)
    @output_file.write(text)
  end

  def output_documentation_html
    content_tag('html') do
      content_tag('head') do
        content_tag('title') do
          output_text 'User documentation'
        end
      end

      content_tag('body') do
        content_tag('p', 'font-size: 200%') do
          output_text 'Drops documentation'
        end

        output_drops_documentation

        content_tag('p', 'font-size: 200%') do
          output_text 'Liquid views variables'
        end

        output_liquid_views_variables

        content_tag('p', 'font-size: 200%') do
          output_text 'Workflows'
        end

        output_workflows
      end
    end
  end

  def output_workflows
    @workflow_variables.each do |workflow_name, workflow_steps|
      content_tag('p', 'font-size: 125%') do
        content_tag('strong') do
          output_text "Workflow Name: #{workflow_name}"
        end
      end

      output_workflow_steps(workflow_steps)
    end
  end

  def output_workflow_steps(workflow_steps)
    workflow_steps.each do |workflow_step_name, workflow_alerts|
      content_tag('p', 'font-size: 118%') do
        content_tag('strong') do
          output_text "Workflow step: #{workflow_step_name}"
        end
      end

      output_workflow_alerts(workflow_alerts)
    end
  end

  def output_workflow_alerts(workflow_alerts)
    workflow_alerts.each do |workflow_alert|
      content_tag('p', 'font-size: 110%') do
        output_text "Workflow Alert: #{workflow_alert[:name]}"
      end

      content_tag('table') do
        content_tag('tr') do
          content_tag('td') do
            output_text 'Template path'
          end
          content_tag('td') do
            output_text workflow_alert[:template_path]
          end
        end

        content_tag('tr') do
          content_tag('td') do
            output_text 'Alert type'
          end
          content_tag('td') do
            output_text workflow_alert[:alert_type]
          end
        end

        content_tag('tr') do
          content_tag('td') do
            output_text 'Recipient type'
          end
          content_tag('td') do
            output_text workflow_alert[:recipient_type]
          end
        end

        content_tag('tr') do
          content_tag('td') do
            output_text 'Variables'
          end
          content_tag('td') do
            output_workflow_alerts_variables(workflow_alert[:variables])
          end
        end
      end
    end
  end

  def output_workflow_alerts_variables(variables)
    content_tag('table') do
      variables.each do |variable_name, explanation|
        content_tag('tr') do
          content_tag('td') do
            output_text variable_name
          end

          content_tag('td') do
            output_text explanation
          end
        end
      end
    end
  end

  def output_liquid_views_variables
    @liquid_views_variables.each do |liquid_view_path, liquid_variables|
      content_tag('p', 'font-size: 125%') do
        content_tag('strong') do
          output_text liquid_view_path
        end
      end

      liquid_variables.each do |liquid_variable, explanation|
        content_tag('table') do
          content_tag('tr') do
            content_tag('td') do
              content_tag('strong') do
                output_text liquid_variable
              end
            end

            content_tag('td') do
              output_text explanation
            end
          end
        end
      end
    end
  end

  def output_drops_documentation
    @drops_documentation.each do |class_name, class_doc|
      content_tag('p', 'font-size: 125%;') do
        content_tag('strong') do
          output_text class_name
        end
      end

      class_doc.each do |node_name, node_value|
        if node_name != :delegate
          content_tag('table') do
            content_tag('tr') do
              content_tag('td') do
                content_tag('strong') do
                  output_text node_name
                end
              end

              content_tag('td') do
                output_text htmlize_node_value(node_value)
              end
            end
          end
        end
      end
    end
  end

  def parse_workflows
    # Utils::DefaultAlertsCreator.new.create_all_workflows!
    PlatformContext.current = PlatformContext.new(Instance.find_by_id(1) || Instance.first)

    Workflow.all.each do |workflow|
      @workflow_variables[workflow.name] ||= {}

      workflow.workflow_steps.each do |workflow_step|
        @workflow_variables[workflow.name][workflow_step.name] ||= []

        workflow_step.workflow_alerts.each do |workflow_alert|
          workflow_alert_info = {}
          @workflow_variables[workflow.name][workflow_step.name] << workflow_alert_info

          workflow_alert_info[:name] = workflow_alert.name
          workflow_alert_info[:template_path] = workflow_alert.template_path
          workflow_alert_info[:alert_type] = workflow_alert.alert_type
          workflow_alert_info[:recipient_type] = workflow_alert.recipient_type
          workflow_alert_info[:variables] = get_variables_for_workflow_alert(workflow_alert)
        end
      end
    end

    @workflow_variables = @workflow_variables.sort { |v1, v2| v1[0] <=> v2[0] }.to_h
    @workflow_variables.each do |k, v|
      @workflow_variables[k] = v.sort { |v1, v2| v1[0] <=> v2[0] }.to_h
      @workflow_variables[k].each do |_workflow_step_name, alert_infos|
        alert_infos.each do |alert_info|
          alert_info[:variables] = alert_info[:variables].sort { |v1, v2| v1[0] <=> v2[0] }.to_h
        end
      end
    end
  end

  def get_variables_for_workflow_alert(workflow_alert)
    data_method_info = workflow_alert.workflow_step.associated_class.constantize.instance_method(:data).source_location
    file = data_method_info[0]

    ast, comments_association = raw_parse_file(file)

    data_comment = find_data_method_comment(ast, comments_association)

    if data_comment.blank?
      raise StandardError, "could not find data method comment: #{file}"
    end

    parse_variables_from_data_comment(data_comment)
  rescue StandardError => e
    {}
  end

  def parse_variables_from_data_comment(comment)
    parse_key_values_from_indented_comment(comment)
  end

  def find_data_method_comment(ast, comments_association)
    data_comment = nil

    if ast.to_a[2].type == :begin
      search_array = ast.to_a[2].to_a
    else
      search_array = ast.to_a
    end

    search_array.to_a.each do |item|
      if item.type == :def
        if item.to_a[0] == :data
          data_comment = comments_association[item].collect(&:text).join("\n").gsub(/#/, '')

          break
        end
      end
    end

    data_comment
  end

  def raw_parse_file(file_path)
    unless @parsed_files[file_path]
      ast, comments = Parser::CurrentRuby.parse_with_comments(File.read(file_path))
      comments_association = Parser::Source::Comment.associate(ast, comments)

      @parsed_files[file_path] = {}
      @parsed_files[file_path][:ast] = ast
      @parsed_files[file_path][:comments] = comments_association
    end

    [@parsed_files[file_path][:ast], @parsed_files[file_path][:comments]]
  end

  def htmlize_node_value(node_value)
    node_value.gsub(/\r\n|\r|\n/, '<br/>')
  end

  def content_tag(tag_name, styles = '')
    styles_fragment = ''
    styles_fragment = "style='#{styles}'" unless styles.empty?

    output_text "<#{tag_name} #{styles_fragment}>"
    yield
    output_text "</#{tag_name}>"
  end

  def parse_drop_files
    @files.each do |file|
      parse_drop_file(file)
    end

    @drops_documentation = @drops_documentation.sort { |v1, v2| v1[0] <=> v2[0] }.to_h
    @drops_documentation.each do |k, v|
      @drops_documentation[k] = v.sort { |v1, v2| v1[0] <=> v2[0] }.to_h
    end
  end

  def parse_liquid_views_variables
    @liquid_views_variables = InstanceView::DEFAULT_LIQUID_VIEWS_PATHS.dup
    @liquid_views_variables = @liquid_views_variables.sort { |v1, v2| v1[0] <=> v2[0] }.to_h
    @liquid_views_variables.each do |k, _v|
      @liquid_views_variables[k] = @liquid_views_variables[k].sort { |v1, v2| v1[0].to_s <=> v2[0].to_s }.to_h
    end
  end

  def parse_drop_file(file_path)
    file_contents = File.read(file_path)

    ast, comments = Parser::CurrentRuby.parse_with_comments(file_contents)
    comments_association = Parser::Source::Comment.associate(ast, comments)

    if ast.type == :class
      class_name = get_drop_class_name(ast)
      @drops_documentation[class_name] = parse_ast(ast, comments_association)
    end
  end

  def parse_ast_const(ast)
    if ast.to_a[0].nil?
      return ast.to_a[1]
    else
      return [parse_ast_const(ast.to_a[0]), ast.to_a[1]]
    end
  end

  def get_drop_class_name(ast)
    class_names = []
    ast.to_a.each do |ast_node|
      if ast_node && ast_node.type == :const
        class_names << parse_ast_const(ast_node)
      end
    end

    class_names.flatten.join('::').gsub(/::BaseDrop$/, '')
  end

  def parse_delegate_comment(comment)
    parse_key_values_from_indented_comment(comment)
  end

  def parse_key_values_from_indented_comment(comment)
    parsed_hash = {}

    current_item = nil
    comment_lines = comment.split(/\n/)
    comment_lines.each do |comment_line|
      match_heading = comment_line.match(/^\s{0,1}([^\s]+)/)
      match_contents = comment_line.match(/^\s{3,}([^\s]+)/)

      if match_heading
        current_item = match_heading.to_a[1]
      elsif match_contents && current_item
        parsed_hash[current_item] ||= ''
        parsed_hash[current_item] << comment_line.strip + "\n"
      else
        current_item = nil
      end
    end

    parsed_hash
  end

  def parse_ast(ast, comments_association)
    node_documentation = {}

    begin_node = ast.to_a.find { |node| node && node.type == :begin }
    begin_node.to_a.each do |node|
      unless comments_association[node].empty?
        node_list = node.to_a
        if node.type == :def || (node.type == :send && node_list.length >= 2 && node_list[1] == :delegate)
          comment = comments_association[node].collect(&:text).join("\n")
          parsed_comment = comment.gsub(/#/, '')

          if node.type == :def
            node_name = node.to_a[0]
            node_documentation[node_name.to_s] = parsed_comment.strip
          else
            parse_delegate_comment(parsed_comment).each do |k, v|
              node_documentation[k.to_s] = v
            end
          end
        end
      end
    end

    node_documentation
  end
end
