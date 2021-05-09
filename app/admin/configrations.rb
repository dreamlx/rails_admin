ActiveAdmin.register Configration do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :run_status, :symbol
  #
  # or
  #
  require 'socket'

  permit_params do
    permitted = [:title, :run_level, 
      :symbol_code, :long_short_judgment, 
      :major_period, :minor_period,
      :boll, :start_from, :to_end, :kbar_period,
      :sim_account, :sim_pwd, :position_size,
      :future_account, :future_pwd, :future_company, :memo
      ]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  end

  form do |f|
    f.semantic_errors

    
    para do 
      # link_to '期货代码组合tqsdk参考', 'https://doc.shinnytech.com/pysdk/latest/usage/mddatas.html', target: '_blank'
      link_to '期货代码组合一览', 'https://www.akshare.xyz/zh_CN/latest/data/futures/futures.html', target: '_blank'
    end

    f.inputs '配置内容' do
      f.input :title, hint: '策略命名原则为帮助记忆, 比如 jd_boll_只开空'      
      f.input :position_size
      f.input :symbol_code, label: '期货代码', hint:  (link_to '提示格式: DCE.jd2109, 期货代码组合一览', 'https://www.akshare.xyz/zh_CN/latest/data/futures/futures.html', target: '_blank')
      f.input :run_level, label: '运行模式', 
      :as => :select, 
      :collection => [[ '回测-replay', 'replay'],['模拟实盘-sim', 'sim'],['真实交易-real', 'real'],], 
      :include_blank => true, 
      hint:  "当模式为replay时候, 回测周期才有效; 模式为 real 需要配置绑定真实期货账号, 模式为sim 需要绑定simsnow 账号"
      f.input :long_short_judgment,  
        :as => :select, 
        :collection => [[ '多', 'long'],['空', 'short'],['AI自动', 'auto'],], 
        :include_blank => true, 
        hint:  "选多, 主观判断当前主要趋势为上涨; 选空, 主观判断为下跌; 如果选择AI自动, 则由系统按均线组合判断多空, 双向开仓", 
        label: '趋势选择'

      f.inputs '长短期均线组合(趋势判断为 AI自动 时候起效)' do
        f.input :major_period, label: '主要MA均线(长), 单位分钟', hint: '4 * 60 = 240'
        f.input :minor_period,  label: '次要MA均线(短), 单位分钟', hint: '60'
      end

      f.input :kbar_period, label: '布林线K线单位(分钟)', 
        hint: '5, 代表5分钟为一个K线的序列, 如果是一小时k线, 就输入60'
      f.input :boll, label: '布林线周期', hint: '26, 代表输入26个k线bar'
      

      f.inputs '回测时间段, 只有当运行模式为 回测replay时候有效' do
        f.input :start_from, label: '开始日期', as: :datepicker,
        datepicker_options: {
          min_date: "2016-1-1",
          max_date: "+3D"
        }
        f.input :to_end, label: '结束日期', as: :datepicker,
        datepicker_options: {
          min_date: "2016-1-1",
          max_date: "+3D"
        }
      end

      f.inputs 'simsnow 账号配置' do
        
        
        f.input :sim_account, label: '信易账户'
        f.input :sim_pwd, as: :password, label: '账号密码'

        div do
          link_to("注册模拟账号", 'https://account.shinnytech.com/')
        end
      end

      f.inputs '期货实盘账号配置' do
        f.input :future_company, label: '期货公司', hint: 'H海通期货 或者 simnow'
        f.input :future_account, label: '期货账号'
        f.input :future_pwd, as: :password, label: '交易密码'

        div do
          link_to('期货公司支出列表', 'https://www.shinnytech.com/blog/tq-support-broker/')
        end
      end
      
      # f.inputs '商品图片', :multipart => true do
      #   f.input :avatar, as: :file, hint: (image_tag(f.object.avatar.url, size: '256x256') if !f.object.new_record? and !f.object.avatar.url.nil?)
      #   f.input :avatar_cache, as: :hidden
      # end

    end
    f.actions
  end

  show do
    attributes_table do
      row :title
      row :symbol_code
      row :run_level
      row :long_short_judgment
      row :major_period
      row :minor_period
      row :start_from
      row :to_end
      row :kbar_period
      row :boll
      row :sim_account
      row :future_company
      row :future_account
      unless resource.web_url.blank?
        row '策略运行可视化地址' do 
          link_to resource.web_url, resource.web_url
        end
      end
      unless resource.config_url.blank?
        row '下载配置' do
          link_to resource.config_url, resource.config_url
        end
      end
      row :memo
      row :updated_at
    end

    active_admin_comments
  end
  
  index do
    selectable_column
    id_column
    
    column :title
    column :symbol_code
    column :run_level
    column :updated_at
    actions
  end

  member_action :build_yml, method: :post do
    if request.post?
      
      ip_address = '127.0.0.1'

      port = 3000 + resource.id

      config_name_org = 'config' + resource.id.to_s + '.yml'
      config_name= Rails.root.join("public/yml/", config_name_org)

      #创建文件,参数1:路径path,参数2:对内容的操作
      web_gui = 'http://' + ip_address + ':'+ port.to_s
      download_file = 'http://' + ip_address + ':3000/' + 'yml/' + config_name_org

      resource.web_url = web_gui
      resource.config_url = download_file
      resource.memo = "执行策略docker 后的可视化地址: #{web_gui},  配置文件下载地址: #{download_file}"  

      flash[:notice] = '构建配置内容 created successfully ' + resource.memo
      resource.save!
      
      recipe = { 'title' => resource.title,
      'position_size' => resource.position_size,
      'symbol_code' => resource.symbol_code, 
      'run_level' => resource.run_level,
      'long_short_judgment' => resource.long_short_judgment,
      'major_period'=> resource.major_period,
      'minor_period'=> resource.minor_period,
      'boll_period' => resource.boll,
      'kbar_period' =>  resource.kbar_period, 
      'start_from'=> resource.start_from,
      'to_end'=> resource.to_end,
      'web_url' => resource.web_url,
      'config_url' => resource.config_url,
      'sim_account'=> resource.sim_account,
      'sim_pwd'=> resource.sim_pwd,
      'future_company'=> resource.future_company,
      'future_account'=> resource.future_account,
      'future_pwd'=> resource.future_pwd,
      'memo'=> resource.memo  }

      File.open(config_name, "w") { |file| file.write(recipe.to_yaml) }


      redirect_to admin_configration_path

    end
  end
  
  member_action :copy_yml, method: :get do

    new_item = resource.dup
    new_item.title += ('_copy_' + Time.now.to_s)
    new_item.save
    flash[:notice] = '复制配置成功' + ('_copy_' + Time.now.to_s)
    redirect_to admin_configrations_path
    
  end

  action_item :build_yml,  only: [ :show ] do
    link_to "构建配置", build_yml_admin_configration_path(resource), method: :post
  end

  action_item :copy_yml,  only: [ :show ] do
    link_to "复制策略", copy_yml_admin_configration_path(resource)
  end
end
