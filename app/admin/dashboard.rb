ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    div do
      
      span class: "blank_slate" do
        h3 '使用说明'
        span '先在本机安装docker 环境, 然后下载策略docker image 镜像, 然后执行操作'
        ol
          li link_to 'win10 下安装wsl2 ', 'https://zhuanlan.zhihu.com/p/69121280'
          
          li link_to '利用wsl2 安装docker' , 'https://zhuanlan.zhihu.com/p/148511634'
          li link_to 'OSX 安装docker', 'https://zhuanlan.zhihu.com/p/91116621'
          li link_to '安装docker image-布林线突破策略', '#'
        hr
        h3 '一个配置文件对应执行一个策略, 一个期货账号可跑多个策略, 同时可执行策略受本机性能限制'
        para do
           '为了避免系统配置文件生成错误, 请务必按配置表单提示输入!'
        end
      end
    end

    # Here is an example of a simple dashboard with columns and panels.
    #
    # columns do
    #   column do
    #     panel "Recent Posts" do
    #       ul do
    #         Post.recent(5).map do |post|
    #           li link_to(post.title, admin_post_path(post))
    #         end
    #       end
    #     end
    #   end

    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end
  end # content
end
