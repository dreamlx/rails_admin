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
  permit_params do
    permitted = [:run_level, :symbol_code, :long_short_judgment, :major_period, :minor_period,
      :boll, :start_from, :to_end,
      :sim_account, :sim_pwd,
      :future_account, :future_pwd, :future_company
      ]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  end

  form do |f|
    f.semantic_errors

    blockquote "#CFFEX: 中金所
      #SHFE: 上期所
      #DCE: 大商所
      #CZCE: 郑商所
      #INE: 能源交易所(原油)"
      
    

    f.inputs '配置内容' do
      f.input :title, hint: '策略命名原则为帮助记忆, 比如 jd_boll_只开空'      
      f.input :symbol_code, label: '期货代码', hint:  "提示格式: DCE.jd2109"
      f.input :run_level, label: '运行模式', 
      :as => :select, 
      :collection => [[ '回测', 'replay'],['模拟实盘', 'sim'],['真实交易', 'real'],], 
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

      f.input :boll, label: '布林线周期', hint: '26'

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
      row :sim_account
      row :future_company
      row :future_account
      row :memo
    end

    active_admin_comments
  end
  
  index do
    selectable_column
    id_column
    
    column :title
    column :symbol_code
    column :run_level
    column :created_at
    actions
  end

  member_action :build_yml, method: :post do
    if request.post?
      
      flash[:notice] = '构建配置内容 created successfully'
      redirect_to admin_configration_path

    end
  end
  
  action_item only: :show do
    link_to '创建配置文件', build_yml_admin_configration_path(resource), method: :post
  end
end
