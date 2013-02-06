define :drupal_project, :user => 'drupal', :httpd_group => 'www-data', :repository => nil, :revision => 'master' do
  drupal_path = params[:name]
  drupal_uri  = params[:drupal_uri]
  site_name   = params[:site_name]
  drupal_user = params[:user]
  httpd_group = params[:httpd_group]
  drupal_repo = params[:repository]  ? params[:repository]  : nil
  drupal_rev  = params[:revision]    ? params[:revision]    : nil
  ssh_wrap    = params[:ssh_wrapper] ? params[:ssh_wrapper] : nil

  drupal_root = drupal_path
  unless drupal_repo.nil?
    drupal_deploy = deploy drupal_path do
      repository                  drupal_repo
      revision                    drupal_rev
      user                        drupal_user
      ssh_wrapper                 ssh_wrap
      # TODO: figure out what to do with these
      symlinks.clear
      symlink_before_migrate.clear
      create_dirs_before_symlink  []
      purge_before_symlink        []
    end
    drupal_root = drupal_deploy.current_path
  end

  drupal_site site_name do
    drupal_root drupal_root
    drupal_user drupal_user
    httpd_group httpd_group
    site_uri    drupal_uri
    cookbook    "drupal_projects"
    enable      true
  end

  execute "#{Chef::Config[:file_cache_path]}/file-permissions.sh --httpd_group=#{httpd_group} --drupal_path=#{drupal_root} --drupal_user=#{drupal_user}"
end
