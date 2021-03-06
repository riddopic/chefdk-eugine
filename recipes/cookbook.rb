# encoding: UTF-8

context = ChefDK::Generator.context
cookbook_dir = File.join(context.cookbook_root, context.cookbook_name)

directory cookbook_dir

template "#{cookbook_dir}/metadata.rb" do
  helpers(ChefDK::Generator::TemplateHelper)
  action :create_if_missing
end

template "#{cookbook_dir}/README.md" do
  helpers(ChefDK::Generator::TemplateHelper)
  action :create_if_missing
end

cookbook_file "#{cookbook_dir}/chefignore"

if context.use_berkshelf
  cookbook_file "#{cookbook_dir}/Berksfile" do
    action :create_if_missing
  end
else
  template "#{cookbook_dir}/Policyfile.rb" do
    source 'Policyfile.rb.erb'
    helpers(ChefDK::Generator::TemplateHelper)
  end
end

template "#{cookbook_dir}/.kitchen.yml" do
  if context.use_berkshelf
    source 'kitchen.yml.erb'
  else
    source 'kitchen_policyfile.yml.erb'
  end
  helpers(ChefDK::Generator::TemplateHelper)
  action :create_if_missing
end

directory "#{cookbook_dir}/test/integration/default/serverspec" do
  recursive true
end

template "#{cookbook_dir}/test/integration/default/serverspec/default_spec.rb" do
  source 'serverspec_default_spec.rb.erb'
  helpers(ChefDK::Generator::TemplateHelper)
  action :create_if_missing
end

directory "#{cookbook_dir}/test/integration/helpers/serverspec" do
  recursive true
end

cookbook_file "#{cookbook_dir}/test/integration/helpers/serverspec/spec_helper.rb" do
  source 'serverspec_spec_helper.rb'
  action :create_if_missing
end

cookbook_file File.join(cookbook_dir, '.rspec') do
  source '.rspec'
  action :create_if_missing
end

directory "#{cookbook_dir}/spec/unit/recipes" do
  recursive true
end

template File.join(cookbook_dir, 'spec', 'spec_helper.rb') do
  source 'spec_spec_helper.rb.erb'
  backup false
  variables(
    use_berkshelf: context.use_berkshelf
  )
  action :create_if_missing
end

template "#{cookbook_dir}/spec/unit/recipes/default_spec.rb" do
  source 'recipe_spec.rb.erb'
  helpers(ChefDK::Generator::TemplateHelper)
  action :create_if_missing
end

cookbook_file File.join(cookbook_dir, 'Rakefile') do
  source 'Rakefile'
  backup false
  action :create_if_missing
end

cookbook_file File.join(cookbook_dir, '.rubocop.yml') do
  source '.rubocop.yml'
  backup false
  action :create_if_missing
end

directory "#{cookbook_dir}/recipes"

template "#{cookbook_dir}/recipes/default.rb" do
  source 'recipe.rb.erb'
  helpers(ChefDK::Generator::TemplateHelper)
  action :create_if_missing
end

if context.have_git
  unless context.skip_git_init
    execute('initialize-git') do
      command('git init .')
      cwd cookbook_dir
    end
  end

  cookbook_file "#{cookbook_dir}/.gitignore" do
    source 'gitignore'
  end
end
