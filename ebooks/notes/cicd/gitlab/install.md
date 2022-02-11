## Install GitLab
Follow https://about.gitlab.com/install/#ubuntu to install Omnibus version GitLab.

## Configure GitLab
+ Run command “gitlab-ctl stop” to stop GitLab

+ Edit “/etc/gitlab/gitlab.rb”, and set below configuration to enable https
    ```bash
    external_url https://gitlab.dc.mikesay.com
    nginx['redirect_http_to_https'] = true

    nginx['ssl_certificate'] = "/etc/gitlab/ssl/gitlab.dc.mikesay.com.crt" 
    nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/gitlab.dc.mikesay.com.key"
    ```
+ Edit “/etc/gitlab/gitlab.rb”, and set below configuration to change GitLab data folder
    ```ruby
    git_data_dirs({
    "default" => {
    "path" => "/data/gitlab/git-data"
    }
    })
    ```
+ Edit “/etc/gitlab/gitlab.rb”, to set SMTP server for email notification
    ```ruby
    gitlab_rails['smtp_enable'] = true
    gitlab_rails['smtp_address'] = "smtp.mikesay.com"
    gitlab_rails['smtp_port'] = 465
    gitlab_rails['smtp_user_name'] = "devops@mikesay.com"
    gitlab_rails['smtp_password'] = "xxxx"
    gitlab_rails['smtp_domain'] = "mikesay.com"
    gitlab_rails['smtp_authentication'] = "login"
    gitlab_rails['smtp_enable_starttls_auto'] = true
    gitlab_rails['smtp_tls'] = true

    ###! **Can be: 'none', 'peer', 'client_once', 'fail_if_no_peer_cert'**
    ###! Docs: http://api.rubyonrails.org/classes/ActionMailer/Base.html
    gitlab_rails['smtp_openssl_verify_mode'] = 'peer'
    ```
+ Run command “gitlab-ctl reconfigure” and “gitlab-ctl start” to reconfigure and start GitLab with newly configuration
